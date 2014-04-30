/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/file.d
 **********************************************************/

module backend.file;

//================================================
// Imports
//================================================

import std.array;
import std.conv;
import std.file;
import std.stdio;
import std.string;

import value;

//================================================
// Class
//================================================

class LGM_File
{
	static Value read(Value[] v)
	{
		string filename = v[0].content.s;

		string contents = to!string(std.file.read(filename));

		return new Value(contents);
	}

	static Value write(Value[] v)
	{
		string filename = v[0].content.s;
		string data = v[1].content.s;

		std.file.write(filename, data);

		return new Value(0);
	}

	static Value append(Value[] v)
	{
		string filename = v[0].content.s;
		string data = v[1].content.s;

		std.file.append(filename, data);

		return new Value(0);
	}

	static Value rename(Value[] v)
	{
		string filename = v[0].content.s;
		string new_filename = v[1].content.s;

		std.file.rename(filename, new_filename);

		return new Value(0);
	}

	static Value deleteFile(Value[] v)
	{
		string filename = v[0].content.s;

		std.file.remove(filename);

		return new Value(0);
	}

	static Value exists(Value[] v)
	{
		string filename = v[0].content.s;

		bool ret = std.file.exists(filename);

		return new Value(ret);
	}
}
