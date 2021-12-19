import 'lexemes.dart' show Lexeme, constLexemes;


class PositionedLexeme {
	final int lineNum;

	final Lexeme lexeme;
	final Object? value;

	const PositionedLexeme(this.lineNum, this.lexeme, [this.value]);

	@override
	String toString() => constLexemes[lexeme] ?? value as String;
}
