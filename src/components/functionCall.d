/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** functionCall.d
 **********************************************************/

module components.functionCall;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import globals;

import components.expressions;
import components.functionDecl;
import components.expression;
import components.argument;
import components.statement;

import symbols;
import value;

import backends;
import safety;
import panic;
import position;

import errors;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* FunctionCall_new(char* n, Expressions e) { return cast(void*)(new FunctionCall(to!string(n),e)); }
	void* FunctionCall_newWithModule(char* m, FunctionCall f) { return cast(void*)(new FunctionCall(to!string(m),f)); }

}

//================================================
// Functions
//================================================

class FunctionCall
{
	string name;
	string parentModule;
	Expressions parameters;
	Symbols localSymbols;
	Symbols oldSymbols;
	Position pos;

	this(string n, Expressions e)
	{
		name = n;
		parameters = e;
		localSymbols = new Symbols();
		parentModule = "";
	}

	this(string m, FunctionCall f)
	{
		name = f.name;
		parameters = f.parameters;
		localSymbols = new Symbols();
		parentModule = m;
	}

	void print()
	{
		writeln("\t | Name: " ~ name);
		parameters.print();
	}

	int isFactQuestion()
	{
		for (int i=0; i<parameters.list.length; i++)
		{
			Expression expr = parameters.list[i];

			if (expr.arg is null) return -1;
			if ((expr.arg.type=="id") && (expr.arg.value.str()=="?")) return i;
		}

		return -1;
	}

	ExecResult execute()
	{
		int quePos = isFactQuestion();
		if (quePos==-1)
		{
			//writeln("Calling function :: " ~ name);]

			//writeln("Before looking...");

			FunctionDecl f = Glob.functions.get(name,parentModule,parameters,true);
			//writeln("execute : " ~ f.name);
			//writeln("my params : "  ~ f.parameters.list);
			//writeln("Looking for...");

			if (f !is null) { /*writeln("Found");*/ }
			else 
			{
				string errMsg;

				if (parentModule!="") errMsg = parentModule ~ "::" ~ name;
				else errMsg = name;

				throw new ERR_MethodNotFound(errMsg);
				//Panic.runtimeError("Call to undefined function : " ~ errMsg);
			}

			Value[] args = Safety.checkFunctionCallAndEvaluateParameters(f,parameters);

			if (f.reference == "") // It's a normal function call
			{
				localSymbols = new Symbols();

				for (int i=0; i<parameters.list.length; i++)
				{
					//writeln("Setting " ~ f.parameters.list ~ " to : " ~ args[i].str());
					localSymbols.set(f.parameters.list[i], args[i]);
				}

				Symbols oldLocals = Glob.localSymbols;
				Glob.localSymbols = localSymbols;

				ulong stackBefore = Glob.stack.size();

				//try
				//{
					//Glob.executionStack.push("FUNC");
					//Glob.executionStack.print();

					Glob.retCounter = 1;
					//writeln("retCounter = " ~ to!string(Glob.retCounter));
					//writeln("Execing...");
					ExecResult rez = f.statements.execute();
					//writeln("End-Execing...");
					
					//writeln("rez = " ~ to!string(rez));
					//writeln("retCounter = " ~ to!string(Glob.retCounter));

					Glob.localSymbols = oldLocals;

					if (rez!=ExecResult.Ok) return rez;

					Glob.retCounter = -1;


				//} 
				//catch (ReturnSignal r)
				//{
					// Just catch it
				//}
				//finally
				//{

					//Glob.executionStack.pop();
					//Glob.executionStack.print();
				//}

				

				ulong stackAfter = Glob.stack.size();
				if (stackBefore==stackAfter) Glob.stack.push(new Value(0));
			}
			else // It's a function reference
			{
				Value[] passedParams = args;

				Value returned = backends.execute(f.reference, passedParams);

				Glob.stack.push(returned);
			}
		}
		else // Fact Question
		{
			Value[] rets;

			for (int c=0; c<Glob.consts.list.length; c++)
			{
				Expressions exprs = new Expressions();

				for (int j=0; j<parameters.list.length; j++)
				{
					if (j==quePos)
					{
						exprs.add(new Expression(new Argument("string",Glob.consts.list[c].str())));
					}
					else
					{
						exprs.add(parameters.list[j]);
					}
				}

				FunctionCall fc = new FunctionCall(name, exprs);
				fc.execute();
				Value got = Glob.stack.pop();

				if ((got.type==ValueType.booleanValue) && (got.content.b==true))
					rets ~= new Value(Glob.consts.list[c]);

			}

			Value toReturn = new Value(rets);
			Glob.stack.push(toReturn);
		}

		return ExecResult.Ok;
	}
}
