/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** loop.d
 **********************************************************/

module loop;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import globals;

import components.statement;
import components.boolExpression;

import value;

import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Loop_new(BoolExpression b, Statement s) { return cast(void*)(new Loop(b,s)); }

}

//================================================
// Functions
//================================================

class Loop : Statement
{
	BoolExpression boolExpression;
	Statement statement;

	Position pos;

	this(BoolExpression b, Statement s)
	{
		super("loop");

		boolExpression = b;
		statement = s;
	}

	override void print()
	{
		super.print();
	}

	override ExecResult execute()
	{
		Value v = boolExpression.evaluate();
		while (v.content.b)
		{
			Glob.breakCounter = 1;
			ExecResult rez = statement.execute();

			if (rez!=ExecResult.Ok) return rez;
			Glob.breakCounter = -1;
			v = boolExpression.evaluate();
		}

		return ExecResult.Ok;
	}
}