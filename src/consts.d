/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** consts.d
 **********************************************************/

 module consts;

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

class Consts
{
	Value[] list;
	string type;

	this()
	{
		
	}

	void add(Value v)
	{
		if (!exists(v))
			list ~= v;
	}

	bool exists(Value v)
	{
		foreach (Value i; list)
		{
			if (i.str()==v.str()) return true;
		}
		return false;
	}

	void print()
	{
		foreach (Value v; list)
		{
			writeln("Const : " ~ v.str());
		}
	}
}
