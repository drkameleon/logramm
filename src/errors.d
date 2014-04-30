/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** errors.d
 **********************************************************/

module errors;

//================================================
// Imports
//================================================

import std.stdio;
import std.conv;
import std.exception;
import std.string;

import value;

//================================================
// Functions
//================================================

class ERR_UndefinedOperation : Exception
{
	this(string operator, const Value lhs, const Value rhs)
	{
		super( format("Undefined Operation: %s %s %s", to!string(lhs.type), operator, to!string(rhs.type)) );
	}
}

class ERR_OutOfRange : Exception
{
	this(string item, string collection)
	{
		super( format("Out of range: attempting to access %s of %s", item, collection) );
	}
}

class ERR_MethodNotFound : Exception
{
	this(string method)
	{
		super( format("Method not found: %s", method) );
	}
}

class ERR_UserException : Exception
{
	this(string msg)
	{
		super( format("User exception: %s", msg) );
	}
}

class ERR_DatabaseException : Exception
{
	this(string msg)
	{
		super ( format("Database exception: %s", msg) );
	}
}

class ERR_AssignmentException : Exception
{
	this(string id, string operator)
	{
		super ( format("Assignment exception: Attempting to use '%s' operator on undefined variable '%s'",operator,id) );
	}
}