/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/sqliteDb.d
 **********************************************************/

module backend.sqlitedb;

//================================================
// Imports
//================================================

import etc.c.sqlite3;

import std.array;
import std.conv;
import std.stdio;
import std.string;

import databases;
import globals;

import value;
import errors;

//================================================
// Constants
//================================================

const string[] SQLITE_RESULTSTR =
[
	"Successful",
	"SQL error or missing database",
	"Internal logic error in SQLite",
	"Access permission denied",
	"Callback routine requested an abort",
	"The database file is locked",
	"A table in the database is locked",
	"A malloc() failed",
	"Attempt to write a readonly database",
	"Operation terminated by sqlite3_interrupt()",
	"Some kind of disk I/O error occured",
	"The database disk image is malformed",
	"Unknown opcode in sqlite3_file_control()",
	"Insertion failed because database is full",
	"Unable to open the database file",
	"Database lock protocol error",
	"Database is empty",
	"The database schema changed",
	"String or BLOB exceeds size limit",
	"Abort due to constraint violation",
	"Data type mismatch",
	"Library used incorrectly",
	"Uses OS features not supported on host",
	"Authorization denied",
	"Auxiliary database format error",
	"2nd parameter to sqlite3_bind out of range",
	"File opened that is not a database file",
	"Notifications from sqlite3_log()",
	"Warnings from sqlite3_log()"
];

const string SQLITE_DBNOTINITIALIZED = "Database has not been initialized";
const string SQLITE_CURRENTSTATEMENTISNULL = "Current statement is null";

//================================================
// Class
//================================================

class LGM_Sqlitedb
{

	static Value open(Value[] v)
	{
		string name = v[0].content.s;

		sqlite3* db;
		int result = sqlite3_open(toStringz(name~DB_FILE_EXTENSION), &db);

		if (result==SQLITE_OK) 
		{
			Glob.databases.set(name,db);
			return new Value(true);
		}
		else throw new ERR_DatabaseException(SQLITE_RESULTSTR[result]);
	}

	static Value close(Value[] v)
	{
		string name = v[0].content.s;

		if (!Glob.databases.exists(name))
			throw new ERR_DatabaseException(SQLITE_DBNOTINITIALIZED);

		DatabaseInfo di = Glob.databases.get(name);
		sqlite3* db = di.handle;

		int result = sqlite3_close(db);

		if (result==SQLITE_OK) 
		{
			Glob.databases.setActive(name,false);

			return new Value(true);
		}
		else throw new ERR_DatabaseException(SQLITE_RESULTSTR[result]);
	}

	static Value query(Value[] v)
	{
		string name = v[0].content.s;
		string query = v[1].content.s;

		if (!Glob.databases.exists(name))
			throw new ERR_DatabaseException(SQLITE_DBNOTINITIALIZED);

		DatabaseInfo di = Glob.databases.get(name);

		if (!di.active)
			throw new ERR_DatabaseException(SQLITE_DBNOTINITIALIZED);

		sqlite3* db = di.handle;

		sqlite3_stmt* stmt;

		sqlite3_prepare(db, toStringz(query), cast(int)(query.length), &stmt, null);
   		
   		int result = sqlite3_step(stmt);

   		if ((result==SQLITE_DONE)||(result==SQLITE_ROW))
   		{
   			Glob.databases.setCurrentStatement(name,stmt,result);

   			return new Value(true);
   		}
   		else throw new ERR_DatabaseException(SQLITE_RESULTSTR[result]);
	}

	static Value nextRow(Value[] v)
	{
		string name = v[0].content.s;

		if (!Glob.databases.exists(name))
			throw new ERR_DatabaseException(SQLITE_DBNOTINITIALIZED);

		DatabaseInfo di = Glob.databases.get(name);

		if (!di.active)
			throw new ERR_DatabaseException(SQLITE_DBNOTINITIALIZED);

		sqlite3* db = di.handle;

		if (di.currentStatement is null)
			throw new ERR_DatabaseException(SQLITE_CURRENTSTATEMENTISNULL);

		sqlite3_stmt* stmt = di.currentStatement;
		int res = di.currentStatementResult;

		if (res==SQLITE_ROW)
      	{
      		Value[Value] ret;

      		int numCols = sqlite3_data_count(stmt);

         	for (int i=0; i<numCols; i++)
         	{
            	string val = to!string(sqlite3_column_text(stmt,i));
            	string col = to!string(sqlite3_column_name(stmt,i));

            	ret[new Value(val)] = new Value(col);
         	}

         	int result = sqlite3_step(stmt);

         	if ((result==SQLITE_DONE)||(result==SQLITE_ROW))
	      	{
	      		Glob.databases.setCurrentStatement(name,stmt,result);

	      		return new Value(ret);
	      	}
	      	else
	      		throw new ERR_DatabaseException(SQLITE_RESULTSTR[result]);
		}

		return new Value(false);
	}

	static Value allRows(Value[] v)
	{
		string name = v[0].content.s;

		if (!Glob.databases.exists(name))
			throw new ERR_DatabaseException(SQLITE_DBNOTINITIALIZED);

		DatabaseInfo di = Glob.databases.get(name);

		if (!di.active)
			throw new ERR_DatabaseException(SQLITE_DBNOTINITIALIZED);

		sqlite3* db = di.handle;

		if (di.currentStatement is null)
			throw new ERR_DatabaseException(SQLITE_CURRENTSTATEMENTISNULL);

		sqlite3_stmt* stmt = di.currentStatement;
		int res = di.currentStatementResult;

		Value[] ret; 

		while (res==SQLITE_ROW)
      	{
      		Value[Value] oneret;

      		int numCols = sqlite3_data_count(stmt);

         	for (int i=0; i<numCols; i++)
         	{
            	string val = to!string(sqlite3_column_text(stmt,i));
            	string col = to!string(sqlite3_column_name(stmt,i));

            	oneret[new Value(col)] = new Value(val);
         	}

         	res = sqlite3_step(stmt);

         	if ((res==SQLITE_DONE)||(res==SQLITE_ROW))
	      	{
	      		Glob.databases.setCurrentStatement(name,stmt,res);
	      	}
	      	else
	      		throw new ERR_DatabaseException(SQLITE_RESULTSTR[res]);

	      	ret ~= new Value(oneret);
		}

		return new Value(ret);
	}

	static Value lastInsertId(Value[] v)
	{
		string name = v[0].content.s;

		if (!Glob.databases.exists(name))
			throw new ERR_DatabaseException(SQLITE_DBNOTINITIALIZED);

		DatabaseInfo di = Glob.databases.get(name);

		if (!di.active)
			throw new ERR_DatabaseException(SQLITE_DBNOTINITIALIZED);

		sqlite3* db = di.handle;

		int ret = cast(int)(sqlite3_last_insert_rowid(db));

		return new Value(ret);
	}
}
