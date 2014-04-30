/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** loader.d
 **********************************************************/

//================================================
// Imports
//================================================

import std.stdio;
import core.stdc.stdlib;
import std.string;
import std.conv;

import components.program;
import compiler;
import globals;



//================================================
// Constants
//================================================

const string LOADER_CODE 	= import("resources/loader.lgm");

//================================================
// Functions
//================================================

void loadDefault()
{
	Program loaderProgram = compiler.compileFromString(LOADER_CODE);
	loaderProgram.execute();
}

 
 