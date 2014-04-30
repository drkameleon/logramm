/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** boolExpression.d
 **********************************************************/

module components.boolExpression;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;
import std.array;

import panic;

import components.expression;
import components.relExpression;

import value;
import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* BoolExpression_new(RelExpression l, char* op, RelExpression r) { return cast(void*)(new BoolExpression(l,to!string(op),r)); }
	void* BoolExpression_newFromExpression(Expression e) { return cast(void*)(new BoolExpression(e)); }

}

//================================================
// Functions
//================================================

class BoolExpression
{
	RelExpression left;
	string operator;
	RelExpression right;

	Expression expression;
	Position pos;

	this(RelExpression l, string op, RelExpression r)
	{
		left = l;
		operator = op;
		right = r;

		expression = null;
	}

	this(Expression expr)
	{
		expression = expr;
	}

	Value evaluate()
	{
		if (expression !is null)
		{
			Value eValue = expression.evaluate();
			return eValue;
		}

		Value lValue = left.evaluate(); 

		if ((operator=="!") || (operator=="not"))
		{
			if (lValue.content.b) return new Value(false);
			else return new Value(true);
		}

		if (right is null) return lValue;

		Value rValue = right.evaluate();

		if ((lValue.type == ValueType.booleanValue) && (rValue.type == ValueType.booleanValue))
		{
			switch (operator)
			{
				case "&"	: 
				case "and"	: return new Value(lValue.content.b && rValue.content.b);

				case "|"	: 
				case "or"	: return new Value(lValue.content.b || rValue.content.b);

				case "^"	:
				case "xor"	: return new Value(((lValue.content.b || rValue.content.b) && !(lValue.content.b && rValue.content.b)));

				default		: return null;
			}
		}

		return null;
	}

}
