/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** program.d
 **********************************************************/

module components.program;

//================================================
// Imports
//================================================

import core.memory;

import std.stdio;
import std.conv;

import globals;

import components.statement;
import components.statements;

import signals;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void  Program_set(Program p, Statements s) { GC.addRoot(cast(void*)p); p.set(s); }
}

//================================================
// Functions
//================================================

class Program 
{
	Statements statements;

	this()
	{

	}

	void set(Statements st)
	{
		statements = st;
	}

	void print()
	{
		statements.print();
	}

	ExecResult execute()
	{
		//writeln("EXECUTING PROGRAM");
		statements.execute();
		//writeln("EXECUTED PROGRAM");

		return ExecResult.Ok;
	}
}
