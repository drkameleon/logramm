/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** databases.d
 **********************************************************/

 module databases;

//================================================
// Imports
//================================================

import std.stdio;
import std.file;
import std.conv;
import std.algorithm;
import std.string;
import etc.c.sqlite3;

//================================================
// Types
//================================================

struct DatabaseInfo
{
	string filename;
	sqlite3* handle;
	sqlite3_stmt* currentStatement;
	int currentStatementResult;
	bool active;
}

//================================================
// Constants
//================================================

const string DB_FILE_EXTENSION = ".db";


//================================================
// Functions
//================================================

class Databases
{
	DatabaseInfo[string] list;

	this()
	{
		
	}

	void add(string n, sqlite3* db, sqlite3_stmt* st)
	{
		DatabaseInfo di;

		di.filename 		= n ~ DB_FILE_EXTENSION;
		di.handle			= db;
		di.currentStatement = st;
		di.active			= true;

		list[n] = di;
	}

	void set(string n, sqlite3* db, sqlite3_stmt* st=null)
	{
		if (exists(n))
		{
			list[n].handle = db;
			list[n].currentStatement = st;
			list[n].active = true;
		}
		else
		{
			add(n,db,st);
		}
	}

	void setHandle(string n, sqlite3* db)
	{
		list[n].handle = db;
	}

	void setCurrentStatement(string n, sqlite3_stmt* st, int r)
	{
		list[n].currentStatement = st;
		list[n].currentStatementResult = r;
	}

	void setActive(string n, bool active)
	{
		list[n].active = active;
	}

	bool exists(string n)
	{
		return ((n in list)!=null);
	}

	DatabaseInfo get(string n)
	{
		return list[n];
	}
}
