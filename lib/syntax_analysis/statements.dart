class Assignment {
	final String variable;
	final Object expression;

	Assignment(this.variable, this.expression);
}

class If {
	final Object condition;
	Object? body;

	If(this.condition, [this.body]);
}
