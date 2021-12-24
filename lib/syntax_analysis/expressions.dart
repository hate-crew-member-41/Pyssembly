import 'dart:collection' show Queue;

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
	final Lexeme operation;

	OneOperandExpression(this.operand, this.operation);
}
