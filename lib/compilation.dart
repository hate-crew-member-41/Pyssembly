import 'dart:io';

import 'errors/compilation_error.dart' show CompilationError;
import 'lexical_analysis/lexical_analysis.dart' show lexemes;
import 'syntax_analysis/syntax_tree.dart' show syntaxTree;


/// Compile the code in the Python [file] to Assembly,
/// and write it into a different file with the same name.
Future<void> compile(File file) async {
	try {
		final lexemesValues = await lexemes(file);
		var tree = syntaxTree(lexemesValues.item1, lexemesValues.item2);
	}
	on CompilationError catch (error) {
		print(error);
	}
}
