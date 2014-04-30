/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** expression.d
 **********************************************************/

module components.expression;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;
import std.array;

import panic;
import components.argument;

import value;
import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Expression_new(Expression l, char* op, Expression r) { return cast(void*)(new Expression(l,to!string(op),r)); }
	void* Expression_newFromArgument(Argument a) { return cast(void*)(new Expression(a)); }

}

//================================================
// Functions
//================================================

class Expression
{
	Expression left;
	string operator;
	Expression right;

	Argument arg;

	Position pos;

	this() // an empty one
	{

	}

	this(Expression l, string op, Expression r)
	{
		left = l;
		operator = op;
		right = r;

		arg = null;
	}

	this(Argument a)
	{
		arg = a;
	}

	Value evaluate()
	{
		if (arg !is null) return arg.getValue(); //#CHNG

		Value lValue = left.evaluate();
		Value rValue; 
		if (right) rValue = right.evaluate(); //#CHNG


		switch (operator)
		{
			case "+"	: return lValue+rValue;
			case "-"	: return lValue-rValue;
			case "*"	: return lValue*rValue;
			case "/"	: return lValue/rValue;
			case "%"	: return lValue%rValue;
			case "&&"	: return lValue&rValue;
			case "||"	: return lValue|rValue;
			case "^^"	: return lValue^rValue;
			case "u-"	: return -lValue;
			case ""		: return lValue; //#CHNG
			default		: break;
		}

		return null;
	}

	void print()
	{
		writeln("Expression: ");
		if (!arg)
		{
			writeln("\t | Operator: " ~ operator ~ ", Left: ");
			left.print();
			writeln("Right: ");
			right.print();
		}
		else
		{
			writeln("\t | Argument: ");
			arg.print();
		}
	}


}
