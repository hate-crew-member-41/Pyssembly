import 'compilation_error.dart';


class SyntaxError extends CompilationError {
	SyntaxError.invalidNumberLiteral(String system) : super("invalid $system literal");

	SyntaxError.invalidIdentifier() : super("identifier starts with a digit");

	SyntaxError.unknownLexeme() : super("unknown lexeme");
}
