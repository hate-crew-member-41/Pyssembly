import 'compilation_error.dart';


class SyntaxError extends CompilationError {
	SyntaxError.invalidNum(String system) : super("invalid $system literal");

	SyntaxError.invalidIdentifier() : super("identifier starts with a digit");

	SyntaxError.unterminatedStr() : super("unterminated string literal");

	SyntaxError.unknownLexeme() : super("unknown lexeme");
}
