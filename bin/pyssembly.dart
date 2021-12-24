import 'dart:io';

import 'package:pyssembly/compilation.dart' show compile;


void main(List<String> arguments) async {
	if (arguments.isEmpty) {
		print(help);
	}
	else {
		for (var path in arguments) {
			var file = File(path);

			if (await file.exists()) {
				print("\nCompiling \"$path\"");
				await compile(file);
			}
			else {
				print("The file \"$path\" does not exist");
			}
		}
	}
}

const help = "\nCompile Python code to Assembly x86 (MASM).\n"
"Usage: pyssembly <files>\n";
