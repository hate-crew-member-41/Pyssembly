import 'dart:io';


class CompilationError extends Error {
	CompilationError(this.message);

	late final File file;
	late final int lineNumber;
	final String message;

	@override
	String toString() => '${runtimeType.toString()}: $message (${file.path}, line $lineNumber)';
}
