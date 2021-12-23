import 'dart:io' show File;

import 'errors/compilation_error.dart' show CompilationError;
import 'lexical_analysis/lexical_analysis.dart' show lexemes;
import 'syntax_analysis/abstract_syntax_tree.dart' show abstractSyntaxTree;
import 'code_generation/code_generation.dart' show writeCode;


/// Compiles the code in the Python [file],
/// and writes it into a different file with the same name.
Future<void> compile(File file) async {
	final compilationWatch = Stopwatch()..start();

	try {
		final watch = Stopwatch()..start();
		final lexemes_ = await lexemes(file);

		print("\tlexical analysis (${watch.elapsedMilliseconds} ms): ${lexemes_.length} lexemes");

		watch.reset();
		final tree = abstractSyntaxTree(lexemes_);
		print("\tsyntax analysis (${watch.elapsedMilliseconds} ms)");

		watch.reset();
		writeCode(tree, file);
		print("\tcode generation (${watch.elapsedMilliseconds} ms)");
	}
	on CompilationError catch (error) {
		print(error);
	}
	finally {
		compilationWatch.stop();
		print("\ttotal compilation time: ${compilationWatch.elapsedMilliseconds} ms");
	}
}
