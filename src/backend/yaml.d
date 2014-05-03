/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/yaml.d
 **********************************************************/

module backend.yaml;

//================================================
// Imports
//================================================

import std.array;
import std.conv;
import std.stdio;
import std.stream;
import std.string;

import library.yaml.all;

import value;

//================================================
// Constants
//================================================

enum YAML_STRING	=	"tag:yaml.org,2002:str";
enum YAML_INT		=	"tag:yaml.org,2002:int";
enum YAML_FLOAT		=	"tag:yaml.org,2002:float";
enum YAML_BOOL		=	"tag:yaml.org,2002:bool";

enum YAML_SEQ		=	"tag:yaml.org,2002:seq";
enum YAML_SET		=	"tag:yaml.org,2002:set";

enum YAML_MAP		=	"tag:yaml.org,2002:map";
enum YAML_OMAP		=	"tag:yaml.org,2002:omap";
enum YAML_PAIRS		=	"tag:yaml.org,2002:pairs";

//================================================
// Functions
//================================================

Value parseYAMLNode(Node n)
{
	switch (n.tag)
	{
		case YAML_STRING 	: 	return new Value(n.as!(string));
		case YAML_INT 		: 	return new Value(n.as!(long));
		case YAML_FLOAT 	:	return new Value(n.as!(float));
		case YAML_BOOL 		:	return new Value(n.as!(bool));
		case YAML_SEQ 		:
		case YAML_SET 		: {
			Value[] ret;

			foreach (Node v; n)
			{
				ret ~= parseYAMLNode(v);
			}

			return new Value(ret);
		}
		case YAML_MAP 		:
		case YAML_OMAP 		:
		case YAML_PAIRS 	: {
			Value[Value] ret;

			foreach (Node k, Node v; n)
			{
				Value key = parseYAMLNode(k);
				Value val = parseYAMLNode(v);

				ret[key] = val;
			}

			return new Value(ret);
		}

		default:
	}

	return new Value(0); // Shouldn't ever reach here
}

Node generateYAMLValue(Value input)
{
	Node ret;
	switch (input.type)
	{
		case ValueType.numberValue		:	return Node(input.content.i, YAML_INT);
		case ValueType.realValue		:	return Node(input.content.r, YAML_FLOAT);
		case ValueType.stringValue		:	return Node(input.content.s, YAML_STRING);
		case ValueType.booleanValue		:	return Node(input.content.b, YAML_BOOL);
		case ValueType.arrayValue		:	{
			Node[] vals;
			for (int i=0; i<input.content.a.length; i++)
			{
				vals ~= generateYAMLValue(input.content.a[i]);
			}
			ret = Node(vals, YAML_SEQ);
			return ret;
		}
		case ValueType.dictionaryValue	: 	{
			Node[Node] vals;

			foreach (Value kv, Value vv; input.content.d)
			{
				vals [ generateYAMLValue(kv) ] = generateYAMLValue(vv);
			}
			ret = Node(vals, YAML_MAP);
			return ret;
		}
		default	: break;
	}

	return ret; // won't reach here
}


//================================================
// Class
//================================================

class LGM_Yaml
{
	static Value parse(Value[] v)
	{
		string yaml = v[0].content.s;

		Node root = Loader.fromString(yaml).load();

		Value ret = parseYAMLNode(root);

		return new Value(ret);
	}

	static Value generate(Value[] v)
	{
		Value arg = v[0];

		Node y = generateYAMLValue(arg);

		auto stream = new MemoryStream();
 		Dumper(stream).dump(y);

 		string ret = to!string(stream);

 		return new Value(ret);
	}

}
