import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:stack/stack.dart';
import 'package:tuple/tuple.dart';

import 'package:pyssembly/errors/compilation_error.dart';

import 'lexemes.dart';


extension Line on String {
	/// The line's indentation change, relative to the previous line.
	/// 
	/// If the indentation holds, returns 0.
	/// If it increases, returns the number of spaces it does by, as a positive [int].
	/// If it decreases, returns the number of levels it exits as a negative [int].
	int indentationChange(List<int> indentations) {
		final indentation = length - trimLeft().length;
		int change = indentation - indentations.last;

		if (change == 0) return 0;

		if (change > 0) return change;

		int indentationIndex = indentations.indexOf(indentation);
		if (indentationIndex != -1) {
			return indentationIndex - (indentations.length - 1);
		}
		
		throw IndentationError.noMatch();
	}

	/// The [Match?] of the variable [lexeme] at the beginning of the string.
	Match? prefixVarLexemeMatch(Lexeme lexeme) {
		return lexemeExprs[lexeme]!.matchAsPrefix(this);
	}

	/// The string without the [lexeme] in the beginning and possible spaces after it.
	String afterLexeme(String lexeme) {
		return replaceRange(0, lexeme.length, '').trimLeft();
	}
}


/// A [List<Lexeme>] of the lexemes of the code in the [file],
/// and a [List<Object>] of the corresponding values for the variable ones.
Future<Tuple2<Queue<Lexeme>, Queue<Object>>> lexemes(File file) async {
	int lineNumber = 0;

	final lines = file.openRead().map(utf8.decode).transform(const LineSplitter()).map((line) {
		lineNumber++;
		return line.trimRight();
	});

	final lexemes = Queue<Lexeme>();
	final values = Queue<Object>();

	final indentations = [0];
	final brackets = Stack<Lexeme>();

	try {
		await for (String line in lines) {
			if (line.isEmpty) continue;

			// todo: or \
			if (brackets.isEmpty) {
				final indentationChange_ = line.indentationChange(indentations);
				
				if (indentationChange_ > 0) {
					indentations.add(indentations.last + indentationChange_);
				}

				if (indentationChange_ < 0) {
					indentations.removeRange(indentations.length + indentationChange_, indentations.length);
				}

				lexemes.add(Lexeme.indentation);
				values.add(indentations.length - 1);
				// lexemes.
			}

			line = line.trimLeft();

			do {
				// keywords

				if (line.startsWith(lexemeExprs[Lexeme.functionDeclaration]!)) {
					line = line.afterLexeme(constLexemes[Lexeme.functionDeclaration]!);
					lexemes.add(Lexeme.functionDeclaration);

					continue;
				}

				// parentheses
				// todo: remove code duplication

				final openingParenthesis = constLexemes[Lexeme.openingParenthesis]!;

				if (line.startsWith(openingParenthesis)) {
					line = line.afterLexeme(openingParenthesis);
					lexemes.add(Lexeme.openingParenthesis);
					brackets.push(Lexeme.openingParenthesis);

					continue;
				}

				final closingParenthesis = constLexemes[Lexeme.closingParenthesis]!;

				if (line.startsWith(closingParenthesis)) {
					final lastBracket = brackets.pop();
					if (lastBracket != Lexeme.openingParenthesis) {
						throw SyntaxError.wrongBracket(closingBrackets[lastBracket]!);
					}

					line = line.afterLexeme(closingParenthesis);
					lexemes.add(Lexeme.closingParenthesis);

					continue;
				}

				final openingSquareBracket = constLexemes[Lexeme.openingSquareBracket]!;

				if (line.startsWith(openingSquareBracket)) {
					line = line.afterLexeme(openingSquareBracket);
					lexemes.add(Lexeme.openingSquareBracket);
					brackets.push(Lexeme.openingSquareBracket);

					continue;
				}

				final closingSquareBracket = constLexemes[Lexeme.closingSquareBracket]!;

				if (line.startsWith(closingSquareBracket)) {
					final lastBracket = brackets.pop();
					if (lastBracket != Lexeme.openingSquareBracket) {
						throw SyntaxError.wrongBracket(closingBrackets[lastBracket]!);
					}

					line = line.afterLexeme(closingSquareBracket);
					lexemes.add(Lexeme.closingSquareBracket);

					continue;
				}

				final openingBrace = constLexemes[Lexeme.openingBrace]!;

				if (line.startsWith(openingBrace)) {
					line = line.afterLexeme(openingBrace);
					lexemes.add(Lexeme.openingBrace);
					brackets.push(Lexeme.openingBrace);

					continue;
				}

				final closingBrace = constLexemes[Lexeme.closingBrace]!;

				if (line.startsWith(closingBrace)) {
					final lastBracket = brackets.pop();
					if (lastBracket != Lexeme.openingBrace) {
						throw SyntaxError.wrongBracket(closingBrackets[lastBracket]!);
					}

					line = line.afterLexeme(closingBrace);
					lexemes.add(Lexeme.closingBrace);

					continue;
				}

				// number literals
				// todo: remove code duplication

				final binLiteralMatch = line.prefixVarLexemeMatch(Lexeme.binLiteral);

				if (binLiteralMatch != null) {
					final literal = binLiteralMatch.group(1)!;

					if (literal.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNumberLiteral('binary');
					}

					line = line.afterLexeme(binLiteralMatch.group(0)!);
					lexemes.add(Lexeme.binLiteral);
					values.add(literal.replaceAll(numDelimiter, ''));

					continue;
				}

				final octLiteralMatch = line.prefixVarLexemeMatch(Lexeme.octLiteral);

				if (octLiteralMatch != null) {
					final literal = octLiteralMatch.group(1)!;

					if (literal.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNumberLiteral('octal');
					}

					line = line.afterLexeme(octLiteralMatch.group(0)!);
					lexemes.add(Lexeme.octLiteral);
					values.add(literal.replaceAll(numDelimiter, ''));

					continue;
				}

				final hexLiteralMatch = line.prefixVarLexemeMatch(Lexeme.hexLiteral);

				if (hexLiteralMatch != null) {
					final literal = hexLiteralMatch.group(1)!;

					if (literal.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNumberLiteral('hexadecimal');
					}

					line = line.afterLexeme(hexLiteralMatch.group(0)!);
					lexemes.add(Lexeme.hexLiteral);
					values.add(literal.replaceAll(numDelimiter, ''));

					continue;
				}

				final floatLiteralMatch = line.prefixVarLexemeMatch(Lexeme.floatLiteral);

				if (floatLiteralMatch != null) {
					if (
						floatLiteralMatch.group(1)!.endsWith(numDelimiter) ||
						floatLiteralMatch.group(2)!.endsWith(numDelimiter)
					) {
						throw SyntaxError.invalidNumberLiteral('decimal');
					}

					final literal = floatLiteralMatch.group(0)!;
					line = line.afterLexeme(literal);
					lexemes.add(Lexeme.floatLiteral);
					values.add(literal.replaceAll(numDelimiter, ''));

					continue;
				}

				final decLiteral = line.prefixVarLexemeMatch(Lexeme.decLiteral)?.group(0);

				if (decLiteral != null) {
					if (decLiteral.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNumberLiteral('decimal');
					}

					line = line.afterLexeme(decLiteral);
					lexemes.add(Lexeme.decLiteral);
					values.add(decLiteral.replaceAll(numDelimiter, ''));

					continue;
				}

				// identifier

				final identifier = line.prefixVarLexemeMatch(Lexeme.identifier)?.group(0);

				if (identifier != null) {
					if (identifier.startsWith(lexemeExprs[Lexeme.decLiteral]!)) {
						throw SyntaxError.invalidIdentifier();
					}
	
					line = line.afterLexeme(identifier);
					lexemes.add(Lexeme.identifier);
					values.add(identifier);

					continue;
				}

				// unknown lexeme
				throw SyntaxError.unknownLexeme();

			}
			while (line.isNotEmpty);
		}
	}
	on CompilationError catch (error) {
		error.file = file;
		error.lineNumber = lineNumber;
		rethrow;
	}

	return Tuple2(lexemes, values);
}
