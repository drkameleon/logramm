/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** statements.d
 **********************************************************/

module components.statements;

//================================================
// Imports
//================================================

import core.memory;

import std.stdio;
import std.conv;

import globals;

import components.statement;

import position;

import panic;
import signals;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Statements_new() { return cast(void*)(new Statements()); }
	void  Statements_add(Statements s, Statement st) { GC.addRoot(cast(void*)s); s.add(st); }
}

//================================================
// Functions
//================================================

class Statements
{
	Statement[] list;

	Position pos;

	this()
	{
	}

	void add(Statement st)
	{
		//writeln("IN HERE");
		list ~= st;
		//writeln("IN HERE");
	}

	void print()
	{
		for (int i=0; i<list.length; i++)
		{
			write(to!string(i) ~ "\t : ");
			list[i].print();
		}
	}

	ExecResult execute()
	{
		//writeln("IN : statements");\
		bool augm;
		try
		{
			//Glob.executionStack.push("statements");
			augm = false;

			if (Glob.retCounter>-1) Glob.retCounter++;
			
			foreach (int i, Statement s; list)
			{
				//writeln("EXECUTING statement : " ~ to!string(i));
				Glob.currentStatement = s;
				//if (s.pos is null) writeln("STATEMENT.pos was NULL **********************");

				
				try
				{
					//writeln("Pushing : " ~ s.classinfo.name);

					
					//if (Glob.retCounter>-1) { Glob.retCounter++; augm = true; }
					//writeln("retCounter = " ~ to!string(Glob.retCounter));

					//Glob.executionStack.printPath();
					//Glob.executionStack.printPath();
					//writeln("Executing...");
					ExecResult rez = s.execute();

					//writeln("retCounter = " ~ to!string(Glob.retCounter));

					//writeln("printing stack");
					//Glob.executionStack.printPath();
					//writeln("printed stack");
					//}
					//catch (ReturnSignal r)
					//{
					
					if (rez==ExecResult.Return)
					{
						//string lastItem = Glob.executionStack.lastItem();

						//writeln("Last Item : " ~ lastItem);

						if (Glob.retCounter!=0) 
						{
							Glob.retCounter--;
							Glob.executionStack.pop();
							//Glob.executionStack.printPath();
							return ExecResult.Return; //throw new ReturnSignal();
						}
						else
						{
							Glob.retCounter = -1;
						}
					}
					else if (rez==ExecResult.Break)
					{
						/*
						string lastItem = Glob.executionStack.lastItem();

						if ((lastItem!="foreachSt.Foreach")&&(lastItem!="loop.Loop"))
						{
							//Glob.executionStack.pop();
							//Glob.executionStack.printPath();
							return ExecResult.Break; // throw new BreakSignal();
						}*/
					}
					//catch (BreakSignal b)
					//{
					//	string lastItem = Glob.executionStack.lastItem();

					//	if ((lastItem!="foreachSt.Foreach")&&(lastItem!="loop.Loop"))
					//		throw new BreakSignal();
					//}
				}
				catch (Exception e)
				{
					Panic.runtimeErrorAtPosition(e.msg, s.pos);
				}
				finally
				{
					//writeln("Poping...");
					//Glob.executionStack.pop();

					//writeln("EXECUTED statement : " ~ to!string(i));
				}

			}
		}
		finally
		{
			//Glob.executionStack.pop();
			//Glob.executionStack.printPath();
			if (augm) Glob.retCounter--;
		}

		return ExecResult.Ok;
	}
}