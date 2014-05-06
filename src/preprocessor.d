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
import library.warp.file;
import library.warp.textbuf;
import library.warp.context;
import library.warp.cmdline;
import library.warp.sources;

//================================================
// Functions
//================================================

string preprocess(string filename)
{
	return library.warp.omain.start(["",filename]);
}
