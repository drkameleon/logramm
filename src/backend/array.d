/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/array.d
 **********************************************************/

module backend.array;

//================================================
// Imports
//================================================

import std.array;
import std.stdio;
import std.string;

import value;

//================================================
// Class
//================================================

class LGM_Array
{
	static Value count(Value[] v)
	{
		Value[] arr = v[0].content.a;

		return new Value(arr.length);
	}
}
