/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/console.d
 **********************************************************/

module console;

//================================================
// Imports
//================================================

import std.array;
import std.file;
import std.path;
import std.stdio;
import std.string;

import components.program;

import compiler;
import globals;
import loader;
import versions;

//================================================
// Constants
//================================================

const string LGM_PROMPT			= "\x1B[35m$$>\x1B[0m ";
const string LGM_INTERACTIVE	= "\x1B[0m*********************************************************\n* Interactive console\n* Type any valid statement or 'exit' to quit.\n*********************************************************\n";

//================================================
// Functions
//================================================


void init(string include, bool nopreload)
{
	// Setup Globals
	Glob = new Globals();

	Glob.paths ~= dirName(getcwd);
	Glob.paths ~= include.split(",");

	Glob.interactiveMode = true;

	if (!nopreload) loader.loadDefault();

	versions.showLogo();
	writeln(LGM_INTERACTIVE);

	while (true)
	{
		write(LGM_PROMPT);
		
		auto input = strip(stdin.readln());

		bool specialCommand = false;
		
		// Special commands
		if (input=="exit") break; 
		else if (input.indexOf("?"))
		{
			if (input=="symbols?") 
			{
				Glob.symbols.print();
				specialCommand = true;
			}
			else if (input=="functions?") 
			{
				Glob.functions.print();
				specialCommand = true;
			}
			else
			{
				string item = input.chop();
				if (Glob.symbols.exists(item)) 
				{
					Glob.symbols.printItem(item);
					specialCommand = true;
				}
			}
		}

		// Treat input as valid logramm code
		if (!specialCommand)
		{
			Program base = compiler.compileFromString(input);
			base.execute();
		}

	}
}

