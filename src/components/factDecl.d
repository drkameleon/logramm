/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** factDecl.d
 **********************************************************/

module components.factDecl;

//================================================
// Imports
//================================================

import core.memory;

import std.stdio;
import std.conv;
import std.array;

import globals;

import components.argument;
import components.statement;
import components.statements;
import components.identifiers;

import components.expression;
import components.expressions;
import components.functionDecl;

import components.ifSt;
import components.boolExpression;
import components.relExpression;

import components.returnSt;

import value;
import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* FactDecl_new(char* n, Expressions e) { return cast(void*)(new FactDecl(to!string(n),e)); }
}

//================================================
// Functions
//================================================

class FactDecl : Statement
{
	string name;

	Argument[] args;

	this(string n, Expressions e)
	{
		super("factDecl");

		name = n;

		foreach (Expression x; e.list)
		{
			args ~= x.arg;
		}
	}

	void registerConstSymbols()
	{
		FunctionDecl f = Glob.functions.get(name,"",new Expressions(),false);
		
		IfSt oldIf = null;
		for (int ai=0; ai<args.length; ai++)
		{
			if (args[ai].type!="id")
			{
				Glob.consts.add(new Value(args[ai].value));
				RelExpression rel = new RelExpression(new Expression(new Argument("id",f.parameters.list[ai])), "==", new Expression(args[ai]));
				BoolExpression boo = new BoolExpression(rel,"",null);

				ReturnSt ret = new ReturnSt(new BoolExpression(new Expression(new Argument("boolean","true"))));

				IfSt newIf;

				if (oldIf is null)
				{
					oldIf = new IfSt(boo,ret,null);
				}
				else
				{
					newIf = new IfSt(boo,ret,null);
					oldIf = new IfSt(oldIf.boolExpression,newIf,null);
				}
			}
			else
			{
				RelExpression rel = new RelExpression(new Expression(new Argument("booloean","true")), "==", new Expression(new Argument("booloean","true")));
				BoolExpression boo = new BoolExpression(rel,"",null);

				ReturnSt ret = new ReturnSt(new BoolExpression(new Expression(new Argument("boolean","true"))));

				IfSt newIf;

				if (oldIf is null)
				{
					oldIf = new IfSt(boo,ret,null);
				}
				else
				{
					newIf = new IfSt(boo,ret,null);
					oldIf = new IfSt(oldIf.boolExpression,newIf,null);
				}
			}
		}

		f.statements.list.insertInPlace(0,oldIf);

		//writeln("CONSTS====>\n");
		//Glob.consts.print();
	}

	override ExecResult execute()
	{
		FunctionDecl f = Glob.functions.get(name,"",new Expressions(),false);

		string[] varSyms = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];

		if (f is null) // Fact does not exist, create it
		{
			Expressions exprs = new Expressions();

			for (int ai=0; ai<args.length; ai++)
			{
				Expression exp = new Expression(new Argument("id",varSyms[ai]));
				exprs.add(exp);
			}

			Statements stmts = new Statements();
			ReturnSt ret = new ReturnSt(new BoolExpression(new Expression(new Argument("boolean","false"))));
			stmts.add(ret);

			FunctionDecl ff = new FunctionDecl(name, exprs, stmts);

			ff.execute();

			registerConstSymbols();
		}
		else // It exists, add to it;
		{
			registerConstSymbols();
		}

		return ExecResult.Ok;
	}
}
