enum Lexeme {
	indentation,  // variable

	// keywords
	defKeyword,
	ifKeyword,
	elifKeyword,
	elseKeyword,
	forKeyword,
	inKeyword,
	whileKeyword,

	// brackets
	openingParenthesis,
	closingParenthesis,
	openingSquareBracket,
	closingSquareBracket,
	openingBrace,
	closingBrace,

	// symbols
	comma,
	colon,

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
	Lexeme.defKeyword: 'def',
	Lexeme.ifKeyword: 'if',
	Lexeme.elifKeyword: 'elif',
	Lexeme.elseKeyword: 'else',
	Lexeme.forKeyword: 'for',
	Lexeme.inKeyword: 'in',
	Lexeme.whileKeyword: 'while',

	// brackets
	Lexeme.openingParenthesis: '(',
	Lexeme.closingParenthesis: ')',
	Lexeme.openingSquareBracket: '[',
	Lexeme.closingSquareBracket: ']',
	Lexeme.openingBrace: '{',
	Lexeme.closingBrace: '}',

	// symbols
	Lexeme.comma: ',',
	Lexeme.colon: ':'
};

const keywords = [
	Lexeme.defKeyword,
	Lexeme.ifKeyword,
	Lexeme.elifKeyword,
	Lexeme.elseKeyword,
	Lexeme.forKeyword,
	Lexeme.whileKeyword
];

const statementDelimiter = ';';
const numDelimiter = '_';
const decLiteralExpr = '\\d[0-9$numDelimiter]*';
const nonIdentifierCharAfter = r'(?=\W|$)';

final lexemeExprs = {
	// keywords
	for (final lexeme in keywords)
		lexeme: RegExp('${constLexemes[lexeme]}$nonIdentifierCharAfter'),

	// number literals
	Lexeme.decLiteral: RegExp(decLiteralExpr),
	Lexeme.floatLiteral: RegExp('($decLiteralExpr)\\.($decLiteralExpr)'),
	Lexeme.binLiteral: RegExp('0b([01$numDelimiter]+)', caseSensitive: false),
	Lexeme.octLiteral: RegExp('0o([0-7$numDelimiter]+)', caseSensitive: false),
	Lexeme.hexLiteral: RegExp('0x([0-9a-f$numDelimiter]+)', caseSensitive: false),

	// identifier
	Lexeme.identifier: RegExp(r'[a-z_]\w*', caseSensitive: false)
};

const closingBrackets = {
	Lexeme.openingParenthesis: Lexeme.closingParenthesis,
	Lexeme.openingSquareBracket: Lexeme.closingSquareBracket,
	Lexeme.openingBrace: Lexeme.closingBrace
};
