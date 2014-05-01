/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/path.d
 **********************************************************/

module backend.path;

//================================================
// Imports
//================================================

import std.algorithm;
import std.array;
import std.conv;
import std.file;
import std.path;
import std.stdio;
import std.string;

import value;

//================================================
// Class
//================================================

class LGM_Path
{
	static Value isFile(Value[] v)
	{
		string filepath = v[0].content.s;

		bool ret = filepath.isFile();

		return new Value(ret);
	}

	static Value isDirectory(Value[] v)
	{
		string filepath = v[0].content.s;

		bool ret = filepath.isDir();

		return new Value(ret);
	}

	static Value isSymlink(Value[] v)
	{
		string filepath = v[0].content.s;

		bool ret = filepath.isSymlink();

		return new Value(ret);
	}

	static Value createDirectory(Value[] v)
	{
		string filepath = v[0].content.s;

		std.file.mkdir(filepath);

		return new Value(0);
	}

	static Value currentDirectory(Value[] v)
	{
		string ret = std.file.getcwd();

		return new Value(ret);
	}

	static Value directoryContents(Value[] v)
	{
		string dir = v[0].content.s;

		Value[] ret;

		auto preDirs = std.file.dirEntries(dir, SpanMode.breadth);
		string[] dirs;

		foreach( string d; preDirs) dirs ~= d;

		bool symbComp(string a, string b) { return a < b; }
		sort!(symbComp)(dirs);

		foreach (string name; dirs)
		{
			ret ~= new Value(name);
		}

		return new Value(ret);
	}

	static Value directorySeparator(Value[] v)
	{
		return new Value(dirSeparator);
	}

	static Value filename(Value[] v)
	{
		string filepath = v[0].content.s;

		string ret = baseName(filepath);

		return new Value(ret);
	}

	static Value directory(Value[] v)
	{
		string filepath = v[0].content.s;

		string ret = dirName(filepath);

		return new Value(ret);
	}

	static Value extension(Value[] v)
	{
		string filepath = v[0].content.s;

		string ret = std.path.extension(filepath);

		return new Value(ret);
	}

	static Value withoutExtension(Value[] v)
	{
		string filepath = v[0].content.s;

		string ret = stripExtension(filepath);

		return new Value(ret);
	}

	static Value normalized(Value[] v)
	{
		string filepath = v[0].content.s;

		string ret = buildNormalizedPath(filepath);

		return new Value(ret);
	}

	static Value expandTilde(Value[] v)
	{
		string filepath = v[0].content.s;

		string ret = std.path.expandTilde(filepath);

		return new Value(ret);
	}
}
