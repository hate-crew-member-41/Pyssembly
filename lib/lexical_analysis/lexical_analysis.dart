import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:stack/stack.dart';
import 'package:tuple/tuple.dart';

import 'package:pyssembly/errors/bracket_error.dart';
import 'package:pyssembly/errors/compilation_error.dart';
import 'package:pyssembly/errors/indentation_error.dart';
import 'package:pyssembly/errors/syntax_error.dart';

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

	/// The bracket of the [opening] bracket's family at the beginning of the string.
	Lexeme? handleBracket(Lexeme opening, Stack<Lexeme> brackets, Queue<Lexeme> lexemes) {
		if (startsWith(constLexemes[opening]!)) {
			brackets.push(opening);
			lexemes.add(opening);
			return opening;
		}

		final closing = closingBrackets[opening]!;

		if (startsWith(constLexemes[closing]!)) {
			if (brackets.isEmpty) {
				throw BracketError.unexpectedClosing(closing);
			}

			final lastOpening = brackets.pop();

			if (lastOpening != opening) {
				throw BracketError.wrongClosing(closingBrackets[lastOpening]!);
			}

			lexemes.add(closing);
			return closing;
		}
	}

	/// The [Match?] of the variable [lexeme] at the beginning of the string.
	Match? varLexemeMatch(Lexeme lexeme) {
		return lexemeExprs[lexeme]!.matchAsPrefix(this);
	}

	/// The string without the [lexeme] at the beginning and possible spaces after it.
	String afterLexeme(String lexeme) {
		return replaceRange(0, lexeme.length, '').trimLeft();
	}
}

extension Indentations on List<int> {
	int get level => length - 1;
}


