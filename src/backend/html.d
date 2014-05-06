/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/html.d
 **********************************************************/

module backend.html;

//================================================
// Imports
//================================================

import std.array;
import std.conv;
import std.json;
import std.stdio;
import std.string;

import value;

//================================================
// Class
//================================================

class LGM_Html
{
	static Value parse(Value[] v)
	{
		string str = v[0].content.s;

		string buffer = "";
		string ret = "";
		bool codeMode = false;
		string slice;
		string[] lines;
		bool toOut = false; 

		for (ulong i=0; i<str.length; i++)
		{
			buffer ~= str[i];
			slice = str[i..$];

			if ((std.algorithm.startsWith(slice,"<%")) && !codeMode)
			{
				if (std.algorithm.startsWith(slice,"<%=")) toOut = true;
				else toOut = false;

				lines = buffer[0..$-1].splitter("\n").array();
				foreach (string line; lines)
				{
					if (line!="")
						ret ~= "out '" ~ line.replace("'","\\'") ~ "';\n";
				}
				buffer = "";
				codeMode = true;
				i+= 1 + toOut;
			}

			else if ((std.algorithm.startsWith(slice,"%>")==1) && codeMode)
			{
				lines = buffer[0..$-1].splitter("\n").array();
				foreach (string line; lines)
				{
					if (!toOut)
						ret ~= line.strip() ~ "\n";
					else
						ret ~= "out " ~ line.strip() ~ ";\n";
				}

				buffer = "";
				codeMode = false;
				i+=1;
			}

		}
		buffer ~= str[str.length-1];
		lines = buffer[0..$-1].splitter("\n").array();
		foreach (string line; lines)
		{
			if (line!="")
				ret ~= "out '" ~ line ~ "';\n";
		}

		return new Value(ret);
	}

}
