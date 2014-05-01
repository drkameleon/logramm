/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** value.d
 **********************************************************/

module value;

//================================================
// Imports
//================================================

import std.stdio;
import std.file;
import std.conv;
import std.string;
import std.array;

import globals;

import components.expression;
import components.arrayAr;
import components.dictionary;
import components.pair;

import value;

import errors;

//================================================
// Definitions
//================================================

enum ValueType
{
	numberValue,
	realValue,
	stringValue,
	booleanValue,
	arrayValue,
	dictionaryValue
}

union ValueContent
{
	long i;
	real r;
	ulong l;
	string s;
	bool b;
	Value[] a;
	Value[Value] d;
}

//================================================
// Functions
//================================================

class Value
{
	ValueType type;
	ValueContent content;

	this() { Glob.calls["vals"]++; }
	this(int v)   	{ type = ValueType.numberValue;  content.i = v; Glob.calls["vals"]++;}
	this(long v) 	{ type = ValueType.numberValue;  content.i = v; Glob.calls["vals"]++;}
	this(string v)	{ type = ValueType.stringValue;  content.s = v; Glob.calls["vals"]++;}
	this(bool v)	{ type = ValueType.booleanValue; content.b = v; Glob.calls["vals"]++;}
	this(real v)	{ type = ValueType.realValue; 	 content.r = v; Glob.calls["vals"]++;}
	this(Value[] v)
	{
		type = ValueType.arrayValue;
		content.a = [];
		foreach (Value i; v)
		{
			content.a ~= i;
		}
		Glob.calls["vals"]++;
	}
	this(Value[Value] v)
	{
		type = ValueType.dictionaryValue;
		//content.d.init(); NOT INITIALIASED. MAYBE AN ISSUE???
		foreach (Value k, Value c; v)
		{
			content.d[k] = c;
		}
		Glob.calls["vals"]++;
	}
	
	this(ArrayAr v) {
		type = ValueType.arrayValue;
		content.a = [];

		v.evaluate();

		foreach (Expression e; v.expressions.list)
		{
			Value eV = e.evaluate();

			content.a ~= eV;
		}
		Glob.calls["vals"]++;
	}
	this(Dictionary v)
	{
		type = ValueType.dictionaryValue;

		foreach (Pair p; v.pairs.list)
		{
			Value kV = p.key.evaluate();
			Value vV = p.value.evaluate();

			content.d[kV] = vV;
		}
		Glob.calls["vals"]++;

		//writeln("Just created a dictionary : " ~ str());
/*
		foreach (Value key, Value v; content.d)
		{
			writeln("Key :" ~ key.str() ~ ", Value :" ~ v.str());
			writeln("Key :" ~ key.str() ~ ", Value :" ~ content.d[key].str());
		}*/
	}

	Value getValueFromDict(string key)
	{
		foreach (Value k, Value v; content.d)
		{
			if (k.str()==key) return v;
		}

		return null;
	}

	this(Value v)
	{
		type = v.type;
		Glob.calls["vals"]++;

		switch (type)
		{
			case ValueType.numberValue : content.i = v.content.i; break;
			case ValueType.realValue : content.r = v.content.r; break;
			case ValueType.stringValue : content.s = v.content.s; break;
			case ValueType.booleanValue : content.b = v.content.b; break;
			case ValueType.arrayValue : 
				content.a = [];
				foreach (Value vv; v.content.a)
					content.a ~= new Value(vv);
				//content.a = v.content.a; 
				break;
			case ValueType.dictionaryValue :
				foreach (Value kv, Value vv; v.content.d)
					content.d[kv] = new Value(vv); break;
			default: break;
		}
	}

	void copyValuesFrom(Value v)
	{
		type = v.type;

		switch (type)
		{
			case ValueType.numberValue : content.i = v.content.i; break;
			case ValueType.realValue : content.r = v.content.r; break;
			case ValueType.stringValue : content.s = v.content.s; break;
			case ValueType.booleanValue : content.b = v.content.b; break;
			case ValueType.arrayValue : content.a = v.content.a; break;
			case ValueType.dictionaryValue : content.d = v.content.d; break;
			default: break;
		}
	}

