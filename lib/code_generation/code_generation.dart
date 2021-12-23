import 'dart:io' show File;

import 'package:pyssembly/syntax_analysis/statements.dart';

import 'code_parts.dart';


/// Generates the Assembly code of the abstract syntax [tree],
/// and writes it into the [file].
void writeCodeSection(List<Object> tree, File file) {
	writeHeadSection(file);
	writeDataSection(variables(tree), file);
	writeCodeSection(tree, file);
}

Set<String> variables(List<Object> tree) {
	final vars = <String>{};

	for (final statement in tree) {
		if (statement is Assignment) {
			vars.add(statement.variable);
		}
		else if (statement is CompoundStatement) {
			vars.addAll(variables(statement.body!));

			if (statement is If && statement.elseBlock != null) {
				vars.addAll(variables(statement.elseBlock!.body!));
			}
		}
	}

	return vars;
}
