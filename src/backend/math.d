/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/backend/math.d
 **********************************************************/

module backend.math;

//================================================
// Imports
//================================================

import std.array;
import std.conv;
import std.math;
import std.stdio;
import std.string;

import value;

//================================================
// Class
//================================================

class LGM_Math
{
	static Value fromBase(Value[] v)
	{
		string num = v[0].content.s;
		ulong base = v[1].content.i;

		ulong ret = parse!ulong(num,to!int(base));

		return new Value(ret);
	}
	
	// sin, sinh, arcsin, arcsinh, etc...

	static Value sin(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.sin(n);

		return new Value(ret);
	}

	static Value cos(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.cos(n);

		return new Value(ret);
	}

	static Value tan(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.tan(n);

		return new Value(ret);
	}

	static Value sinh(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.sinh(n);

		return new Value(ret);
	}

	static Value cosh(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.cosh(n);

		return new Value(ret);
	}

	static Value tanh(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.tanh(n);

		return new Value(ret);
	}

	static Value arccos(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.acos(n);

		return new Value(ret);
	}

	static Value arcsin(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.asin(n);

		return new Value(ret);
	}

	static Value arctan(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.atan(n);

		return new Value(ret);
	}

	static Value arccosh(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.acosh(n);

		return new Value(ret);
	}

	static Value arcsinh(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.asinh(n);

		return new Value(ret);
	}

	static Value arctanh(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.atanh(n);

		return new Value(ret);
	}

	// Roundings

	static Value floor(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.floor(n);

		return new Value(ret);
	}

	static Value ceil(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.ceil(n);

		return new Value(ret);
	}

	static Value round(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.round(n);

		return new Value(ret);
	}

	// Misc

	static Value ln(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.log(n);

		return new Value(ret);
	}

	static Value log(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.log10(n);

		return new Value(ret);
	}

	static Value pow(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real n2;
		if (v[1].type==ValueType.numberValue) n2 = to!real(v[1].content.i);
		else n2 = v[1].content.r;

		real ret = std.math.pow(n,n2);

		return new Value(ret);
	}

	static Value exp(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.exp(n);

		return new Value(ret);
	}

	static Value sqrt(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;

		real ret = std.math.sqrt(n);

		return new Value(ret);
	}

	static Value trunc(Value[] v)
	{
		real n;
		if (v[0].type==ValueType.numberValue) n = to!real(v[0].content.i);
		else n = v[0].content.r;
		
		real ret = std.math.trunc(n);

		return new Value(ret);
	}

	// Constants

	static Value e(Value[] v)
	{
		real ret = std.math.E;

		return new Value(ret);
	}

	static Value pi(Value[] v)
	{
		real ret = std.math.PI;

		return new Value(ret);
	}
}
