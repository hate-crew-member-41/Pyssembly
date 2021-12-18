import 'dart:collection';

import 'package:tuple/tuple.dart' show Tuple2;

import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme, constLexemes;

import 'package:pyssembly/errors/syntax_error.dart';

import 'grammar_rules.dart';
import 'expression.dart';
import 'statements.dart';


/// The abstract syntax tree built from the [lexemes].
// todo: specify the type
abstractSyntaxTree(Queue<Lexeme> lexemes, Queue<Object> values) {
	final statements_ = statementBlocks(lexemes, values);
}

List<Object> statementBlocks(Queue<Lexeme> lexemes, Queue<Object> values, [int blockLevel = 0]) {
	final statements = <Object>[];

	while (lexemes.isNotEmpty) {
		final statementLevel = values.first as int;

		if (statementLevel == blockLevel) {
			lexemes.removeFirst();
			values.removeFirst();

			final statementLexemes = Queue<Lexeme>();
			final statementValues = Queue<Object>();

			while (lexemes.isNotEmpty && lexemes.first != Lexeme.indentation) {
				final lexeme = lexemes.removeFirst();
				statementLexemes.add(lexeme);

				if (!constLexemes.containsKey(lexeme)) {
					statementValues.add(values.removeFirst());
				}
			}

			statements.add(statement(statementLexemes, statementValues));
		}
		else if (statementLevel > blockLevel) {
			statements.add(statementBlocks(lexemes, values, statementLevel));
		}
		else return statements;
	}

	return statements;
}

// todo; specify the type
statement(Queue<Lexeme> lexemes, Queue<Object> values) {
	final first = lexemes.removeFirst();

	if (first == Lexeme.identifier) {
		final second = lexemes.removeFirst();

		if (assignmentOperators.contains(second)) {
			// todo: add compound assignments and expressions
			return Assignment(values.removeFirst() as String, expression(lexemes, values));
		}
	}

	if (first == Lexeme.ifKeyword) {

	}

	throw SyntaxError.statementExpected();
}
