/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** ruleDecl.d
 **********************************************************/

module ruleDecl;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import components.statement;
import components.expression;
import components.expressions;

import position;



//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* RuleDecl_new(char* n, Expressions e, Expression ex) { return cast(void*)(new RuleDecl(to!string(n),e,ex)); }

}

//================================================
// Functions
//================================================

class RuleDecl : Statement
{
	string name;
	Expressions parameters;
	Expression expression;

	Position pos;

	this(string n, Expressions e, Expression ex)
	{
		super("rule");

		name = n;
		parameters = e;
		expression = ex;
	}

	override void print()
	{
		super.print();

		writeln("\t | Name: " ~ name);
		parameters.print();
		expression.print();
	}
}
