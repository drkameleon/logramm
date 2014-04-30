/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** expressions.d
 **********************************************************/

module components.expressions;

//================================================
// Imports
//================================================

import core.memory;

import std.stdio;
import std.conv;

import components.expression;

import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Expressions_new() { return cast(void*)(new Expressions()); }
	void  Expressions_add(Expressions e, Expression ex) {  GC.addRoot(cast(void*)e); e.add(ex); }
	void  Expressions_addFromExpressions(Expressions e, Expressions ex) {  GC.addRoot(cast(void*)e); e.add(ex); }

}

//================================================
// Functions
//================================================

class Expressions
{
	Expression[] list;
	Position pos;

	this()
	{
	}

	void add(Expression ex)
	{
		list ~= ex;
	}

	void add(Expressions ex)
	{
		foreach (Expression ee; ex.list)
		{
			list ~= ee;
		}
	}

	void print()
	{
		for (int i=0; i<list.length; i++)
		{
			write(to!string(i) ~ "\t : ");
			list[i].print();
		}
	}
}