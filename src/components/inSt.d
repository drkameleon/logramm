/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** inSt.d
 **********************************************************/

module components.inSt;

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

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* InSt_new(char* n) { return cast(void*)(new InSt(to!string(n))); }

}

//================================================
// Functions
//================================================

class InSt : Statement
{
	string name;

	Position pos;

	this(string n)
	{
		super("in");

		name = n;
	}

	override void print()
	{
		super.print();
		writeln("\t | Name : " ~ name);
	}

	override ExecResult execute()
	{
		string input = stdin.readln();
		if (Glob.localSymbols !is null) Glob.localSymbols.set(name, new Value(input));
		else Glob.symbols.set(name,new Value(input));

		return ExecResult.Ok;
	}
}
