import 'dart:collection';

import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme, closingBrackets;
import 'package:pyssembly/lexical_analysis/positioned_lexeme.dart';

import 'package:pyssembly/errors/syntax_error.dart';
import 'package:pyssembly/errors/bracket_error.dart';

import 'expression.dart';
import 'statements.dart';


/// The abstract syntax tree built from the [lexemes].
// todo: specify the type
abstractSyntaxTree(Queue<PositionedLexeme> lexemes) {
	final statements_ = statementBlocks(lexemes);
}

List<Object> statementBlocks(Queue<PositionedLexeme> lexemes, [int blockLevel = 0]) {
	final statements = <Object>[];

	while (lexemes.isNotEmpty) {
		final statementLevel = lexemes.first.value as int;

		if (statementLevel == blockLevel) {
			lexemes.removeFirst();

			final statementLexemes = Queue<PositionedLexeme>();

			while (lexemes.isNotEmpty && lexemes.first.lexeme != Lexeme.indentation) {
				statementLexemes.add(lexemes.removeFirst());
			}

			statements.add(statement(statementLexemes));
		}
		else if (statementLevel > blockLevel) {
			statements.add(statementBlocks(lexemes, statementLevel));
		}
		else return statements;
	}

	return statements;
}

// todo; specify the type
statement(Queue<PositionedLexeme> lexemes) {
	final first = lexemes.removeFirst();

	if (first.lexeme == Lexeme.identifier) {
		final second = lexemes.removeFirst();

		if (assignmentOperators.contains(second.lexeme)) {
			// todo: add compound assignments
			final statement = Assignment(first.value as String, expression(lexemes, second.lineNum));

			if (lexemes.isNotEmpty) {
				throw SyntaxError.unexpectedLexeme(lexemes.first);
			}

			return statement;
		}
	}

	// if (first == Lexeme.ifKeyword) {
		
	// }

	throw SyntaxError.statementExpected(first.lineNum);
}

Object expression(Queue<PositionedLexeme> lexemes, lineNum) {
	Object expr = operand(lexemes, lineNum);

	while (lexemes.isNotEmpty && operators.contains(lexemes.first.lexeme)) {
		final lexeme = lexemes.removeFirst();

		if (!operators.contains(lexeme.lexeme)) {
			throw SyntaxError.unexpectedLexeme(lexeme);
		}

		expr = Expression(expr, operand(lexemes, lexeme.lineNum), lexeme.lexeme);
	}

	return expr;
}

Object operand(Queue<PositionedLexeme> lexemes, int lineNum) {
	if (lexemes.isEmpty) {
		throw SyntaxError.operandExpected(lineNum);
	}

	final lexeme = lexemes.removeFirst();

	if (operands.contains(lexeme.lexeme)) return lexeme;

	if (lexeme.lexeme == Lexeme.openingParenthesis) {
		final lastOperandLineNum = lexemes.last.lineNum;
		final expr = expression(lexemes, lexeme.lineNum);

		if (lexemes.isEmpty) {
			throw BracketError.closingExpected(closingBrackets[lexeme.lexeme]!, lastOperandLineNum);
		}

		lexemes.removeFirst();
		return expr;
	}

	if (unaryOperators.contains(lexeme.lexeme)) {
		return OneOperandExpression(operand(lexemes, lexeme.lineNum), lexeme);
	}

	throw SyntaxError.unexpectedLexeme(lexeme);
}
