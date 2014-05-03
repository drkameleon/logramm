/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** execSt.d
 **********************************************************/

module components.execSt;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;
import std.string;
import std.array;

import library.file;

import globals;
import panic;
import compiler;
import components.statement;
import components.program;
import components.expression;

import value;
import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* ExecSt_new(Expression e) { return cast(void*)(new ExecSt(e)); }

}

//================================================
// Functions
//================================================

class ExecSt : Statement
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

		Program subprogram = compiler.compileFromString(code);
		subprogram.execute();

		return ExecResult.Ok;
	}
}
