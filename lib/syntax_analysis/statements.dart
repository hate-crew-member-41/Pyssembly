abstract class Statement {
	final int lineNum;

	Statement(this.lineNum);
}

abstract class CompoundStatement extends Statement {
	List<Object>? body;

	CompoundStatement(this.body, int lineNum) : super(lineNum);
}


class Assignment extends Statement {
	final String variable;
	final Object expression;

	Assignment(this.variable, this.expression, int lineNum) : super(lineNum);
}


class If extends CompoundStatement {
	final Object condition;
	Else? elseBlock;

	If(this.condition, List<Object>? body, int lineNum) : super(body, lineNum);
}


class Else extends CompoundStatement {
	Else(List<Object>? body, int lineNum) : super(body, lineNum);
}
