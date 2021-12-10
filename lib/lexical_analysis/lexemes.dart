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

	// number literals (variable)
	decLiteral,
	floatLiteral,
	binLiteral,
	octLiteral,
	hexLiteral,
	// todo: add complex literal

	identifier  // variable
}

const constLexemes = {
	// keywords
	Lexeme.functionDeclaration: 'def',

	// brackets
	Lexeme.openingParenthesis: '(',
	Lexeme.closingParenthesis: ')',
	Lexeme.openingSquareBracket: '[',
	Lexeme.closingSquareBracket: ']',
	Lexeme.openingBrace: '{',
	Lexeme.closingBrace: '}',
};

const numDelimiter = '_';
const decLiteralExpr = '\\d[0-9$numDelimiter]*';
const nonIdentifierCharAfter = r'(?=\W|$)';

final lexemeExprs = {
	// keywords
	Lexeme.functionDeclaration: RegExp('${constLexemes[Lexeme.functionDeclaration]}$nonIdentifierCharAfter'),

	// number literals
	Lexeme.decLiteral: RegExp(decLiteralExpr),
	Lexeme.floatLiteral: RegExp('($decLiteralExpr)\\.($decLiteralExpr)'),
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
