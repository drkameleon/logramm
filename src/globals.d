/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** globals.d
 **********************************************************/

 module globals;

//================================================
// Imports
//================================================

import std.stdio;
import std.file;
import std.algorithm;
import etc.c.sqlite3;

import library.stack;

import databases;
import symbols;
import functions;
import rules;
import consts;
import components.moduleSt;
import components.statement;

import value;

//================================================
// Constants
//================================================

const string LGM_NAME 			= "Logramm";
const string LGM_VERSION 		= "02";
const string LGM_COPYRIGHT 		= "2009-2014";
const string LGM_AUTHOR 		= "Dr.Kameleon";
const string LGM_BUILD			= import("resources/build.txt");

const string LGM_LOGO 			= "\x1B[32m\x1B[1m"~LGM_NAME~"/"~LGM_VERSION~"\x1B[0m\nBuild/0" ~ LGM_BUILD ~"\n(c) "~LGM_COPYRIGHT~" "~LGM_AUTHOR~"\n";

const string LGM_PATH_LIB		= "/usr/lib/lgm";

//================================================
// Super-globals
//================================================

Globals Glob;

//================================================
// Functions
//================================================

class Globals
{
	string currentPath;
	string[] paths;

	Symbols symbols;
	Symbols localSymbols;
	Functions functions;
	Rules rules;

	Module currentModule;

	Stack!(Value) stack;

	bool interactiveMode;

	Statement currentStatement;

	Stack!(string) executionStack;

	string[] alreadyImported;

	bool cgiMode;

	Databases databases;

	int[string] calls;

	Consts consts;

	int retCounter;
	int breakCounter;

	this()
	{
		currentPath = getcwd();
		paths ~= LGM_PATH_LIB;

		symbols = new Symbols();
		functions = new Functions();
		rules = new Rules();

		stack = new Stack!(Value);

		localSymbols = null;

		interactiveMode = false;

		currentModule = null;

		currentStatement = null;

		executionStack = new Stack!(string);

		alreadyImported = [];

		cgiMode = false;

		databases = new Databases();

		consts = new Consts();

		retCounter = -1;
		breakCounter = -1;
	}

	Value getSymbolWithoutReference(string n)
	{
		Value vS = symbols.getWithoutReference(n);
		Value vL=null;
		if (localSymbols !is null) vL=localSymbols.getWithoutReference(n);

		if (vL !is null) return new Value(vL);
		if (vS !is null) return new Value(vS);
		else
		{
			/* ERROR : Symbol not found */
			return null;
		}
	}

	Value getSymbol(string n)
	{
		Value vv;
		if (localSymbols !is null)
		{
			vv = localSymbols.get(n);

			if (vv !is null) return vv;
			else 
			{
				//writeln("I was looking for " ~ n);
				//localSymbols.print();
				throw new Exception("Ooops : '" ~ n ~ "' not found in local symbols");
			}
		}
		else
		{
			vv = symbols.get(n);

			

			if (vv !is null) return vv;
			else throw new Exception("Ooops : '" ~ n ~ "' not found in global symbols");
		}
		return null; // won't reach here;
		/*
		Value vS = symbols.get(n);
		Value vL=null;
		if (localSymbols !is null) vL=localSymbols.get(n);

		if (vL !is null) return vL;
		if (vS !is null) return vS;
		else
		{
			// ERROR : Symbol not found
			return null;
		}*/
	}

	string[] fullPaths()
	{
		string[] list;

		foreach (string path; paths) 
		{
			if (startsWith(path,"/")) list ~= path;
			else list ~= currentPath ~ "/" ~ path;
		}

		return list;
	}

	void registerVariable(string name, string value)
	{
		symbols.set(name, new Value(value));
	}

	void registerVariable(string name, string[] values)
	{
		Value[] arr;

		foreach (string value; values)
		{
			arr ~= new Value(value);
		}

		symbols.set(name,new Value(arr));
	}

	void registerVariable(string name, string[string] values)
	{
		Value[Value] dict;

		foreach (string key, string value; values)
		{
			dict[new Value(key)] = new Value(value);
		}

		symbols.set(name, new Value(dict));
	}
}
