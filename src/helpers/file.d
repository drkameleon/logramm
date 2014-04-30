/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/helpers/file.d
 **********************************************************/

module helpers.file;

//================================================
// Imports
//================================================

import std.conv;
import std.random;
import std.stdio;
import std.string;

//================================================
// Functions
//================================================

string searchFileInPaths(string filename, string[] paths)
{
	foreach (string path; paths)
	{
		try 
		{
			
			string filepath = path ~ "/" ~ filename;

			auto file = File(filepath, "r");

			return filepath;
		}
		catch (Exception e)
		{
			
		}
	}

	return filename; // The file was NOT found. Return its name.
}

string tempWithContents(string contents)
{
	string filename = format("/tmp/tmp%s.lgm",to!string(uniform(0,10000)));
	auto f = File(filename, "w"); // open for writing
	f.write(contents);
	f.close();
	return filename;
}