import 'dart:collection';

import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme;


class Call {
	final String identifier;
	final Queue<Object> arguments;

	Call(this.identifier, this.arguments);
}


class TwoOperandExpression {
	final Object leftOperand;
	final Object rightOperand;
	final Lexeme operation;

	TwoOperandExpression(this.leftOperand, this.rightOperand, this.operation);
}


class OneOperandExpression {
	final Object operand;
	final Object operation;

	OneOperandExpression(this.operand, this.operation);
}


const assignmentOperators = {
	Lexeme.assignmentOperator,

	// arithmetical compound assignment operators
	Lexeme.addAssignmentOperator,
	Lexeme.subAssignmentOperator,
	Lexeme.mulAssignmentOperator,
	Lexeme.divAssignmentOperator,
	Lexeme.intDivAssignmentOperator,
	Lexeme.modAssignmentOperator,
	Lexeme.raiseAssignmentOperator,

	// bitwise compound assignment opperators
	Lexeme.bitwiseAndAssignmentOperator,
	Lexeme.bitwiseOrAssignmentOperator,
	Lexeme.bitwiseXOrAssignmentOperator,
	Lexeme.bitwiseLeftShiftAssignmentOperator,
	Lexeme.bitwiseRightShiftAssignmentOperator
};

const operators = {
	// arithmetical operators
	Lexeme.addOperator,
	Lexeme.subOperator,
	Lexeme.mulOperator,
	Lexeme.divOperator,
	Lexeme.intDivOperator,
	Lexeme.modOperator,
	Lexeme.raiseOperator,

	// bitwise opperators
	Lexeme.bitwiseAndOperator,
	Lexeme.bitwiseOrOperator,
	Lexeme.bitwiseXOrOperator,
	Lexeme.bitwiseLeftShiftOperator,
	Lexeme.bitwiseRightShiftOperator,

	// logical operators
	Lexeme.logicalAndOperator,
	Lexeme.logicalOrOperator,

	// comparison operators
	Lexeme.equalsOperator,
	Lexeme.notEqualsOperator,
	Lexeme.greaterOperator,
	Lexeme.lessOperator,
	Lexeme.greaterOrEqualsOperator,
	Lexeme.lessOrEqualsOperator
};

const unaryOperators = {
	Lexeme.addOperator,
	Lexeme.subOperator,
	Lexeme.bitwiseNotOperator,
	Lexeme.logicalNotOperator
};

const operands = {
	Lexeme.identifier,
	Lexeme.decLiteral,
	Lexeme.floatLiteral,
	Lexeme.binLiteral,
	Lexeme.octLiteral,
	Lexeme.hexLiteral,
	Lexeme.boolLiteral
};
