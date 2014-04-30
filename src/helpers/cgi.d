/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/helpers/cgi.d
 **********************************************************/

module helpers.cgi;

//================================================
// Imports
//================================================

import std.array;
import std.stdio;
import std.string;
import std.process;
import std.uri;

//================================================
// Constants
//================================================

const string HTTP_HEADER_TEXT		=	"Content-type: text/plain; charset=iso-8859-1\n\n";
const string HTTP_HEADER_HTML		=	"Content-type: text/html; charset=iso-8859-1\n\n";

//================================================
// Class
//================================================

class Cgi
{
	string requestUri;
	string referrer;
	string userAgent;
	string remoteAddress;
	string host;
	string pathInfo;
	string pathTranslated;
	string queryString;
	string scriptName;
	string scriptFilename;
	string[string] get;

	bool isActive;
	
	this()
	{
		requestUri = getenv("REQUEST_URI");
		referrer = getenv("HTTP_REFERER");
		userAgent = getenv("HTTP_USER_AGENT");
		remoteAddress = getenv("REMOTE_ADDR");
		host = getenv("HTTP_HOST");
		pathInfo = getenv("PATH_INFO");
		pathTranslated = getenv("PATH_TRANSLATED");
		queryString = getenv("QUERY_STRING");
		scriptName = getenv("SCRIPT_NAME");
		scriptFilename = getenv("SCRIPT_FILENAME");

		get = decodeQueryString(queryString);

		isActive = (requestUri!="");
	}

	void outputHeaders()
	{
		writeln(HTTP_HEADER_HTML);
	}

	string[string] decodeQueryString(string str, string separator = "&") 
	{
		string[] vars = str.split(separator);
		string[string] ret;

		foreach(string var; vars) 
		{
			auto equal = var.indexOf("=");
			if(equal == -1) 
			{
				ret[decodeComponent(var)] = "";
			} 
			else 
			{
				ret[decodeComponent(var[0..equal].replace("+", " "))] = decodeComponent(var[equal + 1 .. $].replace("+", " "));
			}
		}

		return ret;
	}
}
