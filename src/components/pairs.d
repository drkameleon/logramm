/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** pairs.d
 **********************************************************/

module components.pairs;

//================================================
// Imports
//================================================

import core.memory;

import std.stdio;
import std.conv;

import components.pair;

import position;

//================================================
// C Interface for Bison
//================================================

extern (C) 
{
	void* Pairs_new() { return cast(void*)(new Pairs()); }
	void Pairs_add(Pairs p, Pair pa) {  GC.addRoot(cast(void*)p); p.add(pa); }

}

//================================================
// Functions
//================================================

class Pairs
{
	Pair[] list;

	this()
	{
	}

	void add(Pair pa)
	{
		list ~= pa;
	}
}