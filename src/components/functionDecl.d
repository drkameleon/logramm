/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** functionDecl.d
 **********************************************************/

module components.functionDecl;

//================================================
// Imports
//================================================

import core.memory;

import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.string;

import globals;

import components.statement;
import components.statements;
import components.identifiers;
import components.dictionary;
import components.expression;
import components.expressions;

import value;
import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* FunctionDecl_new(char* n, Expressions i, Statements s) { return cast(void*)(new FunctionDecl(to!string(n),i,s)); }
	void* FunctionDecl_newWithDesc(char* n, Expressions i, Statements s, Dictionary d) { return cast(void*)(new FunctionDecl(to!string(n),i,s,d)); }
	void* FunctionDecl_newFromReference(char* n, Expressions i, Expression r) { return cast(void*)(new FunctionDecl(to!string(n),i,r)); }
	void* FunctionDecl_newFromReferenceWithDesc(char* n, Expressions i, Expression r, Dictionary d) { return cast(void*)(new FunctionDecl(to!string(n),i,r,d)); }

}

//================================================
// Functions
//================================================

class FunctionDecl : Statement
{
	string name;
	Identifiers parameters;
	Statements statements;
	string reference;

	string[] params;
	string returns;
	string help;

	string parentModule;

	bool descriptionSet;

	Position pos;
/*
	this(string n,FunctionDecl f)
	{
		name = f.name;
		parameters = f.parameters;
		statements = f.statements;
		reference = f.reference;
		params = f.params;
		returns = f.returns;
		help = f.help;
		parentModule = f.parentModule;
		descriptionSet = f.descriptionSet;
		pos = f.pos;
	}
*/
	this(string n, Expressions i, Statements s, Dictionary d)
	{
		this(n, new Identifiers(i), s);

		Value v = new Value(d);

		if (v.getValueFromDict("params") !is null)
		params = v.getValueFromDict("params").str().splitter(",").array();

		if (v.getValueFromDict("returns") !is null)
		returns = v.getValueFromDict("returns").str();

		if (v.getValueFromDict("help") !is null)
		help = v.getValueFromDict("help").str();
	}

	this(string n, Expressions i, Statements s)
	{
		this(n, new Identifiers(i), s);
	}

	this(string n, Expressions i, Expression r, Dictionary d)
	{
		this(n, new Identifiers(i), r);

		Value v = new Value(d);

		if (v.getValueFromDict("params") !is null)
		params = v.getValueFromDict("params").str().splitter(",").array();

		if (v.getValueFromDict("returns") !is null)
		returns = v.getValueFromDict("returns").str();

		if (v.getValueFromDict("help") !is null)
		help = v.getValueFromDict("help").str();
	}

	this(string n, Expressions i, Expression r)
	{
		this(n, new Identifiers(i), r);
	}

	this(string n, Identifiers i, Statements s)
	{
		super("function");

		name = n;
		parameters = i;
		statements = s;

		reference = "";

		parentModule = "";

		for (int j=0; j<parameters.list.length; j++)
		{
			params ~= "any";
		}
		returns = "any";
		help = "";

		descriptionSet = false;
		//writeln("Create a functionDecl : " ~ name);
	}

	this(string n, Identifiers i, Expression r)
	{
		super("function_ref");

		name = n;
		parameters = i;
		statements = null;

		Value v = r.evaluate();
		reference = v.content.s;

		for (int j=0; j<parameters.list.length; j++)
		{
			params ~= "any";
		}
		returns = "any";
		help = "";

		parentModule = "";

		descriptionSet = false;
		//writeln("Create a functionDecl (by Reference) : " ~ name);
	}

	override void print()
	{
		super.print();

		writeln("\t | Name: " ~ name);
		parameters.print();
		statements.print();
	}

	override ExecResult execute()
	{
		//writeln("Executing functionDecl : " ~ name);
		if (Glob.currentModule !is null) parentModule = Glob.currentModule.name;
		//GC.addRoot(cast(void*)this);
		//writeln("Before setting... " ~ name);
		//GC.disable();

		Glob.functions.set(name,this);


		//GC.enable();
		//writeln("After setting." ~ name);
		//writeln("After setting func..." ~ name);
		//Glob.functions.print();

		return ExecResult.Ok;
	}
}
