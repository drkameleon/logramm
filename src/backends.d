/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend.d
 **********************************************************/

 module backends;

//================================================
// Imports
//================================================

import std.stdio;
import std.string;
import std.conv;
import std.typetuple;

import panic;

import value;

import backend.array;
import backend.dictionary;
import backend.file;
import backend.json;
import backend.math;
import backend.net;
import backend.path;
import backend.reflection;
import backend.sqlitedb;
import backend.string;
import backend.types;
import backend.xml;

//================================================
// Constants
//================================================

alias classNames = TypeTuple!(
						"array","dictionary",
						"file","json","math",
						"net","path","reflection",
						"sqlitedb","string","types","xml");

//================================================
// Functions
//================================================

string methodPaths()
{
	string ret = "";
	string[] methods;

	foreach (string className; classNames)
	{
		methods = [__traits(derivedMembers,mixin("backend." ~ className ~ ".LGM_" ~ capitalize(className)))];

		foreach (string s; methods) 
		{
			ret ~= "case \"" ~ className ~ "." ~ s ~ "\": return backend." ~ className ~ ".LGM_" ~ capitalize(className)~ "." ~ s ~ "(params);";
		}
	}

	return ret;
}

Value execute(string method, Value[] params)
{
	switch (method)
	{
		mixin(methodPaths());
		default: break;
	}
	return new Value(0);
}
