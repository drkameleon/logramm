/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** breakSt.d
 **********************************************************/

module breakSt;

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
	void* BreakSt_new() { return cast(void*)(new BreakSt()); }

}

//================================================
// Functions
//================================================

class BreakSt : Statement
{
	Position pos;

	this()
	{
		super("break");
	}

	override void print()
	{
		super.print();
	}

	override ExecResult execute()
	{
		//writeln("Breaking");
		//throw new BreakSignal();
		return ExecResult.Break;
	}
}
