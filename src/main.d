/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/main.d
 **********************************************************/

//================================================
// Imports
//================================================

import core.memory;
import std.stdio;

import library.cgi;
import cmdline;

import compiler;
import console;
import packager;
import versions;

//================================================
// Where the magic begins...
//================================================

void main(string[] args)
{
	GC.disable();
	
	Cgi cgi = new Cgi();

	if (cgi.isActive) 
	{
		compiler.initCgi(cgi);
	}
	else
	{
		CmdResult cmdResult = cmdline.parse(args);

		string input   = cmdResult.input;
		string[] argv  = cmdResult.argv;

		string include = cmdResult.strOption[INCLUDE_OPT];
		bool noPreload = cmdResult.boolOption[NOPRELOAD_OPT];

		switch (cmdResult.action)
		{
			case CmdAction.compileAction			:	compiler.init(input, argv, include, noPreload); break;
			case CmdAction.evalAction				:	compiler.initEval(input, include, noPreload); break;

			case CmdAction.interactiveAction		:	console.init(include, noPreload); break;

			case CmdAction.packageInstallAction 	: 	packager.install(input); break;
			case CmdAction.packageUninstallAction 	: 	packager.uninstall(input); break;
			case CmdAction.packageInfoAction 		: 	packager.info(input); break;

			case CmdAction.helpAction 				: 	versions.showHelp(); break;
			case CmdAction.versionAction 			: 	versions.showLogo(); break;

			default:
		}
	}
}
