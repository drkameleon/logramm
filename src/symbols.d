/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** symbols.d
 **********************************************************/

 module symbols;

//================================================
// Imports
//================================================

import std.algorithm;
import std.stdio;
import std.file;
import std.string;
import std.conv;

import value;

//================================================
// Functions
//================================================

class Symbols
{
	Value[string] list;
	string type;

	this()
	{
		
	}

	void add(string n)
	{
		list[n] = new Value("");
	}

	void set(string n, Value v)
	{
		list[n] = new Value(v);
		//print();
	}

	Value getWithoutReference(string n)
	{
		if (exists(n))
			return new Value(list[n]);
		else 
			return null;
	}

	Value get(string n)
	{
		if (exists(n))
			return list[n];
		else 
			return null;
	}

	bool exists(string n)
	{
		return ((n in list)!=null);
	}

	void unset(string n)
	{
		if (exists(n))
			list.remove(n);

		//print();
	}

	void printItem(string n)
	{
		writefln("Symbol :: %s",n);
		writefln("Type 	 :: %s",list[n].type);
		writefln("Value  :: %s",list[n].str());
		writeln();
	}

	void print()
	{
		string[] lst;

		foreach (string f, Value v; list) lst ~= f;

		bool symbComp(string a, string b) { return a < b; }
		sort!(symbComp)(lst);

		if (lst.length>0) writeln();

		foreach (string symbName; lst)
		{
			Value symb = list[symbName];
			writeln(leftJustify(symbName,30),leftJustify(to!string(symb.type),30), symb.str());
		}
		writeln();
	}
}