	bool contains(Value item)
	{
		foreach (Value v; content.a)
			if (v==item) return true;

		return false;
	}


	/************************************
	 ARITHMETIC OPERATIONS
	 ************************************/

	Value opUnary(string op)() const if (op == "-")
	{
		if (type==ValueType.numberValue)
		{
			return new Value(-1 * content.i);
		}
		else if (type==ValueType.realValue)
		{
			return new Value(-1 * content.r);
		}

		throw new ERR_UndefinedOperation(op,this,new Value("u-"));

		return new Value(0);
	}

	Value opBinary(string op)(in Value rhs) const if (op == "+")
	{
		if (type==ValueType.numberValue)
		{
			long lhs = content.i;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: return new Value(lhs + rhs.content.i);
				case ValueType.realValue 		: return new Value(lhs + rhs.content.r);
				case ValueType.stringValue		: return new Value(to!string(lhs) ~ rhs.content.s);
				case ValueType.booleanValue		: return new Value(lhs + to!int(rhs.content.b));
				default							: break;
			}
		}
		else if (type==ValueType.realValue)
		{
			real lhs = content.r;

			switch (rhs.type) 
			{
				case ValueType.realValue		: return new Value(lhs + rhs.content.r);
				case ValueType.numberValue		: return new Value(lhs + rhs.content.i);
				case ValueType.stringValue		: return new Value(to!string(lhs) ~ rhs.content.s);
				case ValueType.booleanValue		: return new Value(lhs + to!int(rhs.content.b));
				default							: break;
			}
		}
		else if (type==ValueType.stringValue)
		{
			string lhs = content.s;

			switch (rhs.type)
			{
				case ValueType.numberValue		: return new Value(lhs ~ to!string(rhs.content.i));
				case ValueType.realValue 		: return new Value(lhs ~ to!string(rhs.content.r));
				case ValueType.stringValue		: return new Value(lhs ~ rhs.content.s);
				case ValueType.booleanValue		: return new Value(lhs ~ to!string(rhs.content.b));
				case ValueType.arrayValue		:
				case ValueType.dictionaryValue	: return new Value(lhs ~ getAsStr(rhs));
				default							: break;
			}
		}
		else if (type==ValueType.booleanValue)
		{

		}
		else if (type==ValueType.arrayValue)
		{
			Value newV = new Value(cast(Value)(this));
			if (rhs.type!=ValueType.arrayValue)
			{
				newV.content.a ~= cast(Value)rhs;
			}
			else
			{
				foreach (const Value vv; rhs.content.a)
				{
					newV.content.a ~= cast(Value)vv;
				}
			}
			return newV;
		}
		else if (type==ValueType.dictionaryValue)
		{
			if (rhs.type==ValueType.dictionaryValue)
			{
				Value[Value] newV;

				foreach (const Value kv, const Value vv; content.d) 
					newV[cast(Value)kv]=cast(Value)vv; 

				foreach (const Value kv, const Value vv; rhs.content.d)
					newV[cast(Value)kv]=cast(Value)vv; 

				return new Value(newV);
			}
		}

		throw new ERR_UndefinedOperation(op,this,rhs);

