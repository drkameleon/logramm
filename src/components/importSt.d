/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** importSt.d
 **********************************************************/

module components.importSt;

//================================================
// Imports
//================================================

import std.array;
import std.conv;
import std.file;
import std.path;
import std.stdio;
import std.string;

import library.file;

import globals;
import panic;
import compiler;
import components.statement;
import components.program;

import position;

//================================================
// Constants
//================================================

const string LIBRARY_NOT_FOUND_MSG = "Library '%s' not found\n\n              | In paths:\n              | %s";

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* ImportSt_new(char* n) { return cast(void*)(new ImportSt(to!string(n))); }
	void* ImportSt_newMultiple(char* n) { return cast(void*)(new ImportSt(to!string(n),true)); }

}

//================================================
// Functions
//================================================

class ImportSt : Statement
{
	string name;

	Position pos;

	bool multiple;

	this(string n, bool mult=false)
	{
		super("import");

		name = replace(n,"|","/");
		multiple = mult;
	}

	override ExecResult execute()
	{
		//writeln("IMPORTING");
		if (!multiple)
		{
			name ~= ".lgm";

			string filepath = searchFileInPaths(name, Glob.paths);
			if (filepath==name) Panic.runtimeError(format(LIBRARY_NOT_FOUND_MSG, name, join(Glob.fullPaths(),"\n              | ")));

			//writeln(Glob.alreadyImported);

			bool alreadyImported = false;
			foreach (string p; Glob.alreadyImported)
				if (p==filepath) alreadyImported = true;

			if (!alreadyImported) 
			{ 
				Glob.alreadyImported ~= filepath;

				Program subprogram = compiler.compile(filepath);

				if (subprogram.statements is null) writeln("WHOA! Statements is null?!");

				subprogram.execute();
			}
		}
		else
		{
			string filepath = searchFileInPaths(name, Glob.paths);
			if (filepath==name) Panic.runtimeError(format(LIBRARY_NOT_FOUND_MSG, name, join(Glob.fullPaths(),"\n              | ")));

			foreach (string n; dirEntries(filepath, SpanMode.depth))
			{
				if ((isFile(n)) && (extension(n)==".lgm"))
				{
					bool alreadyImported = false;

					foreach (string p; Glob.alreadyImported)
						if (p==filepath) alreadyImported = true;

					if (!alreadyImported) 
					{ 
						Glob.alreadyImported ~= n;

						Program subprogram = compiler.compile(n);

						if (subprogram.statements is null) writeln("WHOA! Statements is null?!");

						subprogram.execute();
					}
				}
			}
		}

		return ExecResult.Ok;
	}

	override void print()
	{
		super.print();

		writeln("\t | Name : " ~ name);
	}
}
