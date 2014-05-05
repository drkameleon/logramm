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
#include "parser.h"

/****************************************
 Extern & Forward declarations
 ****************************************/

void yyerror(const char* str);
void comment(void);
void count();

extern char* yyfilename;
extern int yycgiMode;

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
	char *s = reformat_error_msg(str);
	if (!yycgiMode)
	{
		fprintf(stderr,LGM_LOGO);
		fprintf(stderr,LGM_ERROR_TEMPLATE,yyfilename,yylineno,s);
	}
	else
	{
		fprintf(stdout,LGM_ERROR_TEMPLATE_HTML,yyfilename,yylineno,s);
	}
	exit(0);
}
