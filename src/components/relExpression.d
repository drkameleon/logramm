/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** relExpression.d
 **********************************************************/

module components.relExpression;

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
	void* RelExpression_new(Expression l, char* op, Expression r) { return cast(void*)(new RelExpression(l,to!string(op),r)); }

}

//================================================
// Functions
//================================================

class RelExpression
{
	Expression left;
	string operator;
	Expression right;

	Position pos;

	this(Expression l, string op, Expression r)
	{
		left = l;
		operator = op;
		right = r;
	}

	Value evaluate()
	{
		Value lValue = left.evaluate();
		Value rValue = right.evaluate();

		switch (operator)
		{
			case "=="	: return new Value(lValue==rValue);
			case "!="	: return new Value(lValue!=rValue);
			case ">"	: return new Value(lValue>rValue);
			case ">="	: return new Value(lValue>=rValue);
			case "<"	: return new Value(lValue<rValue);
			case "<="	: return new Value(lValue<=rValue);
			default		: break;
		}

		return null;
	}

}
