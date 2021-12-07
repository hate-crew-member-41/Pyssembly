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
				print("Compiling \"$path\"");
				compile(file);
			}
			else {
				print("The file \"$path\" does not exist");
			}
		}
	}
}

const help = "Compile Python code to Assembly (MASM 32-bit).\nUsage: pyssembly [files]";
