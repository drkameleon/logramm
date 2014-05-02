/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/preprocessor.d
 **********************************************************/

module preprocessor;

//================================================
// Imports
//================================================

import std.conv;
import std.file;
import std.path;
import std.process;
import std.stdio;
import std.string;

import globals;
import panic;

//================================================
// Functions
//================================================

string preprocess(string filename)
{
	string included = "";
	foreach (string p; Glob.paths)
	{
		included ~= " -I" ~ p ~ " ";
	}

	string cmdStr = format("gcc -xc -w -E -P %s \"%s\"",included,filename);
	//writeln("PREP : |" ~ cmdStr ~ "|");

	auto cmd = executeShell(cmdStr);

	if (cmd.status != 0)
	{
		return null;
		//Panic.error("Preprocessor error.");
	}
	
	//writeln(cmd.output);
	return to!string(cmd.output);
}
