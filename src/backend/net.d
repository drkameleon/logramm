/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/net.d
 **********************************************************/

module backend.net;

//================================================
// Imports
//================================================

import std.array;
import std.conv;
import std.file;
import std.net.curl;
import std.stdio;
import std.string;

import value;

//================================================
// Class
//================================================

class LGM_Net
{
	static Value get(Value[] v)
	{
		string url = v[0].content.s;

		string contents = to!string(std.net.curl.get(url));

		return new Value(contents);
	}

	static Value post(Value[] v)
	{
		string url = v[0].content.s;
		string data = v[1].content.s;

		string contents = to!string(std.net.curl.post(url,data));

		return new Value(contents);
	}

	static Value download(Value[] v)
	{
		string url = v[0].content.s;
		string filepath = v[1].content.s;

		std.net.curl.download(url,filepath);

		return new Value(0);
	}
}
