/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/dictionary.d
 **********************************************************/

module backend.dictionary;

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

class LGM_Dictionary
{
	static Value keys(Value[] v)
	{
		Value[Value] dict = v[0].content.d;
		Value[] ret;

		foreach (Value key, Value val; dict)
		{
			ret ~= key;
		}

		return new Value(ret);
	}
}
