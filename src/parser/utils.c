/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/parser/utils.c
 **********************************************************/

//================================================
// Imports
//================================================ 

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "parser.h"

//================================================
// Functions
//================================================

char* reformat_error_msg(const char* msg)
{
	char* ret = str_replace((char*)msg,"unexpected","Unexpected");
	ret = str_replace(ret,"syntax error, ","");
	ret = str_replace(ret,"\"","");
	ret = str_replace(ret,", expecting ","\n              | Expected ");

	return ret;
}

char* str_replace(char *orig, char *rep, char *with) 
{
	char* result;
	char* ins;
	char* tmp;
	int len_rep;
	int len_with;
	int len_front;
	int count;

	if (!orig) return NULL;
	if (!rep) rep = "";

	len_rep = strlen(rep);

	if (!with) with = "";
	len_with = strlen(with);

	ins = orig;
	for (count = 0; (tmp = strstr(ins, rep)); ++count) 
	{
		ins = tmp + len_rep;
	}

	tmp = result = malloc(strlen(orig) + (len_with - len_rep) * count + 1);

	if (!result) return NULL;

	while (count--) 
	{
		ins = strstr(orig, rep);
		len_front = ins - orig;
		tmp = strncpy(tmp, orig, len_front) + len_front;
		tmp = strcpy(tmp, with) + len_with;
		orig += len_front + len_rep;
	}

	strcpy(tmp, orig);

	return result;
}
