/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/json.d
 **********************************************************/

module backend.json;

//================================================
// Imports
//================================================

import std.array;
import std.conv;
import std.json;
import std.stdio;
import std.string;

import value;

//================================================
// Functions
//================================================

Value parseJsonNode(JSONValue n)
{
	switch (n.type())
	{
		case JSON_TYPE.STRING 		: return new Value(n.str());
		case JSON_TYPE.INTEGER 		: return new Value(n.integer());
		case JSON_TYPE.UINTEGER 	: return new Value(n.uinteger());
		case JSON_TYPE.FLOAT 		: return new Value(n.floating());
		case JSON_TYPE.ARRAY 		: {
			Value[] ret;

			foreach (JSONValue v; n.array())
			{
				ret ~= parseJsonNode(v);
			}

			return new Value(ret);
		}
		case JSON_TYPE.OBJECT 		: {
			Value[Value] ret;

			foreach (string k, JSONValue v; n.object())
			{
				Value key = new Value(k);
				Value val = parseJsonNode(v);

				ret[key] = val;
			}

			return new Value(ret);
		}
		default : break;

	}

	return new Value(0); // Shouldn't ever reach here
}

JSONValue generateJsonValue(Value input)
{
	JSONValue ret;
	switch (input.type)
	{
		case ValueType.numberValue		:	ret = input.content.i; return ret;
		case ValueType.realValue		:	ret = input.content.r; return ret;
		case ValueType.stringValue		:	ret = input.content.s; return ret;
		case ValueType.booleanValue		:	ret = to!int(input.content.b); return ret;
		case ValueType.arrayValue		:	{
			JSONValue[] result;
			for (int i=0; i<input.content.a.length; i++)
			{
				result ~= generateJsonValue(input.content.a[i]);
			}
			ret = result;
			return ret;
		}
		case ValueType.dictionaryValue	: 	{
			JSONValue[string] result;
			foreach (Value kv, Value vv; input.content.d)
			{
				result [kv.str()] = generateJsonValue(vv);
			}
			ret = result;
			return ret;
		}
		default	: break;
	}

	return ret; // won't reach here
}

//================================================
// Class
//================================================

class LGM_Json
{
	static Value parse(Value[] v)
	{
		string str = v[0].content.s;

		JSONValue j = parseJSON(str);
		Value ret = parseJsonNode(j);

		return new Value(ret);
	}

	static Value generate(Value[] v)
	{
		Value arg = v[0];

		JSONValue j = generateJsonValue(arg);
		string ret = j.toString();

		return new Value(ret);
	}

}
