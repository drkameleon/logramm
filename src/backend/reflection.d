/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/reflection.d
 **********************************************************/

module backend.reflection;

//================================================
// Imports
//================================================

import std.algorithm;
import std.array;
import std.conv;
import std.regex;
import std.stdio;
import std.string;

import globals;

import components.expressions;
import components.functionDecl;

import symbols;
import functions;

import value;

//================================================
// Class
//================================================

class LGM_Reflection
{
	static Value symbols(Value[] v)
	{
		Symbols curSymbols;

		if (Glob.localSymbols !is null) curSymbols = Glob.localSymbols;
		curSymbols = Glob.symbols;

		Value[] ret;

		foreach (string kv, Value vv; curSymbols.list)
		{
			ret ~= new Value(kv);
		}

		return new Value(ret);
	}

	static Value methods(Value[] v)
	{

		Functions curFunctions = Glob.functions;

		Value[] ret;

		foreach (FunctionDecl vv; curFunctions.list)
		{
			ret ~= new Value(vv.parentModule ~ "::" ~ vv.name);
		}

		return new Value(ret);
	}

	static Value functionInfo(Value[] v)
	{
		string fname = v[0].content.s;

		FunctionDecl f = Glob.functions.get(fname,"",new Expressions(),false);

		if (f is null) return new Value(false);

		Value[Value] ret;

		Value[] params;

		foreach (string p; f.params) params ~= new Value(p);
		ret[new Value("params")] = new Value(params);

		ret[new Value("returns")] = new Value(f.returns);
		ret[new Value("help")] = new Value(f.help);
		ret[new Value("module")] = new Value(f.parentModule);

		return new Value(ret);
	}

	static Value symbolExists(Value[] v)
	{
		string symbol = v[0].content.s;

		Value s = Glob.getSymbol(symbol);

		return new Value(s !is null);
	}

	static Value functionExists(Value[] v)
	{
		string fname = v[0].content.s;

		FunctionDecl f = Glob.functions.get(fname,"",new Expressions(),false);

		return new Value(f !is null);
	}

	static Value functionExistsInModule(Value[] v)
	{
		string mname = v[0].content.s;
		string fname = v[1].content.s;

		FunctionDecl f = Glob.functions.get(fname,mname,new Expressions(),false);

		return new Value(f !is null);
	}

	static Value inspect(Value[] v)
	{
		Value symbol = v[0];

		write(strip(symbol.inspect(0)));
		writeln(" ==> " ~ replace(to!string(symbol.type),"Value",""));

		return new Value(0);
	}
}
