/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/compiler.d
 **********************************************************/

module compiler;

//================================================
// Imports
//================================================

import std.conv;
import std.file;
import std.path;
import std.stdio;
import std.string;

import components.program;
import library.cgi;
import library.file;

import preprocessor;
import globals;
import loader;
import panic;

//================================================
// Externals
//================================================

extern (C) struct yy_buffer_state;
extern (C) int yyparse();
extern (C) yy_buffer_state* yy_scan_string(const char*);
extern (C) yy_buffer_state* yy_scan_buffer(char *, size_t);
extern (C) extern __gshared FILE* yyin;
extern (C) extern __gshared const(char)* yyfilename;
extern (C) extern __gshared int yycgiMode;

extern (C) extern __gshared int yylineno;

extern (C) __gshared void* _program;

//================================================
// Constants
//================================================

const string FILE_NOT_FOUND_MSG	= "File '%s' not found";

//================================================
// Super-globals
//================================================

int yylineno_old;

//================================================
// Functions
//================================================

void init(string input, string[] argv, string include, bool nopreload)
{
	Glob = new Globals();

	Glob.paths ~= dirName(input);
	Glob.paths ~= include.split(",");

	Glob.registerVariable("__Args", argv);

	if (!nopreload) loader.loadDefault();

	Program script;

	if (extension(input)==".lgmx")
	{
		string lgmx = format("import io.file; import format.html; __content = File::read(\"%s\"); __parsed = Html::parse(__content); exec __parsed;", input);
		script = compileFromString(lgmx);
	}
	else
	{
		script = compile(input);
	}

	script.execute();

	//writeln(Glob.calls);
}

void initEval(string input, string include, bool nopreload)
{
	Glob = new Globals();

	Glob.paths ~= dirName(input);
	Glob.paths ~= include.split(",");

	if (!nopreload) loader.loadDefault();

	Program script = compileFromString(input);
	script.execute();
}

void initCgi(Cgi cgi)
{
	cgi.outputHeaders();

	Glob = new Globals();

	Glob.paths ~= dirName(cgi.pathTranslated);

	Glob.registerVariable("__Get", cgi.get);
	Glob.registerVariable("__RequestUri", cgi.requestUri);
	Glob.registerVariable("__QueryString", cgi.queryString);
	Glob.registerVariable("__AbsolutePath", cgi.pathTranslated);

	Glob.cgiMode = true;

	loader.loadDefault();

	Program script = compile(cgi.pathTranslated); // Turn preprocessing OFF, for CGI. TOFIX.

	script.execute();
}

// Main compilation startpoint

Program compile(string filename, bool preprocessorON=true)
{	
	string contents = to!string(std.file.read(filename));
	
	if (preprocessorON)
	{
		string preprocessed = preprocessor.preprocess(filename);
	
		if (preprocessed !is null)
			contents = preprocessed;
	}
	
	return compileFromString(contents,filename);
}

Program compileFromString(string input, string filename="<STDIN>")
{
	if (!yylineno) yylineno = 0;

	yylineno_old = yylineno_old;
	yylineno = 0;
	try 
	{
		// Let's take control over
		// to the Flex/Bison
		_program = cast(void*)(new Program());
		yyfilename = toStringz(filename);
		yycgiMode = cast(int)Glob.cgiMode;

		yy_scan_buffer(cast(char*)(toStringz(input~'\0')),input.length+2);

		yyparse();
	}
	catch (Exception e)
	{
		Panic.error(format(FILE_NOT_FOUND_MSG, filename));
	}

	yylineno = yylineno_old;

	// Let's return our Program object
	return cast(Program)(_program);	

	return compile(library.file.tempWithContents(input));
}

