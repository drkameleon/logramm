/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** functionDesc.d
 **********************************************************/

module components.functionDesc;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;
import std.string;
import std.array;

import globals;

import components.statement;
import components.statements;
import components.identifiers;

import components.expression;
import components.expressions;
import components.functionDecl;

import value;

import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* FunctionDesc_new(char* n, Expressions i, Expression d) { return cast(void*)(new FunctionDesc(to!string(n),i,d)); }

}

//================================================
// Functions
//================================================

class FunctionDesc : Statement
{
	string name;
	Identifiers parameters;
	Value description;
	string[] params;
	string returns;
	string help;
	Expression expression;

	Position pos;

	this(string n, Expressions i, Expression d)
	{
		this(n, new Identifiers(i), d);
	}

	this(string n, Identifiers i, Expression d)
	{
		super("functionDesc");

		name = n;
		parameters = i;

		expression = d;

		//writeln("Create a functionDesc : " ~ name);
	}

	override void print()
	{
		super.print();
	}

	override ExecResult execute()
	{
		//writeln("Executing functionDesc : " ~ name);
		description = expression.evaluate();

		returns = "";
		params = [];
		help = "";

		foreach (Value key, Value val; description.content.d)
		{
			if (key.str()=="returns") returns = val.str();
			else if (key.str()=="help") help = val.str();
			else if (key.str()=="params") 
			{
				if (val.str()=="no") params = []; 
				else params = val.str().splitter(",").array();
			}
		}
		Expressions exprs = new Expressions();
		for (int xc=0; xc<parameters.list.length; xc++)
		{
			exprs.add(new Expression());
		}
		string parentModule = "";
		if (Glob.currentModule !is null) parentModule = Glob.currentModule.name;
		//writeln("PRE DESC");
		FunctionDecl f = Glob.functions.get(name,parentModule,exprs,false,true);
		//writeln("Executing functionDesc : after");
		f.params = params;
		f.returns = returns;
		f.help = help;
		f.descriptionSet = true;
		//Glob.functions.print();
		//Glob.functions.set(name,f);
		//writeln("Executing functionDesc : after");

		return ExecResult.Ok;
	}
}
