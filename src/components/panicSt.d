/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** panicSt.d
 **********************************************************/

module components.panicSt;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;
import std.string;
import std.array;

import helpers.file;

import globals;
import panic;
import components.statement;
import components.program;
import components.expression;

import value;
import position;

import errors;

import signals;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* PanicSt_new(Expression e) { return cast(void*)(new PanicSt(e)); }

}

//================================================
// Functions
//================================================

class PanicSt : Statement
{
	Expression expression;
	Position pos;

	this(Expression e)
	{
		super("exec");

		expression = e;
	}

	override ExecResult execute()
	{
		Value eV = expression.evaluate();
		string code = eV.str();

		throw new ERR_UserException(code);

		return ExecResult.Ok; // won't even reach here
	}
}
