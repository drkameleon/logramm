/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** returnSt.d
 **********************************************************/

module components.returnSt;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import globals;

import components.statement;
import components.expression;
import components.boolExpression;

import value;

import position;

import signals;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* ReturnSt_new(BoolExpression e) { return cast(void*)(new ReturnSt(e)); }

}

//================================================
// Functions
//================================================

class ReturnSt : Statement
{
	BoolExpression expression;

	Position pos;

	this(BoolExpression e)
	{
		super("return");

		expression = e;
	}

	override void print()
	{
		super.print();
		expression.expression.print();
	}

	override ExecResult execute()
	{
		Value eV = expression.evaluate();

		Glob.stack.push(eV);

		return ExecResult.Return;

		//throw new ReturnSignal();
	}
}
