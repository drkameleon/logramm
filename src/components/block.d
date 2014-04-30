/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** block.d
 **********************************************************/

module block;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import components.statement;
import components.statements;

import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Block_new(Statements s) { return cast(void*)(new Block(s)); }

}

//================================================
// Functions
//================================================

class Block : Statement
{
	Statements statements;
	Position pos;

	this(Statements st)
	{
		super("block");

		statements = st;
	}

	override void print()
	{
		super.print();

		statements.print();
	}

	override ExecResult execute()
	{
		return statements.execute();
	}
}
