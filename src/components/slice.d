/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** slice.d
 **********************************************************/

module components.slice;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;
import std.array;

import panic;
import components.argument;
import components.expression;
import components.expressions;
import components.arrayAr;

import value;
import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Slice_new(Expression l, Expression r) { return cast(void*)(new Slice(l,r)); }

}

//================================================
// Functions
//================================================

class Slice
{
	Expression left;
	Expression right;

	Position pos;

	this(Expression l, Expression r)
	{
		left = l;
		right = r;
	}
}
