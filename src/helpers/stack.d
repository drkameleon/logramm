/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/helpers/stack.d
 **********************************************************/

module helpers.stack;

//================================================
// Imports
//================================================

import std.array;
import std.conv;
import std.stdio;

//================================================
// Class
//================================================

class Stack(T)
{
	T[] list;
	this()
	{

	}

	void push(T v)
	{
		list ~= v;
	}

	T pop()
	{
		if (!isEmpty())
		{
			T item = list[list.length-1];
			list.popBack();

			return item;
		}
		else
			return null;
	}

	bool isEmpty()
	{
		return list.length==0;
	}

	ulong size()
	{
		return list.length;
	}

	T lastItem()
	{
		return list[list.length-1];
	}

	void print()
	{
		writeln("-----------/--/---------STACK--------/--/-----------");
		writeln("Stack size : " ~ to!string(list.length));
		foreach (int i, T value; list)
		{
			string tabs;
			for (int j; j<=i; j++) tabs ~= "\t";
			writefln("%s : %s%s",to!string(i),tabs,to!string(value));
		}
		writeln("-----------/--/---------end-0--------/--/-----------");
	}

	void printPath()
	{
		string ret = "";
		foreach (int i, T value; list)
		{
			ret ~= to!string(value);
			if (i!=list.length-1) ret~=":";
		}
		writeln(ret);
	}
}