		return new Value(0); // Control never reaches this point
	}

	Value opBinary(string op)(in Value rhs) const if (op == "-")
	{
		if (type==ValueType.numberValue)
		{
			long lhs = content.i;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: return new Value(lhs - rhs.content.i);
				case ValueType.realValue 		: return new Value(lhs - rhs.content.r);
				case ValueType.booleanValue		: return new Value(lhs - to!int(rhs.content.b));
				default							: break;
			}
		}
		else if (type==ValueType.realValue)
		{
			real lhs = content.r;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: return new Value(lhs - rhs.content.i);
				case ValueType.realValue 		: return new Value(lhs - rhs.content.r);
				case ValueType.booleanValue		: return new Value(lhs - to!int(rhs.content.b));
				default							: break;
			}
		}
		else if (type==ValueType.stringValue)
		{
			string lhs = content.s;

			switch (rhs.type)
			{
				case ValueType.numberValue		: return new Value(replace(lhs, to!string(rhs.content.i),""));
				case ValueType.realValue 		: return new Value(replace(lhs, to!string(rhs.content.r),""));
				case ValueType.stringValue		: return new Value(replace(lhs, rhs.content.s,""));
				case ValueType.arrayValue		: string rets = lhs;
												  foreach (const Value kv; rhs.content.a)
												  {
												  	   rets = replace(rets, getAsStr(kv), "");
												  }
												  return new Value(rets);

				default							: break;
			}
		}
		else if (type==ValueType.booleanValue)
		{

		}
		else if (type==ValueType.arrayValue)
		{
			if (rhs.type!=ValueType.arrayValue)
			{
				Value newL = new Value(cast(Value)this);

				newL.removeSubvalue(cast(Value)rhs); 

				return newL;
			}
			else
			{
				Value newL = new Value(cast(Value)this);

				foreach (const Value kv; rhs.content.a)
				{
					newL.removeSubvalue(cast(Value)kv);
				}

				return newL;
			}
		}
		else if (type==ValueType.dictionaryValue)
		{

		}

		throw new ERR_UndefinedOperation(op,this,rhs);

		return new Value(0); // Control never reaches this point
	}

	Value opBinary(string op)(in Value rhs) const if (op == "*")
	{
		if (type==ValueType.numberValue)
		{
			long lhs = content.i;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: return new Value(lhs * rhs.content.i);
				case ValueType.realValue		: return new Value(lhs * rhs.content.r);
				case ValueType.stringValue		: return new Value(replicate(rhs.content.s,lhs));
				case ValueType.booleanValue		: return new Value(lhs * to!int(rhs.content.b));
				default							: break;
			}
		}
		else if (type==ValueType.realValue)
		{
			real lhs = content.r;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: return new Value(lhs * rhs.content.i);
				case ValueType.realValue		: return new Value(lhs * rhs.content.r);
				case ValueType.booleanValue		: return new Value(lhs * to!int(rhs.content.b));
				default							: break;
			}
		}
		else if (type==ValueType.stringValue)
		{
			string lhs = content.s;

			if (rhs.type==ValueType.numberValue) return new Value(replicate(lhs, rhs.content.i));
		}
		else if (type==ValueType.booleanValue)
		{

		}
		else if (type==ValueType.arrayValue)
		{
			if (rhs.type==ValueType.numberValue)
			{
				Value newL = new Value(cast(Value)this);

				for (int ll=0; ll<rhs.content.i-1; ll++)
				{
					foreach (const Value kv; content.a)
					{
						newL.content.a ~= cast(Value)kv;
					}
				}

				return newL;
			}
		}
		else if (type==ValueType.dictionaryValue)
		{

		}

		throw new ERR_UndefinedOperation(op,this,rhs);

		return new Value(0); // Control never reaches this point
	}

	Value opBinary(string op)(in Value rhs) const if (op == "/")
	{
		if (type==ValueType.numberValue)
		{
			long lhs = content.i;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: return new Value(lhs / rhs.content.i);
				case ValueType.realValue		: return new Value(lhs / rhs.content.r);
				case ValueType.booleanValue		: return new Value(lhs / to!int(rhs.content.b));
				default							: break;
			}
		}
		else if (type==ValueType.realValue)
		{
			real lhs = content.r;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: return new Value(lhs / rhs.content.i);
				case ValueType.realValue		: return new Value(lhs / rhs.content.r);
				case ValueType.booleanValue		: return new Value(lhs / to!int(rhs.content.b));
				default							: break;
			}
		}
		else if (type==ValueType.stringValue)
		{
			if (rhs.type==ValueType.numberValue)
			{
				Value[] ret;

				string resp = "";
				for (int kk=0; kk<content.s.length; kk++)
				{
					resp ~= content.s[kk];
					if ((kk+1)%rhs.content.i==0)
					{
						ret ~= new Value(resp);

						resp = "";
					}
				}

				return new Value(ret);
			}
		}
		else if (type==ValueType.booleanValue)
		{

		}
		else if (type==ValueType.arrayValue)
		{
			
		}
		else if (type==ValueType.dictionaryValue)
		{

		}

		throw new ERR_UndefinedOperation(op,this,rhs);

		return new Value(0); // Control never reaches this point
	}

	Value opBinary(string op)(in Value rhs) const if (op == "%")
	{
		if (type==ValueType.numberValue)
		{
			long lhs = content.i;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: return new Value(lhs % rhs.content.i);
				case ValueType.booleanValue		: return new Value(lhs % to!int(rhs.content.b));
				default							: break;
			}
		}
		else if (type==ValueType.stringValue)
		{
			if (rhs.type==ValueType.numberValue)
			{
				Value[] ret;

				string resp = "";
				for (int kk=0; kk<content.s.length; kk++)
				{
					resp ~= content.s[kk];
					if ((kk+1)%rhs.content.i==0)
					{
						ret ~= new Value(resp);

						resp = "";
					}
				}
				return new Value(resp);
				//return new Value(ret);
			}
		}
		else if (type==ValueType.booleanValue)
		{

		}
		else if (type==ValueType.arrayValue)
		{
			
		}
		else if (type==ValueType.dictionaryValue)
		{

		}

		throw new ERR_UndefinedOperation(op,this,rhs);

		return new Value(0); // Control never reaches this point
	}

	Value opBinary(string op)(in Value rhs) const if (op == "&")
	{
		if ((type==ValueType.numberValue)&&(rhs.type==ValueType.numberValue))
		{
			return new Value(content.i & rhs.content.i);
		}
		else if ((type==ValueType.arrayValue)&&(rhs.type==ValueType.arrayValue))
		{
			// Set intersection
			Value[] items;

			for (int k=0; k<content.a.length; k++)
			{
				if ((cast(Value)rhs).contains(cast(Value)content.a[k]))
					items ~= cast(Value)(content.a[k]);
			}

			return new Value(items);
			
		}

		throw new ERR_UndefinedOperation(op,this,rhs);

		return new Value(0); // Control never reaches this point
	}

	Value opBinary(string op)(in Value rhs) const if (op == "|")
	{
		if ((type==ValueType.numberValue)&&(rhs.type==ValueType.numberValue))
		{
			return new Value(content.i | rhs.content.i);
		}
		else if ((type==ValueType.arrayValue)&&(rhs.type==ValueType.arrayValue))
		{
			// Set union
			Value items;
			Value[] itemItems;

			items = new Value(itemItems);

			for (int k=0; k<content.a.length; k++)
			{
				if (!(cast(Value)items).contains(cast(Value)content.a[k]))
				{
					itemItems ~= cast(Value)(content.a[k]);
					items = new Value(itemItems);
				}
			}

			for (int k=0; k<rhs.content.a.length; k++)
			{
				if (!(cast(Value)items).contains(cast(Value)rhs.content.a[k]))
				{
					itemItems ~= cast(Value)(rhs.content.a[k]);
					items = new Value(itemItems);
				}
			}

			return new Value(itemItems);
		}
		
		throw new ERR_UndefinedOperation(op,this,rhs);

		return new Value(0); // Control never reaches this point
	}

	Value opBinary(string op)(in Value rhs) const if (op == "^")
	{
		if ((type==ValueType.numberValue)&&(rhs.type==ValueType.numberValue))
		{
			return new Value(content.i ^ rhs.content.i);
		}
		else if ((type==ValueType.arrayValue)&&(rhs.type==ValueType.arrayValue))
		{
			// Set intersection
			Value[] items;

			for (int k=0; k<content.a.length; k++)
			{
				if (!(cast(Value)rhs).contains(cast(Value)content.a[k]))
					items ~= cast(Value)(content.a[k]);
			}

			for (int k=0; k<rhs.content.a.length; k++)
			{
				if (!(cast(Value)this).contains(cast(Value)rhs.content.a[k]))
					items ~= cast(Value)(rhs.content.a[k]);
			}

			return new Value(items);
		}
		
		throw new ERR_UndefinedOperation(op,this,rhs);

		return new Value(0); // Control never reaches this point
	}

 	/************************************
	 RELATIONAL OPERATIONS
	 ************************************/

	override bool opEquals(Object rh)
	{
		Value rhs = cast(Value)(rh);

		if (type==ValueType.numberValue)
		{
			long lhs = content.i;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: return (lhs == rhs.content.i);
				case ValueType.realValue		: return (lhs == rhs.content.r);
				case ValueType.booleanValue		: return (lhs == to!int(rhs.content.b));
				default							: break;
			}
		}
		else if (type==ValueType.realValue)
		{
			real lhs = content.r;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: return (lhs == rhs.content.i);
				case ValueType.realValue		: return (lhs == rhs.content.r);
				case ValueType.booleanValue		: return (lhs == to!int(rhs.content.b));
				default							: break;
			}
		}
		else if (type==ValueType.stringValue)
		{
			if (rhs.type==ValueType.stringValue)
			{
				return (content.s == rhs.content.s);
			}
		}
		else if (type==ValueType.booleanValue)
		{
			if (rhs.type==ValueType.booleanValue)
			{
				return (content.b == rhs.content.b);
			}
		}
		else if (type==ValueType.arrayValue)
		{
			if (rhs.type==ValueType.arrayValue)
			{
				if (content.a.length!=rhs.content.a.length) return (false);
				for (int kk=0; kk<content.a.length; kk++)
				{
					Value kv = cast(Value)(content.a[kk]);
					Value rv = cast(Value)(rhs.content.a[kk]);
					if (kv != rv) return (false);
				}
				return (true);
			}
		}
		else if (type==ValueType.dictionaryValue)
		{
			// UNIMPLEMENTED
		}

		return (false);
	}

	int opCmp(in Value rhs)
	{
		if (this==rhs) return 0;
		if (type==ValueType.numberValue)
		{
			long lhs = content.i;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: if (lhs > rhs.content.i) return 1; else return -1;
				case ValueType.realValue		: if (lhs > rhs.content.r) return 1; else return -1;
				case ValueType.booleanValue		: if (lhs > to!int(rhs.content.b)) return 1; else return -1;
				default							: break;
			}
		}
		else if (type==ValueType.realValue)
		{
			real lhs = content.r;

			switch (rhs.type) 
			{
				case ValueType.numberValue		: if (lhs > rhs.content.i) return 1; else return -1;
				case ValueType.realValue		: if (lhs > rhs.content.r) return 1; else return -1;
				case ValueType.booleanValue		: if (lhs > to!int(rhs.content.b)) return 1; else return -1;
				default							: break;
			}
		}
		else if (type==ValueType.stringValue)
		{
			// UNIMPLEMENTED
		}
		
		throw new ERR_UndefinedOperation("?",this,rhs);
	}

	static string getAsStr(const Value myv)
	{
		switch (myv.type)
		{
			case ValueType.numberValue  : return to!string(myv.content.i);
			case ValueType.realValue 	: return to!string(myv.content.r);
			case ValueType.stringValue  : return to!string(myv.content.s);
			case ValueType.booleanValue : return to!string(myv.content.b);
			case ValueType.arrayValue   :
				  string output="[";
			      foreach (int i, const Value v; myv.content.a)
			      {
			      	   output ~= getAsStr(v);

			      	   if (i!=myv.content.a.length-1) output ~= ",";
			      }
			      output~="]";
			      return output;
			case ValueType.dictionaryValue   :
				  string output="[";
				  int i=0;
			      foreach (Value k, const Value v; myv.content.d)
			      {

			      	   output ~= getAsStr(k);// k.str();
						
			      	   output ~= ":" ~ getAsStr(v);// v.str();

			      	   if (i!=myv.content.d.length-1) output ~= ", ";
			      	   i++;
			      }
			      output ~= "]";
			      return output;

			default						: break;
		}
		return null;
	}

	bool isEqualWith(Value v)
	{
		if (type!=v.type) return false;

		switch (type)
		{
			case ValueType.numberValue : return (content.i == v.content.i);
			case ValueType.realValue : return (content.r == v.content.r);
			case ValueType.stringValue : return (content.s == v.content.s);
			case ValueType.booleanValue : return (content.b == v.content.b);
			default: return true;
		}
		return false;
	}

	void removeSubvalue(Value sv)
	{
		if (type!=ValueType.arrayValue) return;

		Value[] newValues;

		foreach (Value v; content.a)
		{
			if (!v.isEqualWith(sv)) newValues ~= v;
		}

		content.a = newValues;
	}

	ValueContent get()
	{
		return content;
	}

	string str()
	{
		switch (type)
		{
			case ValueType.realValue	: return to!string(content.r);
			case ValueType.numberValue  : return to!string(content.i);
			case ValueType.stringValue  : return to!string(content.s);
			case ValueType.booleanValue : return to!string(content.b);
			case ValueType.arrayValue   :
				  string output="[";
			      foreach (int i, Value v; content.a)
			      {
			      		if (v.type==ValueType.stringValue) output ~= "\"";
			      	   output ~= v.str();
			      	   if (v.type==ValueType.stringValue) output ~= "\"";

			      	   if (i!=content.a.length-1) output ~= ",";
			      }
			      output~="]";
			      return output;
			case ValueType.dictionaryValue   :
				  string output="[";
				  int i=0;
			      foreach (Value k, Value v; content.d)
			      {
			      		if (k.type == ValueType.stringValue) output ~= "\"";
			      	   output ~= k.str();
						if (k.type == ValueType.stringValue) output ~= "\"";
			      	   output ~= ":";

			      	   if (v.type == ValueType.stringValue) output ~= "\"";
			      	    output ~= v.str();
			      	    if (v.type == ValueType.stringValue) output ~= "\"";

			      	   if (i!=content.d.length-1) output ~= ", ";
			      	   i++;
			      }
			      output ~= "]";
			      return output;

			default						: break;
		}
		return null;
	}

	string inspect(int level)
	{
		string ret = "";
		string tabs = replicate("\t",level);
		switch (type)
		{
			case ValueType.numberValue		:	ret = to!string(content.i); break;
			case ValueType.realValue		:	ret = to!string(content.r); break;
			case ValueType.booleanValue		:	ret = to!string(content.b); break;
			case ValueType.stringValue		:	ret = to!string("\"" ~ content.s ~ "\""); break;
			case ValueType.arrayValue 		:
				ret ~= "\n" ~ tabs ~ "[\n";
				for (int i=0; i<content.a.length; i++)
				{
					ret ~= tabs ~ "\t" ~ content.a[i].inspect(level+1);
					if (i!=content.a.length-1) ret ~= ",\n";
				}
				ret ~= "\n" ~ tabs ~ "]"; break;

			case ValueType.dictionaryValue 	:
				ret ~= "\n" ~ tabs ~ "[\n";
				int i;
				foreach (Value kv, Value vv; content.d)
				{
					ret ~= tabs ~ "\t" ~ kv.inspect(level+1) ~ " : " ~ vv.inspect(level+1);
					if (i!=content.d.length-1) ret ~= ",\n";
					i++;
				}
				ret ~= "\n" ~ tabs ~ "]"; break;
			default:
				break;
		}
		return ret;
	}
}