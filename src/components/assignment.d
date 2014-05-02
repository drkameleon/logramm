/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** assignment.d
 **********************************************************/

module assignment;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;

import globals;

import components.statement;
import components.expression;
import components.argument;
import components.lvalue;

import value;
import position;

import symbols;
import errors;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Assignment_new(Lvalue l, Expression r, char* op) { return cast(void*)(new Assignment(l,r,to!string(op))); }

	
}

//================================================
// Functions
//================================================

class Assignment : Statement
{
	Lvalue left;
	Expression right;
	string operator;
	Position pos;

	this(Lvalue l, Expression r, string op)
	{
		super("assignment");

		left = l;
		right = r;
		operator = op;
		/*

		if (op=="=") right = r;
		else if (op=="+=") right = new Expression(new Expression(new Argument("id",l)), "+", r);
		else if (op=="-=") right = new Expression(new Expression(new Argument("id",l)), "-", r);
		else if (op=="*=") right = new Expression(new Expression(new Argument("id",l)), "*", r);
		else if (op=="/=") right = new Expression(new Expression(new Argument("id",l)), "/", r);
		else if (op=="%=") right = new Expression(new Expression(new Argument("id",l)), "%", r);

		*/
	}

	override void print()
	{
		super.print();
		//writeln("\t | What: " ~ left ~ ", With: ");
		right.print();
	}

	override ExecResult execute()
	{
		Value exprValue = right.evaluate();
		//writeln("in assignment execute ::  ");
		//writeln(Glob.calls);
		//writeln("Got a new value : " ~ exprValue.str() ~ " and we're about to assign it to : " ~ left.getPath());
		//writeln("LOCAL symbols before: ");
		//if (Glob.localSymbols !is null) Glob.localSymbols.print();
		//writeln("GLOBAL symbols before: ");
		//Glob.symbols.print();

		Symbols curSymbols;
		if (Glob.localSymbols !is null) curSymbols = Glob.localSymbols;
		else curSymbols = Glob.symbols;
  
		/*writeln("LVALUE-PATH : " ~ left.getPath());*/

		string symbolName = left.getName();
		/*writeln("sName = " ~ symbolName);*/
		Value symbolValue = left.getValue(curSymbols);
		//writeln("in assignment execute :: After getValue: ");
		//writeln(Glob.calls);
		if (symbolValue !is null) { /* writeln("sName = " ~ symbolName ~ " sValue = " ~ symbolValue.str() ~ " sPointer = " ~ to!string(&symbolValue)); */ }
 
		string[string] additive_ops = ["+=":"","-=":"","*=":"","/=":"","%=":""];

		if ((symbolValue is null) && (operator in additive_ops))
			throw new ERR_AssignmentException(symbolName,operator);
 
  
		Value retValue; 

		if (symbolValue !is null)  { /*writeln("symbol IS already set");*/ retValue = symbolValue; }
		else { /*writeln("symbol is NOT set");*/ }

		Value newVal;

		Value parentValue = left.getParent(curSymbols);
		//writeln("in assignment execute :: After getParent: ");
		//writeln(Glob.calls);

		if (parentValue !is null) { /* writeln("ParentValue ------> " ~ parentValue.str()); */ }

		//writeln("Before switch"); 

		Glob.calls["assignments"]++;
 
		switch (operator)
		{
			case "="		:	newVal = exprValue; break;
			case "+="		:	newVal = symbolValue + exprValue; break;
			case "-="		:	newVal = symbolValue - exprValue; break;
			case "*="		:	newVal = symbolValue * exprValue; break;
			case "/="		:	newVal = symbolValue / exprValue; break;
			case "%="		:	newVal = symbolValue % exprValue; break;
			case "&&="		:	newVal = symbolValue & exprValue; break;
			case "||="		:	newVal = symbolValue | exprValue; break;
			case "^^="		:	newVal = symbolValue ^ exprValue; break;
			default			:	break;
		}

		// Re-assign it only if (symbolValue) is not set
		if (symbolValue is null)
		{
			curSymbols.set(symbolName,newVal);
		}
		else
		{
			left.setNestedValue(parentValue, newVal, left.paths());
			curSymbols.set(symbolName,parentValue);
		}

		//writeln("in assignment execute ::  ");
		//writeln(Glob.calls);

		return ExecResult.Ok;
	}
}
