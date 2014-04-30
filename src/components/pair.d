/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** pair.d
 **********************************************************/

module components.pair;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;
import std.array;

import panic;
import components.expression;

import value;

import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Pair_new(Expression k, Expression v) { return cast(void*)(new Pair(k,v)); }

}

//================================================
// Functions
//================================================

class Pair
{
	Expression key;
	Expression value;

	this (Expression k, Expression v)
	{
		key = k;
		value = v;
	}
}
