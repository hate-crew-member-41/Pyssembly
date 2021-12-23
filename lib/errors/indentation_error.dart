import 'compilation_error.dart';


class IndentationError extends CompilationError {
	// lexical analysis

	IndentationError.noMatch() :
		super("indentaion does not match");

	// syntax analysis
	
	IndentationError.indentedBlockExpected(int lineNum) :
		super("indented block expected", lineNum);
	
	IndentationError.unexpectedIndentedBlock(int lineNum) :
		super("unexpected indented block", lineNum);
}
