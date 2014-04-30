/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** nullSt.d
 **********************************************************/

module nullSt;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import globals;

import components.statement;
import components.expression;

import value;

import position;
import signals;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* NullSt_new() { return cast(void*)(new NullSt()); }

}

//================================================
// Functions
//================================================

class NullSt : Statement
{
	Position pos;

	this()
	{
		super("nullSt");
	}

	override ExecResult execute()
	{
		return ExecResult.Ok;
		//writeln("null statement executed. :p");
		// Nothing to do
	}
}
