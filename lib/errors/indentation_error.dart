import 'compilation_error.dart';


class IndentationError extends CompilationError {
	// IndentationError.indentationExpected() : super("indentaion expected");

	// IndentationError.unexpectedIndentation() : super("unexpected indentaion");

	IndentationError.noMatch() : super("indentaion does not match");
}
