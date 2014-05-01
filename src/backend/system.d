/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/string.d
 **********************************************************/

module backend.system;

//================================================
// Imports
//================================================

import std.process;

import value;

//================================================
// Class
//================================================

class LGM_System
{
	static Value execute(Value[] v)
	{
		string cmdStr = v[0].content.s;

		auto cmd = executeShell(cmdStr);
		if (cmd.status != 0) 
			return new Value(false);
		else
			return new Value(cmd.output);
	}
}
