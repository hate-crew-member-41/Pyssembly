import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme, constLexemes;
import 'compilation_error.dart' show CompilationError;


class BracketError extends CompilationError {
	BracketError.closingExpected(Lexeme expected) : super("closing bracket '${constLexemes[expected]}' expected");

	BracketError.unexpectedClosing(Lexeme bracket) : super("unexpected closing bracket '${constLexemes[bracket]}'");

	BracketError.wrongClosing(Lexeme expected) : super("wrong closing bracket, '${constLexemes[expected]}' expected");
}
