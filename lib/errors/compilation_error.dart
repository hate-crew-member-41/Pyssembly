import 'dart:io';


class CompilationError extends Error {
	CompilationError(this.message);

	// todo: remove default values and make the fields private, rewrite the error mechanism
	File file = File('{default}');
	int lineNumber = 0;
	final String message;

	@override
	String toString() => '${runtimeType.toString()}: $message (${file.path}, line $lineNumber)';
}
