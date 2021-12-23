import 'dart:collection' show Queue;

import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme, constLexemes;
import 'package:pyssembly/lexical_analysis/positioned_lexeme.dart';

import 'package:pyssembly/errors/bracket_error.dart';
import 'package:pyssembly/errors/indentation_error.dart';
import 'package:pyssembly/errors/syntax_error.dart';

import 'expression.dart';
import 'statements.dart';


/// The abstract syntax tree built from the [lexemes].
List<Object> abstractSyntaxTree(Queue<PositionedLexeme> lexemes) {
	final statements_ = statementBlocks(lexemes);
	assignBlocks(statements_);
	assignElseStatements(statements_);

	return statements_;
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

Object statement(Queue<PositionedLexeme> lexemes) {
	final lineNum = lexemes.first.lineNum;
	Object? expr = expression(lexemes);

	if (expr != null) {
		if (lexemes.isEmpty) return expr;

		if (assignmentOperators.contains(lexemes.first.lexeme)) {
			if (expr is! PositionedLexeme || expr.lexeme != Lexeme.identifier) {
				throw SyntaxError.invalidAssignmentTarget(lineNum);
			}

			final assignmentOperator = lexemes.removeFirst();
			var value = expression(lexemes);

			if (value == null) throw SyntaxError.exprExpected(assignmentOperator.lineNum);

			if (assignmentOperator.lexeme != Lexeme.assignmentOperator) {
				final compoundAssignment = constLexemes[assignmentOperator.lexeme]!;
				final assignmentLength = constLexemes[Lexeme.assignmentOperator]!.length;
				final operatorCode = compoundAssignment.substring(0, compoundAssignment.length - assignmentLength);

				final operation = constLexemes.entries.firstWhere((lexeme) => lexeme.value == operatorCode).key;
				value = TwoOperandExpression(expr, value, operation);
			}

			final statement = Assignment(expr.value as String, value, lineNum);

			if (lexemes.isNotEmpty) {
				throw SyntaxError.unexpectedLexeme(lexemes.first);
			}

			return statement;
		}

		throw SyntaxError.unexpectedLexeme(lexemes.first);
	}

	// todo: reduce code duplication along the following statements

	if (lexemes.first.lexeme == Lexeme.ifKeyword) {
		final lastOperandLineNum = lexemes.last.lineNum;
		lexemes.removeFirst();
		final condition = expression(lexemes);

		if (condition == null) throw SyntaxError.exprExpected(lineNum);
		if (lexemes.isEmpty || lexemes.first.lexeme != Lexeme.colon) {
			throw SyntaxError.colonExpected(lastOperandLineNum);
		}

		lexemes.removeFirst();
		List<Object>? body;

		if (lexemes.isNotEmpty) {
			if (invalidInlineBodyFirstLexemes.contains(lexemes.first.lexeme)) {
				throw SyntaxError.invalidInlineBody(lexemes.first.lineNum);
			}

			body = [statement(lexemes)];
		}

		return If(condition, body, lastOperandLineNum);
	}

	if (lexemes.first.lexeme == Lexeme.elseKeyword) {
		final lineNum = lexemes.removeFirst().lineNum;

		if (lexemes.isEmpty || lexemes.first.lexeme != Lexeme.colon) {
			throw SyntaxError.colonExpected(lineNum);
		}

		lexemes.removeFirst();
		List<Object>? body;

		if (lexemes.isNotEmpty) {
			if (invalidInlineBodyFirstLexemes.contains(lexemes.first.lexeme)) {
				throw SyntaxError.invalidInlineBody(lexemes.first.lineNum);
			}

			body = [statement(lexemes)];
		}

		return Else(body, lineNum);
	}

	throw SyntaxError.statementExpected(lineNum);
}

Object? expression(Queue<PositionedLexeme> lexemes) {
	Object? expr = operand(lexemes);

	if (expr == null) return null;

	while (lexemes.isNotEmpty && operators.contains(lexemes.first.lexeme)) {
		final operator = lexemes.removeFirst();
		final operand_ = operand(lexemes);

		if (operand_ == null) throw SyntaxError.operandExpected(operator.lineNum);

		expr = TwoOperandExpression(expr!, operand_, operator.lexeme);
	}

	return expr;
}

Object? operand(Queue<PositionedLexeme> lexemes) {
	if (lexemes.isEmpty) return null;

	if (operands.contains(lexemes.first.lexeme)) {
		final operand = lexemes.removeFirst();

		if (
			operand.lexeme == Lexeme.identifier &&
			lexemes.isNotEmpty &&
			lexemes.first.lexeme == Lexeme.openingParenthesis
		) {
			final lastLexemeLineNum = lexemes.last.lineNum;
			lexemes.removeFirst();
			final args = Queue<Object>();

			while (true) {
				if (lexemes.isEmpty) {
					throw BracketError.closingExpected(Lexeme.closingParenthesis, lastLexemeLineNum);
				}

				if (lexemes.first.lexeme == Lexeme.closingParenthesis) {
					lexemes.removeFirst();
					return Call(operand.value as String, args);
				}

				args.add(expression(lexemes)!);
				if (lexemes.first.lexeme == Lexeme.comma) lexemes.removeFirst();
			}
		}

		return operand;
	}

	if (lexemes.first.lexeme == Lexeme.openingParenthesis) {
		int openingLineNum = lexemes.removeFirst().lineNum;
		final expr = expression(lexemes);

		if (expr == null) throw SyntaxError.exprExpected(openingLineNum);

		if (lexemes.isEmpty) {
			throw BracketError.closingExpected(Lexeme.closingParenthesis, openingLineNum);
		}

		lexemes.removeFirst();
		return expr;
	}

	if (unaryOperators.contains(lexemes.first.lexeme)) {
		final operator = lexemes.removeFirst();
		final operand_ = operand(lexemes);

		if (operand_ == null) throw SyntaxError.operandExpected(operator.lineNum);

		return OneOperandExpression(operand_, operator.lexeme);
	}
}

void assignBlocks(List<Object> statements) {
	for (int index = 0; index < statements.length; index++) {
		final statement = statements[index];
		final blockFollows = index < statements.length - 1 && statements[index + 1] is List;

		if (statement is CompoundStatement && statement.body == null) {
			if (blockFollows) {
				statement.body = statements.removeAt(index + 1) as List<Object>;
				assignBlocks(statement.body as List<Object>);
				continue;
			}

			throw IndentationError.indentedBlockExpected(statement.lineNum);
		}

		if (blockFollows) {
			throw IndentationError.unexpectedIndentedBlock((statement as Statement).lineNum);
		}
	}
}

void assignElseStatements(List<Object> statements) {
	If? ifStatement;

	for (int index = 0; index < statements.length; index++) {
		final statement = statements[index];

		if (statement is CompoundStatement) assignElseStatements(statement.body!);

		if (statement is If) ifStatement = statement;

		else if (statement is Else) {
			if (ifStatement == null) {
				throw SyntaxError.unexpectedElse(statement.lineNum);
			}

			ifStatement.elseBlock = statements.removeAt(index) as Else;
			ifStatement = null;
		}
	}
}
