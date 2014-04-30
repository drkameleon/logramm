/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** panic.d
 **********************************************************/

//================================================
// Imports
//================================================

import std.stdio;
import core.stdc.stdlib;
import std.string;
import std.conv;

import globals;

import position;

//================================================
// Constants
//================================================

const string RUNTIME_ERROR_TEMPLATE 	= "\x1B[31mRuntime Error \x1B[37m| ";
const string RUNTIME_ERROR_POS_TEMPLATE = "\x1B[31mRuntime Error \x1B[37m| \x1B[0mFile:\x1B[37m %s\n              | \x1B[0mLine:\x1B[37m %d\n\n              | %s\n\n";

const string RUNTIME_ERROR_TEMPLATE_HTML  	= import("resources/error_template.html");
const string RUNTIME_ERROR_POS_TEMPLATE_HTML = import("resources/error_template_with_pos.html");

const string ERROR_TEMPLATE 			= "\x1B[31mError         \x1B[37m| ";
const string WARNING_TEMPLATE 			= "\x1B[31mWarning       \x1B[37m| ";
const string NOTICE_TEMPLATE 			= "\x1B[33mNotice        \x1B[37m| ";

//================================================
// Functions
//================================================

class Panic
{
	static void runtimeError(string msg)
	{
		string useTemplate;

		if (Glob.cgiMode) useTemplate = RUNTIME_ERROR_TEMPLATE_HTML;
		else useTemplate = RUNTIME_ERROR_TEMPLATE;

		writeln(useTemplate ~ msg ~"\n");

		exit(0);
	}

	static void runtimeErrorAtPosition(string msg, Position pos)
	{
		string useTemplate;

		if (Glob.cgiMode) useTemplate = RUNTIME_ERROR_POS_TEMPLATE_HTML;
		else useTemplate = RUNTIME_ERROR_POS_TEMPLATE;

		writeln(format(useTemplate, pos.filename, pos.line+1, msg));

		exit(0);
	}

	static void error(string msg)
	{
		writeln(ERROR_TEMPLATE ~ msg ~"\n");
		exit(0);
		//if (!Glob.interactiveMode) exit(0);
	}

	static void warning(string msg)
	{
		writeln(WARNING_TEMPLATE ~ msg ~"\n");
	}

	static void notice(string msg)
	{
		writeln(NOTICE_TEMPLATE ~ msg ~"\n");
	}
}

