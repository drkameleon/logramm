/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** identifiers.d
 **********************************************************/

module components.identifiers;

//================================================
// Imports
//================================================

import core.memory;

import std.stdio;
import std.conv;

import components.expression;
import components.expressions;

import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Identifiers_new() { return cast(void*)(new Identifiers()); }
	void  Identifiers_add(Identifiers i, char* n) {  GC.addRoot(cast(void*)i); i.add(to!string(n)); }
}

//================================================
// Functions
//================================================

class Identifiers
{
	string[] list;

	Position pos;

	this()
	{
	}

	this(Expressions e)
	{
		foreach (Expression x; e.list)
		{
			list ~= x.arg.value.str(); // too hackish. !TO-FIX
		}
	}

	void add(string n)
	{
		list ~= n;
	}

	void print()
	{
		for (int i=0; i<list.length; i++)
		{
			write(to!string(i) ~ "\t : " ~ list[i]);
		}
	}
}