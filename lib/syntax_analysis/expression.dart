import 'dart:collection';

import 'package:tuple/tuple.dart' show Tuple2;

import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme, constLexemes;

import 'package:pyssembly/errors/bracket_error.dart';
import 'package:pyssembly/errors/syntax_error.dart';

import 'grammar_rules.dart';


Object expression(Queue<Lexeme> lexemes, Queue<Object> values) {
	Object expr = operand(lexemes, values);

	while (lexemes.isNotEmpty && lexemes.first != Lexeme.closingParenthesis) {
		final lexeme = lexemes.removeFirst();

		if (!nonAssignmentOperators.contains(lexeme)) {
			throw SyntaxError.unexpectedLexeme(constLexemes[lexeme] ?? values.removeFirst() as String);
		}

		expr = Expression(expr, operand(lexemes, values), lexeme);
	}

	return expr;
}

Object operand(Queue<Lexeme> lexemes, Queue<Object> values) {
	if (lexemes.isEmpty) {
		throw SyntaxError.operandExpected();
	}

	final lexeme = lexemes.removeFirst();

	if (operands.contains(lexeme)) {
		return Tuple2(lexeme, values.removeFirst() as String);
	}

	if (lexeme == Lexeme.openingParenthesis) {
		final expr = expression(lexemes, values);
		lexemes.removeFirst();
		return expr;
	}

	if (unaryOperators.contains(lexeme)) {
		return OneOperandExpression(operand(lexemes, values), lexeme);
	}

	throw SyntaxError.unexpectedLexeme(constLexemes[lexeme] ?? values.removeFirst() as String);
}

// Object factor(Queue<Lexeme> lexemes, Queue<Object> values) {
// 	final lexeme = lexemes.removeFirst();

// 	if (operands.contains(lexeme)) return Tuple2(lexeme, values.removeFirst());

// 	if (lexeme == Lexeme.openingParenthesis) {
// 		final expr = expression(lexemes, values);

// 		if (lexemes.removeFirst() != Lexeme.closingParenthesis) {
// 			throw BracketError.closingExpected(Lexeme.closingParenthesis);
// 		}

// 		return expr;
// 	}

// 	if (unaryOperators.contains(lexeme)) {
// 		return OneOperandExpression(factor(lexemes, values), lexeme);
// 	}

// 	throw SyntaxError.unexpectedLexeme(lexeme);
// }


class Expression {
	final Object leftOperand;
	final Object rightOperand;
	final Lexeme operation;

	Expression(this.leftOperand, this.rightOperand, this.operation);
}

class OneOperandExpression {
	final Object operand;
	final Lexeme operation;

	OneOperandExpression(this.operand, this.operation);
}
