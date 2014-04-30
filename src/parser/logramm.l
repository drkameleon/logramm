%{
/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/parser/logramm.l
 **********************************************************/

/****************************************
 Includes
 ****************************************/

#include <stdio.h>
#include "logramm.tab.h"

/****************************************
 Extern & Forward declarations
 ****************************************/

void yyerror(const char* str);
void comment(void);
void count();

extern char* yyfilename;

%}

/****************************************
 Options
 ****************************************/

%option yylineno

/****************************************
 Building blocks
 ****************************************/

DIGIT				[0-9]
DIGIT_HEX			[a-fA-F0-9]
DIGIT_BIN			[01]
LETTER				[a-zA-Z]
LETTER_OR_USCORE	[a-zA-Z_]

/****************************************
 Tokens
 ****************************************/
%%

\"(\\.|[^\\"])*\"						{ count(); return STRING; }
'(\\.|[^\\'])+'							{ count(); return STRING; }

"/*"                                    { count(); comment(); /* Multi-line comment. Ignore. */ }
"//".*                                  { count(); /* Single-line comment. Ignore. */ }
"#!".*                                  { count(); /* She-bang line. Ignore. */ }

"external"								{ count(); return EXTERNAL; }
"#describe"								{ count(); return DESCRIBE; }

"else"|"!!"                             { count(); return ELSE; }
"return"|"==>"                          { count(); return RETURN; }
"break"|"%%"							{ count(); return BREAK; }
"exec"|"$>"								{ count(); return EXEC; }
"out"|">>"								{ count(); return OUT; }
"in"|"<<"								{ count(); return IN; }
"import"|"<-"							{ count(); return IMPORT; }
"loop"|"@"								{ count(); return '@'; }
"panic"									{ count(); return PANIC; }

"->"									{ count(); return FOREACH; }

"<=>"									{ count(); return RULE_EQ; }
"=>"									{ count(); return FUNC_EQ; }

"::"			                        { count(); return NAMED_BLOCK_START; }

"true"|"yes"|"false"|"no"|"~0"|"~1"     { count(); return BOOLEAN; }

"&&"									{ count(); return AND; }
"||"									{ count(); return OR; }
"^^"									{ count(); return XOR; }

"&"|"and"								{ count(); return BOOL_AND; }
"|"|"or"								{ count(); return BOOL_OR; }
"^"|"xor"								{ count(); return BOOL_XOR; }
"!"|"not"								{ count(); return BOOL_NOT; }


{LETTER_OR_USCORE}({LETTER_OR_USCORE}|{DIGIT})*	{ count(); return ID; }
{DIGIT}+								{ count(); return NUMBER; }
"0x"{DIGIT_HEX}+						{ count(); return NUMBER; }
"0b"{DIGIT_BIN}+						{ count(); return NUMBER; }
{DIGIT}+\.{DIGIT}+						{ count(); return NUMBER; }

"=="									{ count(); return EQ_OP; }
"<="									{ count(); return LE_OP; }
">="									{ count(); return GE_OP; }
"<"										{ count(); return LT_OP; }
">"										{ count(); return GT_OP; }
"!="									{ count(); return NE_OP; }

".."									{ count(); return RANGE; }

"+="									{ count(); return PLUS_EQ; }
"-="									{ count(); return MINUS_EQ; }
"*="									{ count(); return MULT_EQ; }
"/="									{ count(); return DIV_EQ; }
"%="									{ count(); return MOD_EQ; }
"||="									{ count(); return OR_EQ; }
"&&="									{ count(); return AND_EQ; }
"^^="									{ count(); return XOR_EQ; }
"="										{ count(); return EQ; }

"+"										{ count(); return PLUS_SG; }
"-"										{ count(); return MINUS_SG; }
"*"										{ count(); return MULT_SG; }
"/"										{ count(); return DIV_SG; }
"%"										{ count(); return MOD_SG; }

"\\"									{ count(); return '\\'; }
"?"										{ count(); return '?'; }
","										{ count(); return ','; }
":"										{ count(); return ':'; }
"."										{ count(); return '.'; }
";"										{ count(); return ';'; }
"{"                                     { count(); return '{'; }
"}"                                     { count(); return '}'; }
"("										{ count(); return '('; }
")"										{ count(); return ')'; }
"["										{ count(); return '['; }
"]"										{ count(); return ']'; }

"~"										{ count(); return '~'; }

"#"										{ count(); return '#'; }

[ \t\v\n\f]+                			{ count(); /* ignore whitespace */ }
.										{ count(); /* ignore it */ } 
%%

/****************************************
 Functions
 ****************************************/

int yycolumn = 0;

char *str_replace(char *orig, char *rep, char *with) 
{
	char *result;
	char *ins;
	char *tmp;
	int len_rep;
	int len_with;
	int len_front;
	int count;

	if (!orig)
		return NULL;
	if (!rep)
		rep = "";
	len_rep = strlen(rep);
	if (!with)
		with = "";
	len_with = strlen(with);

	ins = orig;
	for (count = 0; (tmp = strstr(ins, rep)); ++count) {
		ins = tmp + len_rep;
	}

	// first time through the loop, all the variable are set correctly
	// from here on,
	//    tmp points to the end of the result string
	//    ins points to the next occurrence of rep in orig
	//    orig points to the remainder of orig after "end of rep"
	tmp = result = malloc(strlen(orig) + (len_with - len_rep) * count + 1);

	if (!result)
		return NULL;

	while (count--) {
		ins = strstr(orig, rep);
		len_front = ins - orig;
		tmp = strncpy(tmp, orig, len_front) + len_front;
		tmp = strcpy(tmp, with) + len_with;
		orig += len_front + len_rep; // move to next "end of rep"
	}
	strcpy(tmp, orig);
	return result;
}

void comment(void)
{
	int c;

	while ((c = input()) != 0)
	{
		if (c == '*')
		{
			while ((c = input()) == '*');

			if (c == '/') return;
			if (c == 0) break;
		}
	}
}

void count()
{
	int i;
	
	for (i = 0; yytext[i] != '\0'; i++)
	{
		if (yytext[i] == '\n') yycolumn = 0;
		else if (yytext[i] == '\t') yycolumn += 8 - (yycolumn % 8);
		else yycolumn++;
	}

	//ECHO;
	yylval.str=strdup(yytext);
}

void yyerror(const char *str)
{
	char *s = str_replace((char*)str,"unexpected","Unexpected");
	s = str_replace(s,"syntax error, ","");
	s = str_replace(s,"\"","");
	s = str_replace(s,", expecting ","\n              | Expected ");

	fprintf(stderr,"\x1B[32mLogramm/03\n\x1B[0m(c) 2009-2014 Dr.Kameleon\n\n");
	fprintf(stderr,"\x1B[31mSyntax Error  \x1B[37m| \x1B[0mFile:\x1B[37m %s\n              | \x1B[0mLine:\x1B[37m %d\n\n              | %s\n\n",yyfilename,yylineno,s);
	exit(0);
}
