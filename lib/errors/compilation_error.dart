class CompilationError extends Error {
	final String message;
	late final int lineNum;

	CompilationError(this.message, [int? lineNum]) {
		if (lineNum != null) this.lineNum = lineNum;
	}

	@override
	String toString() => '\t${runtimeType.toString()}: $message (line $lineNum)';
}
