/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** functionCallSt.d
 **********************************************************/

module components.functionCallSt;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import globals;

import components.statement;
import components.functionCall;
import components.argument;
import components.expression;
import components.expressions;

import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* FunctionCallSt_new(FunctionCall f) { return cast(void*)(new FunctionCallSt(f)); }
	void* FunctionCallSt_newWithArgument(FunctionCall f, Argument a) { return cast(void*)(new FunctionCallSt(f,a)); }

}

//================================================
// Functions
//================================================

class FunctionCallSt : Statement
{
	FunctionCall functionCall;

	Position pos;

	this(FunctionCall f)
	{
		super("functionCallSt");

		functionCall = f;
	}

	this(FunctionCall f, Argument a)
	{
		super("functionCallSt");

		Expression ex = new Expression(a);
		Expressions exs = new Expressions();
		exs.add(ex);

		foreach (Expression e; f.parameters.list)
		{
			exs.add(e);
		}

		FunctionCall fnew = new FunctionCall(f.name, exs);

		functionCall = fnew;
	}

	override void print()
	{
		super.print();

		functionCall.print();
	}

	override ExecResult execute()
	{
		functionCall = new FunctionCall(functionCall.name, functionCall.parameters);
		functionCall.execute();
		Glob.stack.pop();

		return ExecResult.Ok;
	}
}
