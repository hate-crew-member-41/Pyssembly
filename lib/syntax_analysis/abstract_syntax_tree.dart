import 'dart:collection';

import 'package:tuple/tuple.dart' show Tuple2;

import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme, constLexemes;


/// The abstract syntax tree built from the [lexemes].
abstractSyntaxTree(Queue<Lexeme> lexemes, Queue<Object> values) {
	final statements_ = statements(lexemes, values);
}

List<Object> statements(Queue<Lexeme> lexemes, Queue<Object> values, [int blockLevel = 0]) {
	final statements_ = <Object>[];

	while (lexemes.isNotEmpty) {
		final statementLevel = values.first as int;

		if (statementLevel == blockLevel) {
			lexemes.removeFirst();
			values.removeFirst();

			// todo: lists?
			final statement = Tuple2(<Lexeme>[], <Object>[]);

			while (lexemes.isNotEmpty && lexemes.first != Lexeme.indentation) {
				final lexeme = lexemes.removeFirst();
				statement.item1.add(lexeme);

				if (!constLexemes.containsKey(lexeme)) {
					statement.item2.add(values.removeFirst());
				}
			}

			statements_.add(statement);
		}
		else if (statementLevel > blockLevel) {
			statements_.add(statements(lexemes, values, statementLevel));
		}
		else return statements_;
	}

	return statements_;
}
