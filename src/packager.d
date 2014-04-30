/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/packager.d
 **********************************************************/

module packager;

//================================================
// Imports
//================================================

import std.algorithm;
import std.array;
import std.conv;
import std.file;
import std.net.curl;
import std.stdio;
import std.string;

import globals;
import versions;

//================================================
// Constants
//================================================

const string SERVER_URL = "http://83.212.101.132/packages/server-api.php?";

const string PKG_INFO   = "action=info&query=";
const string PKG_FILES  = "action=files&query=";
const string PKG_GET	= "action=get&query=";

const string PKG_PROMPT	= "\x1B[35mPackageManager>\x1B[0m ";

//================================================
// Functions
//================================================

void install(string p)
{
	versions.showLogo();

	writeln(PKG_PROMPT ~ "Connecting to Package server...");
	string contents = strip(to!string(std.net.curl.get(SERVER_URL ~ PKG_INFO ~ p)));

	if (contents.indexOf("not found")!=-1)
	{
		writeln(PKG_PROMPT ~ "Error: " ~ contents);
		writeln(PKG_PROMPT ~ "Done.");
		exit(0);
	}

	writeln(PKG_PROMPT ~ "Resolving dependencies...");
	contents = strip(to!string(std.net.curl.get(SERVER_URL ~ PKG_FILES ~ p)));

	string[] files = contents.splitter("\n").array();

	foreach (int index, string f; files)
	{
		writeln(PKG_PROMPT ~ "[" ~ to!string(index+1) ~ "] Fetching package : " ~ f);

		string fcontents = strip(to!string(std.net.curl.get(SERVER_URL ~ PKG_GET ~ f)));

		std.file.write(f ~ ".lgm", fcontents);
	}

	writeln(PKG_PROMPT ~ "Installing...");
	foreach (int index, string f; files)
	{
		string[] parts = f.splitter(".").array();

		string folder = LGM_PATH_LIB;
		string fname = parts[parts.length-1];
		for (int i=0; i<parts.length-1; i++)
		{
			folder ~= "/" ~ parts[i];
			if (!std.file.exists(folder))
				std.file.mkdir(folder);
		}
		std.file.copy(f~".lgm",folder~"/"~fname~".lgm");
	}

	writeln(PKG_PROMPT ~ "Cleaning up...");
	foreach (int index, string f; files)
	{
		std.file.remove(f~".lgm");
	}
	writeln(PKG_PROMPT ~ "Done.");
}

void uninstall(string p)
{
	versions.showLogo();

	writeln(PKG_PROMPT ~ "Removing package...");
	string packagefile = LGM_PATH_LIB ~ "/" ~ replace(p,".","/") ~ ".lgm";
	if (!std.file.exists(packagefile))
	{
		writeln(PKG_PROMPT ~ "Error: Package '" ~ p ~ "' is not installed");
	}
	else
	{
		std.file.remove(packagefile);
	}
	writeln(PKG_PROMPT ~ "Done.");
}

void info(string p)
{
	versions.showLogo();

	try
	{
		writeln(PKG_PROMPT ~ "Connecting to Package server...");
		string contents = strip(to!string(std.net.curl.get(SERVER_URL ~ PKG_INFO ~ p)));

		if (contents.indexOf("not found")!=-1)
		{
			writeln(PKG_PROMPT ~ "Error: " ~ contents);
			writeln(PKG_PROMPT ~ "Done.");
		}
		else
		{
			writeln("\n" ~ contents ~ "\n");
		}
	}
	catch (Exception e)
	{
		writeln(PKG_PROMPT ~ "Error: " ~ e.msg);
		writeln(PKG_PROMPT ~ "Done.");
	}
}
