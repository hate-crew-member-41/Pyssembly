import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:stack/stack.dart';

import 'package:pyssembly/errors/bracket_error.dart';
import 'package:pyssembly/errors/compilation_error.dart';
import 'package:pyssembly/errors/indentation_error.dart';
import 'package:pyssembly/errors/syntax_error.dart';

import 'lexemes.dart';
import 'positioned_lexeme.dart';


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
	Lexeme? handleBracket(Lexeme opening, Stack<Lexeme> brackets) {
		if (startsWith(constLexemes[opening]!)) {
			brackets.push(opening);
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

			return closing;
		}
	}

	/// The [Match?] of the variable [lexeme] at the beginning of the string.
	Match? varLexemeMatch(Lexeme lexeme) {
		return lexemeExprs[lexeme]!.matchAsPrefix(this);
	}

	/// The number literal without delimiters.
	String get withoutNumDelimiters => replaceAll(numDelimiter, '');

	/// The string without the [lexeme] at the beginning and possible spaces after it.
	String afterLexeme(String lexeme) {
		return substring(lexeme.length).trimLeft();
	}
}

extension on Queue<PositionedLexeme> {
	void addLexeme(int lineNum, Lexeme lexeme, [Object? value]) {
		add(PositionedLexeme(lineNum, lexeme, value));
	}
}

extension on List<int> {
	int get level => length - 1;
}


/// A [Queue<Lexeme>] of the lexemes of the code in the [file],
/// and a [Queue<Object>] of values of the variable ones.
Future<Queue<PositionedLexeme>> lexemes(File file) async {
	int lineNum = 0;

	final lines = file.openRead().map(utf8.decode).transform(const LineSplitter()).map((line) {
		lineNum++;
		return line.trimRight();
	});

	final lexemes = Queue<PositionedLexeme>();

	final indentations = [0];
	final brackets = Stack<Lexeme>();

	await for (String line in lines) {
		if (line.isEmpty) continue;

		// todo: also consider '\' and multiline string literals
		if (brackets.isEmpty) {
			final indentationChange_ = line.indentationChange(indentations);
			
			if (indentationChange_ > 0) {
				indentations.add(indentations.last + indentationChange_);
			}

			if (indentationChange_ < 0) {
				indentations.removeRange(indentations.length + indentationChange_, indentations.length);
			}

			lexemes.addLexeme(lineNum, Lexeme.indentation, indentations.level);
		}

		line = line.trimLeft();

		try {
			// todo: think about the order to make each iteration the cheapest possible
			handleLexeme: while (line.isNotEmpty) {
				// next-char-dependent constant lexemes and bool literal

				for (final lexeme in nextCharDependentConstLexemes) {
					if (line.startsWith(lexemeExprs[lexeme]!)) {
						lexemes.addLexeme(lineNum, lexeme);
						line = line.afterLexeme(constLexemes[lexeme]!);
						continue handleLexeme;
					}
				}

				final boolLiteral = line.varLexemeMatch(Lexeme.boolLiteral)?.group(0);

				if (boolLiteral != null) {
					lexemes.addLexeme(lineNum, Lexeme.boolLiteral, boolLiteral == trueLiteral);
					line = line.afterLexeme(boolLiteral);
					continue;
				}

				// identifier

				final identifier = line.varLexemeMatch(Lexeme.identifier)?.group(0);

				if (identifier != null) {
					if (identifier.startsWith(lexemeExprs[Lexeme.decLiteral]!)) {
						throw SyntaxError.invalidIdentifier();
					}

					lexemes.addLexeme(lineNum, Lexeme.identifier, identifier);
					line = line.afterLexeme(identifier);
					continue;
				}

				// brackets

				for (final openingBracket in closingBrackets.keys) {
					final bracket = line.handleBracket(openingBracket, brackets);

					if (bracket != null) {
						lexemes.addLexeme(lineNum, bracket);
						line = line.afterLexeme(constLexemes[bracket]!);
						continue handleLexeme;
					}
				}

				// pure next-char-independent constant lexemes

				for (final lexeme in pureNextCharIndependentConstLexemes) {
					final lexemeString = constLexemes[lexeme]!;

					if (line.startsWith(lexemeString)) {
						lexemes.addLexeme(lineNum, lexeme);
						line = line.afterLexeme(lexemeString);
						continue handleLexeme;
					}
				}

				// number literals

				final binLiteralMatch = line.varLexemeMatch(Lexeme.binLiteral);

				if (binLiteralMatch != null) {
					final literal = binLiteralMatch.group(1)!;

					if (literal.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNum('binary');
					}

					lexemes.addLexeme(lineNum, Lexeme.binLiteral, literal.withoutNumDelimiters);
					line = line.afterLexeme(binLiteralMatch.group(0)!);
					continue;
				}

				final octLiteralMatch = line.varLexemeMatch(Lexeme.octLiteral);

				if (octLiteralMatch != null) {
					final literal = octLiteralMatch.group(1)!;

					if (literal.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNum('octal');
					}

					lexemes.addLexeme(lineNum, Lexeme.octLiteral, literal.withoutNumDelimiters);
					line = line.afterLexeme(octLiteralMatch.group(0)!);
					continue;
				}

				final hexLiteralMatch = line.varLexemeMatch(Lexeme.hexLiteral);

				if (hexLiteralMatch != null) {
					final literal = hexLiteralMatch.group(1)!;

					if (literal.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNum('hexadecimal');
					}

					lexemes.addLexeme(lineNum, Lexeme.hexLiteral, literal.withoutNumDelimiters.toLowerCase());
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
					lexemes.addLexeme(lineNum, Lexeme.floatLiteral, literal.withoutNumDelimiters);
					line = line.afterLexeme(literal);
					continue;
				}

				final decLiteral = line.varLexemeMatch(Lexeme.decLiteral)?.group(0);

				if (decLiteral != null) {
					if (decLiteral.endsWith(numDelimiter)) {
						throw SyntaxError.invalidNum('decimal');
					}

					lexemes.addLexeme(lineNum, Lexeme.decLiteral, decLiteral.withoutNumDelimiters);
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

					if (lexemes.last.lexeme == Lexeme.strLiteral) {
						value = (lexemes.removeLast().value as String) + value;
					}

					lexemes.addLexeme(lineNum, Lexeme.strLiteral, value);
					line = line.afterLexeme(strLiteralMatch.group(0)!);
					continue;
				}

				// comment

				if (line.startsWith(commentSymbol)) {
					if (lexemes.last.lexeme == Lexeme.indentation) {
						lexemes.removeLast();
					}

					break;
				}

				// semicolon

				if (line.startsWith(statementDelimiter)) {
					line = line.afterLexeme(statementDelimiter);
					if (line.isEmpty) break;

					// treat what follows as if written on a new line
					lexemes.addLexeme(lineNum, Lexeme.indentation, indentations.level);
				}

				// todo: handle recognizable invalid lexemes e.g. tabs, for better error messages

				throw SyntaxError.unknownLexeme();

			}
		}
		on CompilationError catch (error) {
			error.lineNum = lineNum;
			rethrow;
		}
	}

	return lexemes;
}
