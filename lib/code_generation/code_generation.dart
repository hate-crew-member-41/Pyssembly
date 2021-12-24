import 'dart:io' show File, FileMode;

import 'package:pyssembly/syntax_analysis/expressions.dart' show Call;
import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme;
import 'package:pyssembly/lexical_analysis/positioned_lexeme.dart';
import 'package:pyssembly/syntax_analysis/statements.dart';

import 'package:pyssembly/errors/syntax_error.dart';

import 'code_section.dart';
import 'procedures.dart';


extension Code on File {
	void appendCode(String code) => writeAsStringSync(code, mode: FileMode.append);
}


/// Generates the Assembly code of the abstract syntax [tree],
/// and writes it into the [file].
void writeCode(List<Object> tree, File file) {
	writeHeadSection(file);
	writeDataSection(variables(tree), file);
	writeCodeSection(tree, file);
}

void writeHeadSection(File file) {
	file.writeAsStringSync(
		'.386\n'
		'.model flat, stdcall\n'
		'include \\masm32\\include\\masm32rt.inc\n'
	);
}

Set<String> variables(List<Object> tree) {
	final vars = <String>{};

	for (final statement in tree) {
		if (statement is Assignment) {
			vars.add(statement.variable);
		}
		else if (statement is CompoundStatement) {
			vars.addAll(variables(statement.body!));

			if (statement is If && statement.elseBlock != null) {
				vars.addAll(variables(statement.elseBlock!.body!));
			}
		}
	}

	return vars;
}

void writeDataSection(Set<String> variables, File file) {
	String code =
		'.data\n'
		'buffer db 32 dup(0)\n';

	for (final identifier in variables) {
		code += '${asmIdentifier(identifier)} dd 0\n';
	}

	file.appendCode(code);
}

String asmIdentifier(String identifier) => '_$identifier';

void writeCodeSection(List<Object> tree, File file) {
	file.appendCode(
		'.code\n'
		'$binToDecStrProc'
		'main:\n'
	);
	writeStatements(tree, file);
	file.appendCode('end main\n');
}

void writeStatements(List<Object> statements, File file, [String? loopLabel]) {
	for (final statementObj in statements) {
		switch (statementObj.runtimeType) {
			case Assignment:
				final statement = statementObj as Assignment;

				writeExpression(statement.expression, file);
				final identifier = asmIdentifier(statement.variable);
				file.appendCode('mov $identifier, edi\n');

				break;

			case If:
				final statement = statementObj as If;
				final afterLabel = 'after_if_${statement.lineNum}';

				writeExpression(statement.condition, file);

				if (statement.elseBlock == null) {
					file.appendCode(
						'cmp edi, 0\n'
						'je $afterLabel\n'
					);
					writeStatements(statement.body!, file, loopLabel);
					file.appendCode('$afterLabel:\n');
				}
				else {
					final elseLabel = 'else_${statement.elseBlock!.lineNum}';

					file.appendCode(
						'cmp edi, 0\n'
						'je $elseLabel\n'
					);
					writeStatements(statement.body!, file, loopLabel);
					file.appendCode(
						'jmp $afterLabel\n'
						'$elseLabel:\n'
					);
					writeStatements(statement.elseBlock!.body!, file, loopLabel);
					file.appendCode('$afterLabel:\n');
				}

				break;

			case While:
				final statement = statementObj as While;
				final label = 'while_${statement.lineNum}';
				final afterLabel = 'after_' + label;

				file.appendCode('$label:\n');
				writeExpression(statement.condition, file);
				file.appendCode(
					'cmp edi, 0\n'
					'je $afterLabel\n'
				);
				writeStatements(statement.body!, file, label);
				file.appendCode(
					'jmp $label\n'
					'$afterLabel:\n'
				);

				break;
			
			case Call:
				final statement = statementObj as Call;

				if (statement.identifier == 'print') {
					final posLexeme = statement.arguments.first as PositionedLexeme;
					final identifier = asmIdentifier(posLexeme.value as String);
					file.appendCode(
						'invoke BinToDecStr, addr $identifier, 32, addr buffer\n'
						'invoke StdOut, addr buffer\n'
					);
				}

				break;
			
			default:
				final statement = statementObj as PositionedLexeme;

				if (statement.lexeme == Lexeme.continueKeyword) {
					if (loopLabel == null) throw SyntaxError.noLoop(statement);

					file.appendCode('jmp $loopLabel\n');
				}
				else if (statement.lexeme == Lexeme.breakKeyword) {
					if (loopLabel == null) throw SyntaxError.noLoop(statement);

					file.appendCode('jmp after_$loopLabel\n');
				}
		}
	}
}
