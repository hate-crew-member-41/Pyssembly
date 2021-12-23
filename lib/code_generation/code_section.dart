import 'dart:io' show File;

import 'package:pyssembly/syntax_analysis/expression.dart';
import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme;
import 'package:pyssembly/lexical_analysis/positioned_lexeme.dart';

import 'code_generation.dart' show Code;


const singleInstructionOperationsInstructions = {
	// arithmetical operations
	Lexeme.addOperator: 'add',
	Lexeme.subOperator: 'sub',

	// bitwise operations
	Lexeme.bitwiseAndOperator: 'and',
	Lexeme.bitwiseOrOperator: 'or',
	Lexeme.bitwiseXOrOperator: 'xor',
};

const shiftInstructions = {
	Lexeme.bitwiseLeftShiftOperator: 'shl',
	Lexeme.bitwiseRightShiftOperator: 'shr'
};

const logicalExprsInstructions = {
	Lexeme.logicalAndOperator: 'and',
	Lexeme.logicalOrOperator: 'or'
};

const comparisonExprsInstructions = {
	Lexeme.equalsOperator: 'sete',
	Lexeme.notEqualsOperator: 'setne',
	Lexeme.greaterOperator: 'setg',
	Lexeme.lessOperator: 'setl',
	Lexeme.greaterOrEqualsOperator: 'setge',
	Lexeme.lessOrEqualsOperator: 'setle'
};


void writeExpression(Object expression, File file) {
	if (expression is TwoOperandExpression) {
		writeExpression(expression.rightOperand, file);
		file.appendCode('push edi\n');
		writeExpression(expression.leftOperand, file);
		file.appendCode('pop esi\n');

		String? instruction = singleInstructionOperationsInstructions[expression.operation];
		if (instruction != null) {
			file.appendCode(singleInstructionExprCode(instruction));
			return;
		}

		instruction = shiftInstructions[expression.operation];
		if (instruction != null) {
			file.appendCode(shiftCode(instruction));
			return;
		}

		instruction = logicalExprsInstructions[expression.operation];
		if (instruction != null) {
			file.appendCode(logicalExprCode(instruction));
			return;
		}

		instruction = comparisonExprsInstructions[expression.operation];
		if (instruction != null) {
			file.appendCode(comparisonExprCode(instruction));
			return;
		}
	}
	
	if (expression is OneOperandExpression) {
		writeExpression(expression.operand, file);
		late String code;
	
		switch (expression.operation) {
			case Lexeme.subOperator:
				code = 
					'mov esi, edi\n'
					'xor edi, edi\n'
					'sub edi, esi\n';
				break;

			case Lexeme.bitwiseNotOperator:
				code = 'not edi\n';
				break;

			case Lexeme.logicalNotOperator:
				code =
					'cmp edi, 0\n'
					'sete al\n'
					'and eax, 0ffh\n'
					'mov edi, eax\n';
				break;
			
			default:
				code = '';
		}

		file.appendCode(code);
		return;
	}

	final operand = expression as PositionedLexeme;
	late String value;

	switch (operand.lexeme) {
		case Lexeme.binLiteral:
			value = '${operand.value}b';
			break;

		case Lexeme.octLiteral:
			value = '${operand.value}o';
			break;

		case Lexeme.hexLiteral:
			value = '${operand.value}h';
			break;
		
		case Lexeme.boolLiteral:
			value = operand.value as bool ? '1' : '0';
			break;
		
		case Lexeme.noneLiteral:
			value = '0';
			break;

		default:
			value = operand.value as String;
	}

	file.appendCode('mov edi, $value\n');
}

String singleInstructionExprCode(String instruction) =>
	'$instruction edi, esi\n';

String shiftCode(String instruction) =>
	'mov ecx, esi\n'
	'$instruction edi, cl\n';

String logicalExprCode(String instruction) =>
	'setnz al\n'
	'cmp esi, 0\n'
	'setne bl\n'
	'$instruction al, bl\n'
	'and eax, 0ffh\n'
	'mov edi, eax\n';

String comparisonExprCode(String instruction) =>
	'cmp edi, esi\n'
	'$instruction al\n'
	'and eax, 0ffh\n'
	'mov edi, eax\n';

String asmNumLiteral(PositionedLexeme literal) {
	final value = literal.value as String;

	switch (literal.lexeme) {
		case Lexeme.binLiteral: return '${value}b';
		case Lexeme.octLiteral: return '${value}o';
		case Lexeme.hexLiteral: return '0${value}h';
		default: return value;
	}
}
