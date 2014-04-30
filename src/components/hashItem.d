/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** hashItem.d
 **********************************************************/

module components.hashItem;

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

import value;
import position;

import errors;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* HashItem_new(char* n, Expression e) { return cast(void*)(new HashItem(to!string(n),e)); }
	void* HashItem_newFromParent(HashItem h, Expression e) { return cast(void*)(new HashItem(h,e)); }

}

//================================================
// Functions
//================================================

class HashItem
{
	string name;
	Expression expression;
	HashItem parent;
	Position pos;

	this(string n, Expression e)
	{
		name = n;
		expression = e;
		parent = null;
	}

	this(HashItem h, Expression e)
	{
		name = null;
		expression = e;
		parent = h;
	}

	Value evaluate()
	{
		Value arr;

		//if (parent !is null) writeln("PARENT SET"); else writeln("PARENT NULL");
		//if (name !is null) writeln("NAME SET : " ~ name); else writeln("NAME NULL");
		if (name !is null) { 

			string[] path = name.splitter('|').array();

			if (path.length==1) arr = Glob.getSymbol(name);
			else
			{
				HashItem previousHash;
				for (int i=0; i<path.length; i++)
				{
					if (i==0)
					{
						previousHash = new HashItem(path[0], new Expression(new Argument("string",path[1])));
					}
					else
					{
						if (i!=path.length-1)
							previousHash = new HashItem(previousHash, new Expression(new Argument("string",path[i+1])));
					}
				}

				arr = previousHash.evaluate();
			}


		}
		else arr = parent.evaluate();

		Value eV = expression.evaluate();

		if (arr.type==ValueType.arrayValue)
		{
			//writeln("here");
			if (eV.content.i<=arr.content.a.length-1)
				return arr.content.a[eV.content.i];
			else
			{
				//writeln("HERE");
				throw new ERR_OutOfRange("["~to!string(eV.content.i)~"]", to!string(arr.str()));
			}
		}
		else if (arr.type==ValueType.dictionaryValue)
		{
			try
			{
				foreach (Value key, Value v; arr.content.d)
				{
					if (key==eV) return arr.content.d[key];
				}
				return arr.content.d[eV];
			}
			catch (Exception e)
			{
				throw new ERR_OutOfRange("["~eV.str()~"]", to!string(arr.str()));
			}
		}
		else if (arr.type==ValueType.stringValue)
		{
			return new Value(to!string(arr.content.s[eV.content.i]));
		}

		return null;
	}
}
