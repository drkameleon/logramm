/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** module.d
 **********************************************************/

module components.moduleSt;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import globals;

import components.statement;
import components.statements;

import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Module_new(char* n, Statements s) { return cast(void*)(new Module(to!string(n),s)); }

}

//================================================
// Functions
//================================================

class Module : Statement
{
	string name;
	Statements statements;

	Position pos;

	this(string n, Statements s)
	{
		super("module");

		name = n;
		statements = s;
	}

	override void print()
	{
		super.print();

		writeln("\t | Name: " ~ name);
		statements.print();
	}

	override ExecResult execute()
	{
		Glob.currentModule = this;
		statements.execute();
		Glob.currentModule = null;

		return ExecResult.Ok;
	}
}
