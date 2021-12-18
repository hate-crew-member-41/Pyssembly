import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme;

import 'compilation_error.dart';


class SyntaxError extends CompilationError {
	SyntaxError.invalidNum(String system) : super("invalid $system literal");

	SyntaxError.invalidIdentifier() : super("identifier starts with a digit");

	SyntaxError.unterminatedStr() : super("unterminated string literal");

	SyntaxError.unknownLexeme() : super("unknown lexeme");

	SyntaxError.operandExpected() : super("operand expected");

	SyntaxError.unexpectedLexeme(String lexeme) : super('unexpected lexeme "$lexeme"');

	SyntaxError.statementExpected() : super("statement expected");
}
