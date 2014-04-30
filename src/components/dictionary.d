/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** dictionary.d
 **********************************************************/

module components.dictionary;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;
import std.array;

import panic;
import components.pair;
import components.pairs;
import components.argument;
import components.expression;
import components.expressions;

import value;
import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Dictionary_new(Pairs p) { return cast(void*)(new Dictionary(p)); }

}

//================================================
// Functions
//================================================

class Dictionary
{
	Pairs pairs;
	Position pos;

	this(Pairs p)
	{
		pairs = p;
	}
}
