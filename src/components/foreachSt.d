/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** foreachSt.d
 **********************************************************/

module foreachSt;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import globals;

import components.statement;
import components.expression;
import symbols;

import value;

import panic;
import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Foreach_new(char* i, Expression e, Statement s) { return cast(void*)(new Foreach(to!string(i),e,s)); }
	void* Foreach_newFromKeyValue(char* k, char* v, Expression e, Statement s) { return cast(void*)(new Foreach(to!string(k),to!string(v),e,s)); }
}

//================================================
// Functions
//================================================

class Foreach : Statement
{
	string id;
	string idval;
	Expression expression;
	Statement statement;
	Position pos;

	this(string i, Expression e, Statement s)
	{
		super("foreach");

		id = i;
		idval = null;
		expression = e;
		statement = s;
	}

		this(string k, string v, Expression e, Statement s)
	{
		super("foreach");

		id = k;
		idval = v;
		expression = e;
		statement = s;
	}

	override void print()
	{
		super.print();
	}

	override ExecResult execute()
	{
		Symbols curSymbols;
		if (Glob.localSymbols !is null) curSymbols = Glob.localSymbols;
		else curSymbols = Glob.symbols;

		ulong curI = 0;
		ulong maxI;
		Value v = expression.evaluate();
		Value curValue;
		Value valValue;

		Value[] keys; // if it's a dictionary
		Value[] vals; // ...
		if (v.type == ValueType.arrayValue) { maxI = v.content.a.length; }
		else if (v.type == ValueType.stringValue) { maxI = v.content.s.length; }
		else if (v.type == ValueType.dictionaryValue) 
		{
			maxI = v.content.d.length; 

			foreach (Value key, Value val; v.content.d)
			{
				keys ~= key;
				vals ~= val;
			}

			//writeln(keys);
		}
		else Panic.runtimeError("Trying to 'foreach' with invalid element");

		while (curI<maxI)
		{
			if (v.type == ValueType.arrayValue) {
				curValue = v.content.a[curI]; 
				if (idval !is null) valValue = new Value(curI);
			}
			else if (v.type == ValueType.stringValue) 
			{ 
				curValue = new Value(v.content.s[curI]); 
				if (idval !is null) valValue = new Value(curI);
			}
			else if (v.type == ValueType.dictionaryValue) 
			{ 
				curValue = keys[curI]; 
				if (idval !is null) valValue = vals[curI];
			}

			if (idval is null)
			{
				curSymbols.set(id,curValue);
			}
			else // REVERSED!
			{
				if (v.type!=ValueType.dictionaryValue)
				{
					curSymbols.set(idval,curValue);
					curSymbols.set(id,valValue);
				}
				else
				{
					curSymbols.set(id,curValue);
					curSymbols.set(idval,valValue);
				}
			}
			
			//writeln("Exec : st : " ~ statement.type);
			ExecResult rez = statement.execute();

			if (rez!=ExecResult.Ok) return rez;

			curI++;
		}

		return ExecResult.Ok;
	}
}