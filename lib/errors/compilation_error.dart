import 'dart:io';

import 'package:pyssembly/lexical_analysis/lexemes.dart';


class CompilationError extends Error {
	CompilationError(this.message);

	late final File file;
	late final int lineNumber;
	final String message;

	@override
	String toString() => '${runtimeType.toString()}: $message (${file.path}, line $lineNumber)';
}


class IndentationError extends CompilationError {
	// IndentationError.indentationExpected() : super("indentaion expected");

	// IndentationError.unexpectedIndentation() : super("unexpected indentaion");

	IndentationError.noMatch() : super("indentaion does not match");
}


class SyntaxError extends CompilationError {
	SyntaxError.wrongBracket(Lexeme expected) : super("wrong closing bracket, '${constLexemes[expected]}' expected");

	SyntaxError.invalidNumberLiteral(String system) : super("invalid $system literal");

	SyntaxError.invalidIdentifier() : super("identifier starts with a digit");

	SyntaxError.unknownLexeme() : super("unknown lexeme");
}
