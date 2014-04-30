
/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** tester.d
 **********************************************************/

 module tester;

//================================================
// Imports
//================================================

import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.file;

import components.program;
import compiler;

import globals;

import value;

//================================================
// Functions
//================================================

class Tester
{
	static void emulate(string testname, string code, string output)
	{
		write(leftJustify("- Testing " ~ testname ~ "... ", 50));

		auto original = stdout;
		string emfile = "tmp/test.out";
		stdout.open(emfile, "wt");

		Glob = new Globals();

		Program base = compiler.compileFromString(code);
		base.execute();

		stdout = original;

		string response = to!string(std.file.read(emfile));

		if (response==output) writeln("OK");
		else 
		{ 
			writeln("*** FAILED ***");
			writeln(response);
		}
	}
}
