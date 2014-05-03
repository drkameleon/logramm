/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/versions.d
 **********************************************************/

module versions;

//================================================
// Imports
//================================================

import std.stdio;

//================================================
// Constants
//================================================

const string LGM_NAME 			= "Logramm";
const string LGM_VERSION 		= "03";
const string LGM_COPYRIGHT 		= "2009-2014";
const string LGM_AUTHOR 		= "Dr.Kameleon";
const string LGM_BUILD			= import("resources/build.txt");

const string LGM_LOGO 			= "\x1B[32m\x1B[1m"~LGM_NAME~"/"~LGM_VERSION~"\x1B[0m\nBuild/0" ~ LGM_BUILD ~"\n(c) "~LGM_COPYRIGHT~" "~LGM_AUTHOR~"\n";

//================================================
// Functions
//================================================

void showLogo()
{
	writeln(LGM_LOGO);
}

void showHelp()
{
	showLogo();

	string helpText = import("resources/logramm.hlp");
	writeln(helpText);
}
