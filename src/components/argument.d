/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** argument.d
 **********************************************************/

module components.argument;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;
import std.array;
import std.string;
import std.algorithm;
import std.regex;

import globals;

import components.functionCall;
import components.arrayAr;
import components.dictionary;
import components.hashItem;
import components.functionDecl;
import components.expression;
import components.expressions;
import components.slice;

import value;
import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Argument_new(char* t, char* v) { return cast(void*)(new Argument(to!string(t),to!string(v))); }
	void* Argument_newFromFunction(FunctionCall f) { return cast(void*)(new Argument(f)); }
	void* Argument_newFromArray(ArrayAr a) { return cast(void*)(new Argument(a)); }
	void* Argument_newFromDictionary(Dictionary d) { return cast(void*)(new Argument(d)); }
	void* Argument_newFromHashItem(Argument a, Expression e) { return cast(void*)(new Argument(a,e)); }
	void* Argument_newFromHashItemExpr(Expression e, Expression ex) { return cast(void*)(new Argument(e,ex)); }
	void* Argument_newFromSlice(Slice s, Argument a) { return cast(void*)(new Argument(s,a)); }
	void* Argument_newFromSliceExpr(Slice s, Expression e) { return cast(void*)(new Argument(s,e)); }
	void* Argument_newFromDotItem(Argument a, char* i) { return cast(void*)(new Argument(a,to!string(i))); }
	void* Argument_newFromDotItemExpr(Expression e, char* i) { return cast(void*)(new Argument(e,to!string(i))); }
	void* Argument_newFromFunctionWithParent(FunctionCall f, Argument a) { return cast(void*)(new Argument(f,a)); }
	void* Argument_newFromFunctionWithParentExpr(FunctionCall f, Expression e) { return cast(void*)(new Argument(f,e)); }
}

//================================================
// Functions
//================================================

class Argument
{
	string type;
	Value value;

	FunctionCall func;
	HashItem hash;
	Slice slice;
	Argument sliceArgument;
	Expression sliceExpression;
	ArrayAr arra;
	Dictionary dict;

	Position pos;

	Argument dotItem;
	Expression dotItemExpression;
	string dotItemIndex;

	Argument hashItem;
	Expression hashItemExpression;
	Expression hashItemIndex;

	this(string t, string v)
	{
		type = t;

		if ((v=="true")||(v=="yes")||(v=="~1")) value = new Value(true);
		else if ((v=="false")||(v=="no")||(v=="~0")) value = new Value(false);
		else if (t=="string") value = new Value(formatString(v));
		else if (t=="number") 
		{
			if (v.indexOf(".")!=-1) // it's a real
			{
				value = new Value(to!real(v));
			}
			else
			{
				value = new Value(formatNumber(v));
			}
		}
		else if (t=="id") value = new Value(v);
	}

	this(Argument a, string i)
	{
		type = "dotItem";
		dotItem = a;
		dotItemIndex = i;
	}

	this(Expression e, string i)
	{
		type = "dotItem";
		dotItem = null;
		dotItemExpression = e;
		dotItemIndex = i;
	}

	this (Slice s, Argument a)
	{
		slice = s;
		sliceArgument = a;
		type = "slice";
	}

	this (Slice s, Expression e)
	{
		slice = s;
		sliceExpression = e;
		sliceArgument = null;
		type = "slice";
	}

	this(FunctionCall f)
	{
		type = "function";
		func = f;
	}

	this(FunctionCall f, Argument a)
	{
		type = "function";
		Expression ex = new Expression(a);
		Expressions exs = new Expressions();
		exs.add(ex);

		foreach (Expression e; f.parameters.list)
		{
			exs.add(e);
		}

		FunctionCall fnew = new FunctionCall(f.name, exs);

		func = fnew;
	}

	this(FunctionCall f, Expression e)
	{
		type = "function";

		Expressions exs = new Expressions();
		exs.add(e);

		foreach (Expression ex; f.parameters.list)
		{
			exs.add(ex);
		}

		FunctionCall fnew = new FunctionCall(f.name, exs);

		func = fnew;
	}

	this(ArrayAr a)
	{
		type = "array";
		arra = a;
		//value = new Value(a);
	}

	this(Dictionary d)
	{
		type = "dictionary";
		dict = d;
		//value = new Value(d);
	}

	this (Argument a, Expression e)
	{
		hashItem = a;
		hashItemIndex = e;

		type = "hashitem";
	}

	this (Expression e, Expression ex)
	{
		hashItem = null;
		hashItemExpression = e;
		hashItemIndex = ex;

		type = "hashitem";
	}

