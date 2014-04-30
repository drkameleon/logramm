/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/types.d
 **********************************************************/

module backend.types;

//================================================
// Imports
//================================================

import std.algorithm;
import std.array;
import std.conv;
import std.regex;
import std.stdio;
import std.string;

import value;

//================================================
// Class
//================================================

class LGM_Types
{
	static Value getType(Value[] v)
	{
		Value v1 = v[0];

		string ret = replace(to!string(v1.type),"Value","");

		return new Value(ret);
	}
}
