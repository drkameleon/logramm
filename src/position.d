/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** position.d
 **********************************************************/

//================================================
// Imports
//================================================

import std.stdio;
import core.stdc.stdlib;
import std.string;
import std.conv;

import globals;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Position_new(int l, char* f) { return cast(void*)(new Position(l,to!string(f))); }
}

//================================================
// Functions
//================================================

class Position
{
	int line;
	string filename;

	this(int l, string f)
	{
		line = l;
		filename = f;
	}
}

