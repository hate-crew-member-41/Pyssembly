import 'dart:collection';

import 'package:pyssembly/errors/bracket_error.dart';
import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme, closingBrackets;
import 'package:pyssembly/lexical_analysis/positioned_lexeme.dart';

import 'package:pyssembly/errors/syntax_error.dart';

import 'grammar_rules.dart';


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


class Expression {
	final Object leftOperand;
	final Object rightOperand;
	final Lexeme operation;

	Expression(this.leftOperand, this.rightOperand, this.operation);
}


class OneOperandExpression {
	final Object operand;
	final PositionedLexeme operation;

	OneOperandExpression(this.operand, this.operation);
}
