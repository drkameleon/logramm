/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** outSt.d
 **********************************************************/

module components.outSt;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import components.statement;
import components.expression;

import value;

import position;


//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* OutSt_new(Expression e) { return cast(void*)(new OutSt(e)); }

}

//================================================
// Functions
//================================================

class OutSt : Statement
{
	Expression expression;

	this(Expression e)
	{
		super("out");

		expression = e;
	}

	override void print()
	{
		super.print();
		expression.print();
	}

	override ExecResult execute()
	{
		Value exprValue = expression.evaluate();
		writefln("%s",exprValue.str());

		return ExecResult.Ok;
	}
}
