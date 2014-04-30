/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** ifSt.d
 **********************************************************/

module components.ifSt;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import components.statement;
import components.boolExpression;

import value;

import position;

import signals;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* IfSt_new(BoolExpression b, Statement s, Statement e) { return cast(void*)(new IfSt(b,s,e)); }

}

//================================================
// Functions
//================================================

class IfSt : Statement
{
	BoolExpression boolExpression;
	Statement statement;
	Statement elseStatement;

	Position pos;

	this(BoolExpression b, Statement s, Statement e)
	{
		super("ifSt");

		boolExpression = b;
		statement = s;
		elseStatement = e;
	}

	override void print()
	{
		super.print();
	}

	override ExecResult execute()
	{
		Value v = boolExpression.evaluate();
		if (v.content.b)
		{
			ExecResult rez = statement.execute();

			if (rez!=ExecResult.Ok) return rez;
		}
		else
		{
			if (elseStatement !is null)
			{
				ExecResult rez = elseStatement.execute();

				if (rez!=ExecResult.Ok) return rez;
			}
		}

		return ExecResult.Ok;
	}
}