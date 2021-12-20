import 'dart:collection';

import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme, constLexemes, closingBrackets;
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

			final statement = Assignment(expr.value as String, value);

			if (lexemes.isNotEmpty) {
				throw SyntaxError.unexpectedLexeme(lexemes.first);
			}

			return statement;
		}

		throw SyntaxError.unexpectedLexeme(lexemes.first);
	}

	// if (first == Lexeme.ifKeyword) {
		
	// }

	throw SyntaxError.statementExpected(lineNum);
}

Object? expression(Queue<PositionedLexeme> lexemes) {
	Object? expr = operand(lexemes);

	if (expr == null) return null;

	while (lexemes.isNotEmpty && operators.contains(lexemes.first.lexeme)) {
		final operator = lexemes.removeFirst();
		final operand_ = operand(lexemes);

		if (operand_ == null) throw SyntaxError.operandExpected(operator.lineNum);
		// if (!operators.contains(posLexeme.lexeme)) {
		// 	throw SyntaxError.unexpectedLexeme(posLexeme);
		// }

		expr = TwoOperandExpression(expr!, operand_, operator.lexeme);
	}

	return expr;
}

Object? operand(Queue<PositionedLexeme> lexemes) {
	if (lexemes.isEmpty) return null;

	final posLexeme = lexemes.removeFirst();

	if (operands.contains(posLexeme.lexeme)) {
		if (posLexeme.lexeme == Lexeme.identifier && lexemes.first.lexeme == Lexeme.openingParenthesis) {
			final lastLexemeLineNum = lexemes.last.lineNum;
			lexemes.removeFirst();
			final args = Queue<Object>();

			while (true) {
				if (lexemes.isEmpty) {
					throw BracketError.closingExpected(Lexeme.closingParenthesis, lastLexemeLineNum);
				}

				if (lexemes.first.lexeme == Lexeme.closingParenthesis) {
					lexemes.removeFirst();
					return Call(posLexeme.value as String, args);
				}

				args.add(expression(lexemes)!);
				if (lexemes.first.lexeme == Lexeme.comma) lexemes.removeFirst();
			}
		}

		return posLexeme;
	}

	if (posLexeme.lexeme == Lexeme.openingParenthesis) {
		final lastOperandLineNum = lexemes.last.lineNum;
		final expr = expression(lexemes);

		if (lexemes.isEmpty) {
			throw BracketError.closingExpected(closingBrackets[posLexeme.lexeme]!, lastOperandLineNum);
		}

		lexemes.removeFirst();
		return expr;
	}

	if (unaryOperators.contains(posLexeme.lexeme)) {
		final operand_ = operand(lexemes);

		if (operand_ == null) throw SyntaxError.operandExpected(posLexeme.lineNum);

		return OneOperandExpression(operand_, posLexeme.lexeme);
	}

	throw SyntaxError.unexpectedLexeme(posLexeme);
}
