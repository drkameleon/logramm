/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/cmdline.d
 **********************************************************/

module cmdline;

//================================================
// Imports
//================================================

import core.stdc.stdlib;

import std.array;
import std.getopt;
import std.stdio;
import std.string;

import panic;
import versions;

//================================================
// Types
//================================================

enum CmdAction
{
	compileAction,
	evalAction,
	interactiveAction,
	packageInstallAction,
	packageUninstallAction,
	packageInfoAction,
	helpAction,
	versionAction,
	noAction
}
 
struct CmdResult
{
	string input;
	CmdAction action;

	string[string] strOption;
	bool[string] boolOption;

	string[] argv;
}

//================================================
// Constants
//================================================

const string INCLUDE_OPT		= "include|i";
const string NOPRELOAD_OPT		= "no-preload|l";

const string EVAL_OPT			= "evaluate|e";
const string INTERACTIVE_OPT	= "interactive|r";

const string PKGINSTALL_OPT		= "package-install";
const string PKGUNINSTALL_OPT	= "package-uninstall";
const string PKGINFO_OPT		= "package-info";

const string HELP_OPT 			= "help|h";
const string VERSION_OPT		= "version|v";

const string ERR_USE_HELP		  = "Please use '--help' for more info.";
const string ERR_MULTIPLE_ACTIONS = "Multiple actions specified. " ~ ERR_USE_HELP;
const string ERR_UNRECOGNISED_ARG = "Unrecognised argument '%s'. " ~ ERR_USE_HELP;
const string ERR_REDUNDANT_ARGS   = "Redundant arguments. " ~ ERR_USE_HELP;
const string ERR_NO_ACTION		  = "No file or action specified. " ~ ERR_USE_HELP;

//================================================
// Functions
//================================================

void setIfNoAction(ref CmdAction action, CmdAction toAction)
{
	if (action==CmdAction.noAction) action = toAction;
	else Panic.error(ERR_MULTIPLE_ACTIONS);
}

CmdResult parse(string[] args)
{
	string includeOpt = "";
	bool noPreloadOpt = false;

	string evalOpt = "";
	bool interactiveOpt = false;

	string pkgInstallOpt = "";
	string pkgUninstallOpt = "";
	string pkgInfoOpt = "";

	bool helpOpt = false;
	bool versionOpt = false;

	try
	{
		getopt
		(
			args,

			std.getopt.config.caseSensitive,
			std.getopt.config.passThrough,

			INCLUDE_OPT, 		&includeOpt,
			NOPRELOAD_OPT, 		&noPreloadOpt,
			EVAL_OPT, 			&evalOpt,
			INTERACTIVE_OPT,	&interactiveOpt,
			PKGINSTALL_OPT,		&pkgInstallOpt,
			PKGUNINSTALL_OPT,	&pkgUninstallOpt,
			PKGINFO_OPT,		&pkgInfoOpt,
			HELP_OPT,			&helpOpt,
			VERSION_OPT,		&versionOpt
		);
	}
	catch (Exception e)
	{
		Panic.error(e.msg);
	}

	args.popFront(); // Remove first element (usually the binary's name), to process the rest

	CmdResult result;

	// Store options

	result.strOption[INCLUDE_OPT] = includeOpt;
	result.boolOption[NOPRELOAD_OPT] = noPreloadOpt;

	// Store action
	
	result.action = CmdAction.noAction;

	if (evalOpt!="") { 
		result.action = CmdAction.evalAction; 
		result.input = evalOpt; 
	}

	if (interactiveOpt==true) 
	{
		setIfNoAction(result.action, CmdAction.interactiveAction);
	}

	if (pkgInstallOpt!="") 
	{
		setIfNoAction(result.action, CmdAction.packageInstallAction);
		result.input = pkgInstallOpt;
	}

	if (pkgUninstallOpt!="") 
	{
		setIfNoAction(result.action, CmdAction.packageUninstallAction);
		result.input = pkgUninstallOpt;
	}

	if (pkgInfoOpt!="") 
	{
		setIfNoAction(result.action, CmdAction.packageInfoAction);
		result.input = pkgInfoOpt;
	}

	if (helpOpt==true) 
	{
		setIfNoAction(result.action, CmdAction.helpAction);
	}

	if (versionOpt==true) 
	{
		setIfNoAction(result.action, CmdAction.versionAction);
	}

	if (args.length>0)
	{
		if (result.action==CmdAction.noAction)
		{
			string possibleInput = args[0];

			if (!possibleInput.startsWith("-"))
			{
				result.input = possibleInput;
				result.action = CmdAction.compileAction;
			}
			else
				Panic.error(format(ERR_UNRECOGNISED_ARG,possibleInput));

			args.popFront();
			result.argv = args;
		}
		else
			Panic.error(ERR_REDUNDANT_ARGS);
	}
	
	if (result.action==CmdAction.noAction)
		Panic.error(ERR_NO_ACTION);

	return result;
}
