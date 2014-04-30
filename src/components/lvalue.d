/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** lvalue.d
 **********************************************************/

module components.lvalue;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;
import std.array;

import globals;
import panic;
import components.argument;
import components.expression;
import components.expressions;
import components.arrayAr;

import symbols;

import value;
import position;

import errors;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Lvalue_new(char* n) { return cast(void*)(new Lvalue(to!string(n))); }
	void* Lvalue_newFromId(Lvalue l, char* n) { return cast(void*)(new Lvalue(l,to!string(n))); }
	void* Lvalue_newFromHash(Lvalue l, Expression e) { return cast(void*)(new Lvalue(l,e)); }
}

//================================================
// Functions
//================================================

class Lvalue
{
	Position pos;

	string name;
	Lvalue parent;
	Expression expression;

	this(string n)
	{
		name = n;
		parent = null;
		expression = null;
	}

	this(Lvalue l, string n)
	{
		name = n;
		parent = l;
		expression = null;
	}

	this(Lvalue l, Expression e)
	{
		name = null;
		parent = l;
		expression = e;
	}

	string getName()
	{
		if (parent is null) return name;
		else return parent.getName();
	}

	Value getParent(Symbols syms)
	{
		if (parent is null)
		{
			if (syms.exists(name))
				return syms.getWithoutReference(name);
			else return null;
		}
		else
		{
			return parent.getParent(syms);
		}
	}

	Value[] paths()
	{
		if (parent is null) return [];
		else 
		{
			if (expression !is null)
				return parent.paths() ~ expression.evaluate();
			else
				return parent.paths() ~ new Value(name);
		}
	}

	void setNestedValue(ref Value parentValue, Value newValue, Value[] indexes)
	{
		Value* node = &parentValue;

		foreach (Value index; indexes)
		{
			if (node.type==ValueType.arrayValue)
			{
				node = &node.content.a[to!int(index.str())];
			}
			else if (node.type==ValueType.dictionaryValue)
			{

				foreach (Value kv, Value vv; node.content.d)
				{
					if (kv.str()==index.str())
					{
						node = &node.content.d[kv];
						break;
					}
				}
			}
		}

		*node = newValue;
	}

	Value getValue(Symbols syms)
	{
		if (parent is null) 
		{
			if (syms.exists(name)) 
				return syms.get(name);
			else
				return null;
		}
		else
		{
			Value left = new Value(parent.getValue(syms));

			if (left is null) throw new Exception("LEFT does not exist. (no pun intended) :-p");

			//writeln("Got parent value");

			if (expression !is null)
			{
				//writeln("It's an expression [...] type of reference");
				Value calc = expression.evaluate();

				if (left.type==ValueType.arrayValue)
				{
					//writeln("LEFT--> array");
					return left.content.a[to!int(calc.str())];
				}
				else if (left.type==ValueType.dictionaryValue)
				{
					//writeln("LEFT--> dictionary");
					foreach (Value kk, Value vv; left.content.d)
					{
						if (kk==calc) return vv;
					}
					throw new Exception("WTF... Searching for dict key, but not found");
				}
				else
					throw new Exception("WTF... LValue...");
			}
			else // it's a dot-child reference
			{
				//writeln("It's a dot-child (.child) type of reference");
				Value calc = new Value(name);

				if (left.type==ValueType.dictionaryValue)
				{
					//writeln("LEFT--> dictionary");
					foreach (Value kk, Value vv; left.content.d)
					{
						if (kk==calc) return vv;
					}
					throw new Exception("WTF... Searching for dict key, but not found");
				}
				else
					throw new Exception("WTF... LValue...");
			}
		}
	}
}
