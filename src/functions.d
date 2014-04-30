/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** functions.d
 **********************************************************/

 module functions;

//================================================
// Imports
//================================================

import core.memory;
import std.stdio;
import std.file;
import std.conv;
import std.algorithm;
import std.string;

import components.functionDecl;
import components.expression;
import components.expressions;

import safety;
import value;
import panic;

//================================================
// Constants
//================================================

//================================================
// Functions
//================================================

class Functions
{
	FunctionDecl[] list;

	this()
	{
		
	}

	void add(string n)
	{
		
	}

	void set(string name, FunctionDecl f)
	{
		list ~= f;
	}
/*
	FunctionDecl get(string n)
	{
		return list[n];
	}
*/
	FunctionDecl get(string name, string mod, Expressions params, bool checkArgs = false, bool stillCountArgs = false)
	{
		Value[] passedValues;
		bool byModule = false;
		FunctionDecl[] possibleCalls;

		if (mod!="") byModule = true;

		foreach (Expression p; params.list)
		{
			if (!stillCountArgs) passedValues ~= p.evaluate();
		}

		for (int j=0; j<list.length; j++)
		{
			FunctionDecl f = list[j];

			//writeln("Checking f.name==" ~ name);

			if (byModule)
			{
				if ( (f.name==name) && (f.parentModule==mod) )
				{
					if (checkArgs)
					{
						if ( (Safety.numArgumentsMatch(passedValues, f.params)) &&
					 		 (Safety.typeArgumentsMatch(passedValues, f.params)) )
							return f;
					}
					else 
					{
						if ((stillCountArgs) && (params.list.length == f.params.length))
							return f;

						if (!stillCountArgs)
							return f;
					}
				}
			}
			else
			{
				//writeln("(2) Checking f.name : " ~ f.parentModule ~ "::" ~ f.name ~ "==" ~ name);
				if (f.name==name)
				{
					if (checkArgs)
					{
						if ( (Safety.numArgumentsMatch(passedValues, f.params)) &&
					 		 (Safety.typeArgumentsMatch(passedValues, f.params)) )
							possibleCalls ~= f;
					}
					else 
					{
						if ((stillCountArgs) && (params.list.length == f.params.length))
							possibleCalls ~= f;

						if (!stillCountArgs)
							possibleCalls ~= f;
					}
				}
			}
 		}

 		if (possibleCalls.length==1) { /*writeln("Returning");*/ return possibleCalls[0]; }
 		else if (possibleCalls.length>1)
 		{
 			string errMsg = "";

 			foreach (FunctionDecl f; possibleCalls)
 			{
 				if (f.descriptionSet && !checkArgs) return f;

 				string paramTypes;

				foreach (int k, string r; f.params)
				{
					paramTypes ~= r;
					if (k!=f.params.length-1) paramTypes ~= ", ";
				}

 				errMsg ~= f.parentModule ~ "::" ~ f.name ~ "(" ~ paramTypes ~ ") --> " ~ f.returns ~ "\n";
 			}
 			Panic.runtimeError("Unsure which function to call (" ~ to!string(possibleCalls.length) ~ " found) :\n" ~ errMsg);
 		}

 		/*writeln("Not found");*/

 		return null; // NOT FOUND
	}

	void printItem(string n)
	{
		/*
		FunctionDecl f = list[n];

		string params;

		foreach (int j, string p; f.parameters.list)
		{
			params ~= p;
			if (j!=f.parameters.list.length-1) params ~= ", ";
		}

		string paramTypes;

		foreach (int k, string r; f.params)
		{
			paramTypes ~= r;
			if (k!=f.params.length-1) paramTypes ~= ", ";
		}

		string mod;
		if (f.parentModule=="") mod = "Base";
		else mod = f.parentModule;

		writefln("Module      :: %s",mod);
		writefln("Function 	  :: %s (%s)",mod,n,params);
		writefln("Params   	  :: %s",paramTypes);
		writefln("Returns  	  :: %s",f.returns);
		writefln("Description :: %s",f.help);
		writeln();*/
	}

	FunctionDecl[] sortByName()
	{
		FunctionDecl[] ret;

		foreach (FunctionDecl f; list) ret ~= f;

		bool funcComp(FunctionDecl a, FunctionDecl b) { return ((a.parentModule < b.parentModule)||((a.parentModule == b.parentModule) && (a.name < b.name))); }
		sort!(funcComp)(ret);

		return ret;
	}

	void print()
	{
		/*
		if (list.length>0)
		{
			writefln("Available functions found : %s",to!string(list.length));
			writeln("==========================================");
		}
		*/
		FunctionDecl[] funcs = sortByName();

		string lastModule = "";
		
		foreach (FunctionDecl f; funcs)
		{
			string mod;
			if (f.parentModule=="") mod = "Base";
			else mod = f.parentModule;

			if (mod!=lastModule)
			{
				writeln("\n" ~ mod ~ " ::");
				lastModule = mod;
			}
			string params;

			foreach (int j, string p; f.parameters.list)
			{
				params ~= p;
				if (j!=f.parameters.list.length-1) params ~= ", ";
			}

			string expecting = "";

			foreach (int j, string p; f.params)
			{
				expecting ~= p;
				if (j!=f.params.length-1) expecting ~= ", ";
			}


			writefln("\t%s : %s",leftJustify(f.name ~ "(" ~ params ~ ")",50),leftJustify("("~expecting~") --> " ~ f.returns,40));
		}
		writeln();
	}
}