/// A [Queue<Lexeme>] of the lexemes of the code in the [file],
/// and a [Queue<Object>] of the corresponding values for the variable ones.
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

			// todo: or the previous line was ended with '\'
			if (brackets.isEmpty) {
				final indentationChange_ = line.indentationChange(indentations);
				
				if (indentationChange_ > 0) {
					indentations.add(indentations.last + indentationChange_);
				}

				if (indentationChange_ < 0) {
					indentations.removeRange(indentations.length + indentationChange_, indentations.length);
				}

				lexemes.add(Lexeme.indentation);
				values.add(indentations.level);
			}

			line = line.trimLeft();

			// todo: think about the order to make each iteration the cheapest possible
			handleLexeme: while (line.isNotEmpty) {
				// next-char-dependent constant lexemes and bool literal

				for (final lexeme in nextCharDependentConstLexemes) {
					if (line.startsWith(lexemeExprs[lexeme]!)) {
						lexemes.add(lexeme);
						line = line.afterLexeme(constLexemes[lexeme]!);
						continue handleLexeme;
					}
				}

				final boolLiteral = line.varLexemeMatch(Lexeme.boolLiteral)?.group(0);

				if (boolLiteral != null) {
					lexemes.add(Lexeme.boolLiteral);
					values.add(boolLiteral == trueLiteral);
					line = line.afterLexeme(boolLiteral);
					continue;
				}

				// identifier

				final identifier = line.varLexemeMatch(Lexeme.identifier)?.group(0);

				if (identifier != null) {
					if (identifier.startsWith(lexemeExprs[Lexeme.decLiteral]!)) {
						throw SyntaxError.invalidIdentifier();
					}
	
					lexemes.add(Lexeme.identifier);
					line = line.afterLexeme(identifier);
					values.add(identifier);
					continue;
				}

				// brackets

				for (final openingBracket in closingBrackets.keys) {
					final bracket = line.handleBracket(openingBracket, brackets, lexemes);

					if (bracket != null) {
						line = line.afterLexeme(constLexemes[bracket]!);
						continue handleLexeme;
					}
				}

				// symbols

				final comma = constLexemes[Lexeme.comma]!;

				if (line.startsWith(comma)) {
					lexemes.add(Lexeme.comma);
					line = line.afterLexeme(comma);
					continue;
				}

				final colon = constLexemes[Lexeme.colon]!;

				if (line.startsWith(colon)) {
					lexemes.add(Lexeme.colon);
					line = line.afterLexeme(colon);
					continue;
				}

				if (line.startsWith(statementDelimiter)) {
					line = line.afterLexeme(statementDelimiter);
					if (line.isEmpty) continue;

					// treat what follows as if written on a new line
					lexemes.add(Lexeme.indentation);
					values.add(indentations.level);
				}

				// number literals

				final binLiteralMatch = line.varLexemeMatch(Lexeme.binLiteral);

				if (binLiteralMatch != null) {
					final literal = binLiteralMatch.group(1)!;

					if (literal.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNum('binary');
					}

					lexemes.add(Lexeme.binLiteral);
					values.add(literal.replaceAll(numDelimiter, ''));
					line = line.afterLexeme(binLiteralMatch.group(0)!);
					continue;
				}

				final octLiteralMatch = line.varLexemeMatch(Lexeme.octLiteral);

				if (octLiteralMatch != null) {
					final literal = octLiteralMatch.group(1)!;

					if (literal.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNum('octal');
					}

					lexemes.add(Lexeme.octLiteral);
					values.add(literal.replaceAll(numDelimiter, ''));
					line = line.afterLexeme(octLiteralMatch.group(0)!);
					continue;
				}

				final hexLiteralMatch = line.varLexemeMatch(Lexeme.hexLiteral);

				if (hexLiteralMatch != null) {
					final literal = hexLiteralMatch.group(1)!;

					if (literal.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNum('hexadecimal');
					}

					lexemes.add(Lexeme.hexLiteral);
					values.add(literal.replaceAll(numDelimiter, '').toLowerCase());
					line = line.afterLexeme(hexLiteralMatch.group(0)!);
					continue;
				}

				final floatLiteralMatch = line.varLexemeMatch(Lexeme.floatLiteral);

				if (floatLiteralMatch != null) {
					if (
						floatLiteralMatch.group(1)!.endsWith(numDelimiter) ||
						floatLiteralMatch.group(2)!.endsWith(numDelimiter)
					) {
						throw SyntaxError.invalidNum('decimal');
					}

					final literal = floatLiteralMatch.group(0)!;
					lexemes.add(Lexeme.floatLiteral);
					values.add(literal.replaceAll(numDelimiter, ''));
					line = line.afterLexeme(literal);
					continue;
				}

				final decLiteral = line.varLexemeMatch(Lexeme.decLiteral)?.group(0);

				if (decLiteral != null) {
					if (decLiteral.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNum('decimal');
					}

					lexemes.add(Lexeme.decLiteral);
					values.add(decLiteral.replaceAll(numDelimiter, ''));
					line = line.afterLexeme(decLiteral);
					continue;
				}

				// string literal

				final strLiteralMatch = line.varLexemeMatch(Lexeme.strLiteral);

				if (strLiteralMatch != null) {
					// the literal uses: single quotes / double quotes / triple quotes of a kind
					var value = strLiteralMatch.group(3) ?? strLiteralMatch.group(5) ?? strLiteralMatch.group(2)!;

					if (value.endsWith(r'\')) {
						// the closing quote is escaped
						throw SyntaxError.unterminatedStr();
					}

					for (final char in ["'", '"', r'\']) {
						value = value.replaceAll('\\$char', char);
					}

					if (lexemes.last != Lexeme.strLiteral) {
						lexemes.add(Lexeme.strLiteral);
						values.add(value);
					}
					else values.add((values.removeLast() as String) + value);

					line = line.afterLexeme(strLiteralMatch.group(0)!);
					continue;
				}

				// todo: handle recognizable invalid lexemes for better error messages

				// unknown lexeme
				throw SyntaxError.unknownLexeme();

			}
		}

		if (brackets.isNotEmpty) {
			throw BracketError.closingExpected(closingBrackets[brackets.pop()]!);
		}
	}
	on CompilationError catch (error) {
		error.file = file;
		error.lineNumber = lineNumber;
		rethrow;
	}

	return Tuple2(lexemes, values);
}
