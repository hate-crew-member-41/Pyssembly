enum Lexeme {
	indentation,  // variable

	// keywords
	functionDeclaration,
	
	// brackets
	openingParenthesis,
	closingParenthesis,
	openingSquareBracket,
	closingSquareBracket,
	openingBrace,
	closingBrace,

	// number literals
	decLiteral,
	floatLiteral,
	binLiteral,
	octLiteral,
	hexLiteral,

	identifier
}

const numDelimiter = '_';
const decLiteralExpression = '\\d[0-9$numDelimiter]*';

final codeLexemes = {
	// keywords
	Lexeme.functionDeclaration: 'def ',

	// brackets
	Lexeme.openingParenthesis: '(',
	Lexeme.closingParenthesis: ')',
	Lexeme.openingSquareBracket: '[',
	Lexeme.closingSquareBracket: ']',
	Lexeme.openingBrace: '{',
	Lexeme.closingBrace: '}',

	// number literals
	Lexeme.decLiteral: RegExp(decLiteralExpression),
	Lexeme.floatLiteral: RegExp('($decLiteralExpression)\\.($decLiteralExpression)'),
	Lexeme.binLiteral: RegExp('0b([01$numDelimiter]+)', caseSensitive: false),
	Lexeme.octLiteral: RegExp('0o([0-7$numDelimiter]+)', caseSensitive: false),
	Lexeme.hexLiteral: RegExp('0x([0-9a-f$numDelimiter]+)', caseSensitive: false),

	// identifier
	Lexeme.identifier: RegExp(r'[a-z_]\w*', caseSensitive: false),
};

const closingBrackets = {
	Lexeme.openingParenthesis: Lexeme.closingParenthesis,
	Lexeme.openingSquareBracket: Lexeme.closingSquareBracket,
	Lexeme.openingBrace: Lexeme.closingBrace
};
