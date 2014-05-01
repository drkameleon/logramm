/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** safety.d
 **********************************************************/

 module safety;

//================================================
// Imports
//================================================

import std.stdio;
import std.file;
import std.conv;

import panic;

import components.functionDecl;
import components.expression;
import components.expressions;

import value;

//================================================
// Constants
//================================================

//================================================
// Functions
//================================================

class Safety
{
	static bool numArgumentsMatch(Value[] v, string[] t)
	{
		if (v.length==t.length) { 
			// writeln("numArgumentsMatch : true"); 
		}
		else {
			// writefln("numArgumentsMatch : false, v.l = %s, t.l = %s",to!string(v.length),to!string(t.length) );
		}
		return (v.length == t.length);
	}

	static bool typeArgumentsMatch(Value[] v, string[] t)
	{
		for (int j=0; j<v.length; j++)
		{
			if (!checkType(v[j], t[j])) { /*writefln("typeArgumentsMatch :==> false. Found : %s, Expected : %s",v[j].type,t[j]);*/ return false; }
		}

		//writeln("typeArgumentsMatch :==> true");
		return true;
	}

	static bool checkType(Value v, string t)
	{
		if ((t is null)||(t=="")) return true;

		if (t=="any") return true;
		
		if ((v.type==ValueType.numberValue) && (t=="number")) return true;
		else if ((v.type==ValueType.realValue) && (t=="number")) return true;
		else if ((v.type==ValueType.stringValue) && (t=="string")) return true;
		else if ((v.type==ValueType.booleanValue) && (t=="boolean")) return true;
		else if ((v.type==ValueType.arrayValue) && (t=="array")) return true;
		else if ((v.type==ValueType.dictionaryValue) && (t=="dictionary")) return true;
		else
			return false;
	}

	static Value[] checkFunctionCallAndEvaluateParameters(FunctionDecl f, Expressions e)
	{
		// Check if equal number of params
		if (e.list.length!=f.parameters.list.length) 
			Panic.runtimeError("Wrong number of arguments for : " ~ f.name ~ ". Expected : " ~ to!string(f.parameters.list.length));

		// Check param types one by one
		Value[] ret = [];
		for (int i=0; i<e.list.length; i++)
		{
			Expression eX = e.list[i];
			Value eV = eX.evaluate();
			ret ~= eV;

			if ((i<f.params.length)&&(f.params[i] !is null))
			{
				if (!checkType(eV,f.params[i])) 
					Panic.runtimeError("Wrong argument for : " ~ f.name ~ ". Expected : " ~ f.params[i]);
			}
		}

		// Return calculated values,
		// so that we save some time
		return ret;
	}
}
