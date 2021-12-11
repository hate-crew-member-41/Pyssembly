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

	// bool and none literals
	boolLiteral,  // variable
	noneLiteral,

	// identifier
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
	Lexeme.colon: ':',

	// identifier
	Lexeme.noneLiteral: 'None'
};

const nextCharDependentConstLexemes = [
	Lexeme.defKeyword,
	Lexeme.ifKeyword,
	Lexeme.elifKeyword,
	Lexeme.elseKeyword,
	Lexeme.forKeyword,
	Lexeme.inKeyword,
	Lexeme.whileKeyword,
	Lexeme.noneLiteral
];

const statementDelimiter = ';';
const numDelimiter = '_';
const decLiteralExpr = '\\d[0-9$numDelimiter]*';
const trueLiteral = 'True';
const nonIdentifierCharAfter = r'(?=\W|$)';

final lexemeExprs = {
	// next-char-dependent constant lexemes
	for (final lexeme in nextCharDependentConstLexemes)
		lexeme: RegExp('${constLexemes[lexeme]}$nonIdentifierCharAfter'),

	// number literals
	Lexeme.decLiteral: RegExp(decLiteralExpr),
	Lexeme.floatLiteral: RegExp('($decLiteralExpr)\\.($decLiteralExpr)'),
	Lexeme.binLiteral: RegExp('0b([01$numDelimiter]+)', caseSensitive: false),
	Lexeme.octLiteral: RegExp('0o([0-7$numDelimiter]+)', caseSensitive: false),
	Lexeme.hexLiteral: RegExp('0x([0-9a-f$numDelimiter]+)', caseSensitive: false),

	// bool literal
	Lexeme.boolLiteral: RegExp('($trueLiteral|False)$nonIdentifierCharAfter'),

	// identifier
	Lexeme.identifier: RegExp(r'[a-z_]\w*', caseSensitive: false)
};

const closingBrackets = {
	Lexeme.openingParenthesis: Lexeme.closingParenthesis,
	Lexeme.openingSquareBracket: Lexeme.closingSquareBracket,
	Lexeme.openingBrace: Lexeme.closingBrace
};
