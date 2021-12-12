import 'package:test/test.dart';

import 'package:pyssembly/errors/indentation_error.dart' show IndentationError;
import 'package:pyssembly/lexical_analysis/lexical_analysis.dart' show Line;
import 'package:pyssembly/lexical_analysis/lexemes.dart' show Lexeme, constLexemes;


void main() {
	group('Indentation', () {
		group('holds', () {
			test('none', () {
				expect(
					'line'.indentationChange([0]),
					equals(0)
				);
			});
			test('multiple-level', () {
				expect(
					'   line'.indentationChange([0, 2, 3]),
					equals(0)
				);
			});
		});

		group('increases', () {
			test('to single-level', () {
				expect(
					'  line'.indentationChange([0]),
					equals(2)
				);
			});
			test('to multiple-level', () {
				expect(
					'   line'.indentationChange([0, 1, 2]),
					equals(1)
				);
			});
		});

		group('decreases', () {
			group('by 1 level', () {
				test('to none', () {
					expect(
						'line'.indentationChange([0, 1]),
						equals(-1)
					);
				});
				test('to multiple-level', () {
					expect(
						'   line'.indentationChange([0, 1, 3, 6]),
						equals(-1)
					);
				});
			});

			group('by multiple levels', () {
				test('to none', () {
					expect(
						'line'.indentationChange([0, 1, 5, 7]),
						equals(-3)
					);
				});
				test('to multiple-level', () {
					expect(
						'   line'.indentationChange([0, 1, 3, 6, 7]),
						equals(-2)
					);
				});
			});

			group('without a match', () {
				test('from single-level', () {
					expect(
						() => ' line'.indentationChange([0, 2]),
						throwsA(isA<IndentationError>())
					);
				});
				test('from multiple-level', () {
					expect(
						() => '   line'.indentationChange([0, 2, 4, 7]),
						throwsA(isA<IndentationError>())
					);
				});
			});
		});
	});

	group('Prefix lexeme is removed', () {
		test('with succeeding spaces', () {
			String defKeyword = constLexemes[Lexeme.defKeyword]!;
			expect(
				'$defKeyword main():'.afterLexeme(defKeyword),
				equals('main():')
			);
		});
		test('without succeeding spaces', () {
			String comma = constLexemes[Lexeme.comma]!;
			expect(
				'${comma}identifier'.afterLexeme(comma),
				equals('identifier')
			);
		});
		test('at the end', () {
			String colon = constLexemes[Lexeme.colon]!;
			expect(
				colon.afterLexeme(colon),
				equals('')
			);
		});
	});
}
