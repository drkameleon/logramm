/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** statement.d
 **********************************************************/

module components.statement;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import position;


enum ExecResult
{
	Ok,
	Return,
	Break
}

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void Set_Position(Statement x, Position p) { x.pos = p; }
}

//================================================
// Functions
//================================================

class Statement
{
	string type;
	Position pos;

	this(string t)
	{
		type = t;
	}

	void print()
	{
		writeln(type);
	}

	ExecResult execute()
	{
		writeln("Unimplemented");

		return ExecResult.Ok;
	}
}