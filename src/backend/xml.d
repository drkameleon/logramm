/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/xml.d
 **********************************************************/

module backend.xml;

//================================================
// Imports
//================================================

import std.array;
import std.conv;
import std.stdio;
import std.string;
import std.xml;

import value;

//================================================
// Class
//================================================

class LGM_Xml
{
	static Value check(Value[] v)
	{
		string str = v[0].content.s;

		try
		{
			std.xml.check(str);

			return new Value(true);
		}
		catch (CheckException c)
		{
			return new Value(false);
		}

		return new Value(false);
	}

}
