/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/string.d
 **********************************************************/

module backend.string;

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

class LGM_String
{
	static Value length(Value[] v)
	{
		string str = v[0].content.s;

		return new Value(str.length);
	}

	static Value uppercase(Value[] v)
	{
		string str = v[0].content.s;

		return new Value(str.toUpper);
	}

	static Value lowercase(Value[] v)
	{
		string str = v[0].content.s;

		return new Value(str.toLower);
	}

	static Value trim(Value[] v)
	{
		string str = v[0].content.s;

		return new Value(str.strip());
	}

	static Value trimLeft(Value[] v)
	{
		string str = v[0].content.s;

		return new Value(str.stripLeft());
	}

	static Value trimRight(Value[] v)
	{
		string str = v[0].content.s;

		return new Value(str.stripRight());
	}

	static Value replace(Value[] v)
	{
		string str = v[0].content.s;
		string what = v[1].content.s;
		string repl = v[2].content.s;

		return new Value(str.replace(what,repl));
	}

	static Value replaceFirst(Value[] v)
	{
		string str = v[0].content.s;
		string what = v[1].content.s;
		string repl = v[2].content.s;

		return new Value(str.replaceFirst(what,repl));
	}

	static Value find(Value[] v)
	{
		string str = v[0].content.s;
		string what = v[1].content.s;

		return new Value(str.indexOf(what));
	}

	static Value chop(Value[] v)
	{
		string str = v[0].content.s;

		return new Value(str.chop());
	}

	static Value contains(Value[] v)
	{
		string str = v[0].content.s;
		string what = v[1].content.s;

		return new Value(str.indexOf(what)!=-1);
	}

	static Value isNumeric(Value[] v)
	{
		string str = v[0].content.s;

		return new Value(str.isNumeric());
	}

	static Value split(Value[] v)
	{
		string str = v[0].content.s;
		string delim = v[1].content.s;

		string[] parts = str.splitter(delim).array();
		Value[] ret;

		foreach (string part; parts)
			ret ~= new Value(part);

		return new Value(ret);
	}

	static Value soundex(Value[] v)
	{
		string str = v[0].content.s;

		string ret = "";
		foreach (char c; str.soundex())
			ret ~= c;

		return new Value(ret);
	}

	static Value startsWith(Value[] v)
	{
		string str = v[0].content.s;
		string what = v[1].content.s;

		bool ret;

		if (std.algorithm.startsWith(str,what)==1) ret = true;
		else ret = false;

		return new Value(ret);
	}

	static Value endsWith(Value[] v)
	{
		string str = v[0].content.s;
		string what = v[1].content.s;

		bool ret;

		if (std.algorithm.endsWith(str,what)==1) ret = true;
		else ret = false;

		return new Value(ret);
	}

	static Value chomp(Value[] v)
	{
		string str = v[0].content.s;

		string ret = std.string.chomp(str);

		return new Value(ret);
	}

	static Value justifyLeft(Value[] v)
	{
		string str = v[0].content.s;
		long padding = v[1].content.i;

		string ret = leftJustify(str,to!int(padding));

		return new Value(ret);
	}

	static Value justifyRight(Value[] v)
	{
		string str = v[0].content.s;
		long padding = v[1].content.i;

		string ret = rightJustify(str,to!int(padding));

		return new Value(ret);
	}

	static Value justifyCenter(Value[] v)
	{
		string str = v[0].content.s;
		long padding = v[1].content.i;

		string ret = center(str,to!int(padding));

		return new Value(ret);
	}

	// Regex

	static Value matches(Value[] v)
	{
		string str = v[0].content.s;
		string pattern = v[1].content.s;

		auto r = regex(pattern,"gm");

		if (match(str,r)) return new Value(true);
		else return new Value(false);
	}

	static Value getMatches(Value[] v)
	{
		string str = v[0].content.s;
		string pattern = v[1].content.s;

		Value[] ret;

		auto r = regex(pattern,"gm");

		foreach(m; match(str,r)) 
		{
			string hit = m.hit;

			ret ~= new Value(hit);
		}

		return new Value(ret);
	}

	static Value preMatch(Value[] v)
	{
		string str = v[0].content.s;
		string pattern = v[1].content.s;

		auto r = regex(pattern,"gm");
		auto m = match(str,r);
		auto c = m.captures;

		string ret = to!string(c.pre);

		return new Value(ret);
	}

	static Value postMatch(Value[] v)
	{
		string str = v[0].content.s;
		string pattern = v[1].content.s;

		auto r = regex(pattern,"gm");
		auto m = match(str,r);
		auto c = m.captures;

		string ret = to!string(c.post);

		return new Value(ret);
	}

	static Value xreplaceFirst(Value[] v)
	{
		string str = v[0].content.s;
		string pattern = v[1].content.s;
		string repl = v[2].content.s;

		auto r = regex(pattern,"gm");
		string ret = std.regex.replaceFirst(str, r, repl);

		return new Value(ret);
	}

	static Value replaceAll(Value[] v)
	{
		string str = v[0].content.s;
		string pattern = v[1].content.s;
		string repl = v[2].content.s;

		auto r = regex(pattern,"gm");
		string ret = std.regex.replaceAll(str, r, repl);

		return new Value(ret);
	}

	static Value regexSplit(Value[] v)
	{
		string str = v[0].content.s;
		string pattern = v[1].content.s;

		auto r = regex(pattern,"gm");
		string[] parts = splitter(str, r).array();

		Value[] ret;

		foreach (string part; parts)
			ret ~= new Value(part);

		return new Value(ret);
	}
}
