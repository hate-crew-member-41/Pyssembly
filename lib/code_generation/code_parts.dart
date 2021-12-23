import 'dart:io' show File;


void writeHeadSection(File file) {
	file.writeAsStringSync(
		'.386\n'
		'.model flat, stdcall'
	);
}

void writeDataSection(Set<String> variables, File file) {
	String code = '.data\n';

	for (final variable in variables) {
		code += '_$variable\n dd ?';
	}

	file.writeAsStringSync(code);
}

void writeCodeSection(List<Object> tree, File file) {
	
}
