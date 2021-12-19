import 'package:pyssembly/lexical_analysis/positioned_lexeme.dart';
import 'compilation_error.dart';


class SyntaxError extends CompilationError {
	// lexical-analysis errors

	SyntaxError.invalidNum(String system) :
		super("invalid $system literal");

	SyntaxError.invalidIdentifier() :
		super("identifier starts with a digit");

	SyntaxError.unterminatedStr() :
		super("unterminated string literal");

	SyntaxError.unknownLexeme() :
		super("unknown lexeme");

	// syntax-analysis errors

	SyntaxError.operandExpected(int lineNum) :
		super("operand expected", lineNum);

	SyntaxError.unexpectedLexeme(PositionedLexeme lexeme) :
		super('unexpected lexeme "$lexeme"', lexeme.lineNum);

	SyntaxError.statementExpected(int lineNum) :
		super("statement expected", lineNum);
}
