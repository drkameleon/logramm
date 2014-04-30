/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** arrayAr.d
 **********************************************************/

module components.arrayAr;

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

import value;

import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* ArrayAr_new(Expressions e) { return cast(void*)(new ArrayAr(e)); }
	void* ArrayAr_newFromRange(Expression l, Expression r) { return cast(void*)(new ArrayAr(l,r)); }

}

//================================================
// Functions
//================================================

class ArrayAr
{
	Expressions expressions;
	Expression left, right;
	Position pos;

	this(Expressions e)
	{
		expressions = e;
		left = null;
		right = null;
	}

	this(Expression l, Expression r)
	{
		left = l;
		right = r;
		expressions = null;
	}

	void evaluate()
	{
		if (expressions is null)
		{
			Value vL = left.evaluate();
			Value vR = right.evaluate();

			expressions = new Expressions();

			ulong min,max;

			if (vL.content.i<vR.content.i) { min = vL.content.i; max = vR.content.i; }
			else { min = vR.content.i; max = vL.content.i; }

			for (ulong i=min; i<max; i++)
			{
				expressions.add(new Expression(new Argument("number",to!string(i))));
			}
		}
	}
}