	long formatNumber(string s)
	{
		if (std.algorithm.startsWith(s,"0x")==1) 		// hexadecimal
		{
			string fstr = s[2..$];
			return parse!int(fstr, 16);
		}
		else if (std.algorithm.startsWith(s,"0b")==1) 	// binary
		{
			string fstr = s[2..$];
			return parse!int(fstr, 2);
		}
		else											// decimal
		{
			return to!long(s);
		}
	}

	string formatString(string s)
	{
		string f = s;

		if (f[0]=='"') // double-quoted
		{
			f = chompPrefix(chomp(f,"\""),"\"");
			f = replace(f, "\\\"", "\"");
		}
		else
		{
			f = chompPrefix(chomp(f,"'"),"'");
			f = replace(f, "\\'", "'");
		}

		f = replace(f, "\\t", "\t");
		f = replace(f, "\\n", "\n");
		f = replace(f, "\\x1B", "\x1B");

		return f;
	}

	string parsedString(string s)
	{
		string ret = s;
		auto r = regex(r"\{:[^\}]+\}","g");

		foreach (m; match(s,r))
		{
			string hit = m.hit;

			string ident = hit.replace("{:","").replace("}","");
			
			Argument ar = new Argument("id",ident);
			Value arV = ar.getValue();
			string strV = arV.str();

			ret = ret.replace(hit,strV);
		}

		return ret;
	}

	Value getValue()
	{
		Glob.calls["argval"]++;
		Glob.calls[type]++;
		if (type=="string")
		{
			string s = value.content.s;
			string parsed = parsedString(s);

			if (s!=parsed) return new Value(parsed);
			else return value;
		}
		else if (type=="array")
		{
			return new Value(arra);
		}
		else if (type=="dictionary")
		{
			return new Value(dict);
		}
		else if (type=="id") { 
			return Glob.getSymbol(value.str());
		}
		else if (type=="dotItem")
		{
			Value aV;

			if (dotItem !is null) aV = dotItem.getValue();
			else aV = dotItemExpression.evaluate();

			if (aV.type==ValueType.dictionaryValue)
			{
				foreach (Value kk, Value vv; aV.content.d)
				{
					if (kk.str()==dotItemIndex) return new Value(vv);
				}
				throw new Exception("WTF. Key not found?");
			}
			else
				throw new Exception("WTF.");
		}
		else if (type=="hashitem")
		{
			Value hIIv = hashItemIndex.evaluate();


			Value hIv;

			if (hashItem !is null) hIv = hashItem.getValue();
			else hIv = hashItemExpression.evaluate();

			if (hIv.type==ValueType.arrayValue)
			{
				return hIv.content.a[to!int(hIIv.str())];
			}
			else if (hIv.type==ValueType.dictionaryValue)
			{
				foreach (Value kk, Value vv; hIv.content.d)
				{
					if (kk.str()==hIIv.str()) return new Value(vv);
				}
				throw new Exception("WTF. Hash not found?");
			}
			else if (hIv.type==ValueType.stringValue)
			{
				return new Value(to!string(hIv.content.s[to!int(hIIv.str())]));
			}
			else
			{
				throw new Exception("WTF. Hash...");
			}
		}
		else if (type=="slice")
		{
			Value arr;

			if (sliceArgument !is null) arr = sliceArgument.getValue();
			else arr = sliceExpression.evaluate();

			Value vL; if (slice.left !is null) vL = slice.left.evaluate(); else vL = new Value(0);
			Value vR; if (slice.right !is null) vR = slice.right.evaluate(); else 
			{
				if (arr.type==ValueType.arrayValue)
					vR = new Value(arr.content.a.length);
				else if (arr.type==ValueType.stringValue)
					vR = new Value(arr.content.s.length);
			}

			if (arr.type==ValueType.arrayValue)
			{
				Value newValue = new Value();
				newValue.type = ValueType.arrayValue;

				for (long i=vL.content.i; i<vR.content.i; i++)
				{
					newValue.content.a ~= new Value(arr.content.a[i]);
				}

				return newValue;
			}
			else if (arr.type==ValueType.stringValue)
			{
				string newValue = "";
				for (long i=vL.content.i; i<vR.content.i; i++)
				{
					newValue ~= arr.content.s[i];
				}
				return new Value(newValue);
			}
			return new Value(0);
		}
		else if (type=="function")
		{
			func.execute();
			
			return Glob.stack.pop();
		}
		else return value;

		return null;
	}

	void print()
	{
		if (type!="function")
			writeln("\t | Type: " ~ type ~ ", Value: " ~ value.str());
		else
		{
			writeln("\t | Type: " ~ type ~ ", Func: ");
			func.print();
		}
	}
}
