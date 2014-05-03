%{
/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/parser/logramm.y
 **********************************************************/

/****************************************
 Includes
 ****************************************/
 
#include "parser.h"

/****************************************
 Extern & Forward declarations
 ****************************************/

extern void yyerror(const char* str);
extern int yyparse(void);
extern int yylex();

extern int yylineno;

char* yyfilename;

/****************************************
 Functions
 ****************************************/ 
 
int yywrap()
{
	return 1;
} 

%}

/****************************************
 Definitions
 ****************************************/

%union 
{
	char* str;
	void* compo;
}

/****************************************
 Tokens & Types
 ****************************************/

%token <str> ID "id"
%token <str> NUMBER "number"
%token <str> STRING "string literal"

%token <str> EXTERNAL "'#external'"
%token <str> DESCRIBE "'#describe'"

%token <str> ELSE "'else' ('!!')"
%token <str> RETURN "'return' ('==>')"
%token <str> BREAK "'break' ('%%')"
%token <str> EXEC "'exec' ('$>')"
%token <str> BOOLEAN "boolean"

%token <str> PANIC "'panic'"

%token <str> FOREACH "'->'"

%token <str> NAMED_BLOCK_START "'::'"

%token <str> OUT "'out' ('>>')"
%token <str> IN  "'in' ('<<')"
%token <str> IMPORT "'import' ('<-')"

%token <str> EQ_OP "=="
%token <str> LE_OP "<="
%token <str> LT_OP "<"
%token <str> GE_OP ">="
%token <str> GT_OP ">"
%token <str> NE_OP "!="

%token <str> BOOL_AND "'and' ('&')"
%token <str> BOOL_OR "'or' ('|')"
%token <str> BOOL_XOR "'xor' ('^')"
%token <str> BOOL_NOT "'not' ('!')"

%token <str> RANGE "'..'"

%token <str> RULE_EQ "'<=>'"
%token <str> FUNC_EQ "'=>'"

%token <str> EQ "'='"
%token <str> PLUS_EQ "'+='"
%token <str> MINUS_EQ "'-='"
%token <str> MULT_EQ "'*='"
%token <str> DIV_EQ "'/='"
%token <str> MOD_EQ "'%='"
%token <str> OR_EQ "'||='"
%token <str> AND_EQ "'&&='"
%token <str> XOR_EQ "'^^='"

%token <str> AND "'&&'"
%token <str> OR "'||'"
%token <str> XOR "'^^'"

%token <str> PLUS_SG "'+'"
%token <str> MINUS_SG "'-'"
%token <str> MULT_SG "'*'"
%token <str> DIV_SG "'/'"
%token <str> MOD_SG "'%'"

%token END 0 "End of file"

%type <str> identifier comparison_op

%type <compo> argument expression expressions function_call rel_expression lvalue
%type <compo> bool_expression array pair pairs dictionary slice
%type <compo> assignment_st loop_st foreach_st
%type <compo> statement statements block_st module_st 
%type <compo> function_decl_st function_call_st rule_decl_st fact_st
%type <compo> return_st out_st in_st import_st if_st exec_st function_ref_st 
%type <compo> function_desc_st null_st break_st panic_st
%type <compo> program

/****************************************
 Directives
 ****************************************/

%glr-parser
%expect-rr 2
%locations
%define parse.error verbose

%left PLUS_SG MINUS_SG
%left MULT_SG DIV_SG MOD_SG
%left AND OR XOR

%left BOOL_AND
%left BOOL_OR
%left BOOL_XOR

%nonassoc UMINUS

%nonassoc "THEN"
%nonassoc ELSE

%nonassoc EQ
%nonassoc PLUS_EQ
%nonassoc MINUS_EQ
%nonassoc MULT_EQ
%nonassoc DIV_EQ
%nonassoc MOD_EQ
%nonassoc AND_EQ
%nonassoc OR_EQ
%nonassoc XOR_EQ

%start program
%%

/****************************************
 Grammar Rules
 ****************************************/

//==============================
// Building blocks
//==============================

comparison_op			: 	EQ_OP
						| 	LE_OP												
						| 	GE_OP												
						| 	LT_OP												
						|	GT_OP												
						| 	NE_OP
						;

identifier				:	ID
						|	identifier[parent] '.' ID 										
							{ 
								asprintf(&$$, "%s|%s", $parent, $ID); 
							} 								
						;

// 2 shift/reduce . conflict with "expressions"
// -- e.g. ID,ID,ID can be either 'identifiers' or 'expressions'

array					: 	'[' expressions ']'    										
							{ 
								$$ = ArrayAr_new($expressions); 
							}

						| 	'[' expression[left] RANGE expression[right] ']'				
							{ 
								$$ = ArrayAr_newFromRange($left, $right); 
							}

						| 	'[' ']'															
							{ 
								$$ = ArrayAr_new(Expressions_new()); 
							}
						;

pair 					: 	expression[key] ':' expression[value]							
							{ 
								$$ = Pair_new($key, $value); 
							}
						;

pairs					:	pair 															
							{ 
								$$ = Pairs_new(); 
								Pairs_add($$, $pair); 
							}

						|	pairs[previous] ',' pair 										
							{ 
								Pairs_add($previous, $pair); 
								$$ = $previous; 
							}
						;

dictionary 				:	'[' pairs ']'													
							{ 
								$$ = Dictionary_new($pairs); 
							}

						|	'[' ':' ']'														
							{ 
								$$ = Dictionary_new(Pairs_new()); 
							}
						;

function_call 			: 	ID '(' ')'														
							{ 
								$$ = FunctionCall_new($ID, Expressions_new()); 
							}

						| 	ID '(' expressions ')'											
							{ 
								$$ = FunctionCall_new($ID, $expressions); 
							}

						| 	ID NAMED_BLOCK_START function_call[main] 							
							{ 
								$$ = FunctionCall_newWithModule($ID, $main); 
							}
						;

slice					:	expression[left] RANGE expression[right]						
							{ 
								$$ = Slice_new($left, $right); 
							}

						|	expression[left] RANGE											
							{ 
								$$ = Slice_new($left, NULL); 
							}

						|	RANGE expression[right]											
							{ 
								$$ = Slice_new(NULL, $right); 
							}
						;


argument				:	ID																
							{ 
								$$ = Argument_new("id", $ID); 
							}
		
						|	NUMBER 															
							{ 
								$$ = Argument_new("number", $NUMBER); 
							}

						|	STRING 															
							{ 
								$$ = Argument_new("string", $STRING); 
							}

						|	'.' ID															
							{ 
								$$ = Argument_new("string", $ID); 
							}

						|	BOOLEAN 														
							{ 
								$$ = Argument_new("boolean", $BOOLEAN); 
							}

						|	'?'																
							{ 
								$$ = Argument_new("id","?"); 
							}

						|	array 															
							{ 
								$$ = Argument_newFromArray($array); 
							}

						|	dictionary														
							{ 
								$$ = Argument_newFromDictionary($dictionary); 
							}

						|	function_call 													
							{ 
								$$ = Argument_newFromFunction($function_call); 
							}

						|	argument[previous] '[' slice ']'								
							{ 
								$$ = Argument_newFromSlice($slice,$previous); 
							}

						|	argument[previous] '.' function_call 							
							{ 
								$$ = Argument_newFromFunctionWithParent($function_call, $previous); 
							}

						| 	argument[previous] '.' ID 										
							{ 
								$$ = Argument_newFromDotItem($previous, $ID); 
							}

						|	argument[previous] '[' expression ']' 							
							{ 
								$$ = Argument_newFromHashItem($previous, $expression); 
							}

						|	'(' expression ')' '[' slice ']'
							{
								$$ = Argument_newFromSliceExpr($slice, $expression);
							}

						|	'(' expression ')' '.' function_call
							{
								$$ = Argument_newFromFunctionWithParentExpr($function_call, $expression);
							}

						|	'(' expression ')' '.' ID
							{
								$$ = Argument_newFromDotItemExpr($expression, $ID);
							}
						
						|	'(' expression[previous] ')' '[' expression[main] ']'
							{
								$$ = Argument_newFromHashItemExpr($previous, $main);
							}
						;

// 2 rr : ID.ID, ID[ID] --> is an argument or an lvalue?
lvalue					:	ID 																
							{
								$$ = Lvalue_new($ID); 
							}

						|	lvalue[previous] '.' ID  										
							{ 
								$$ = Lvalue_newFromId($previous, $ID); 
							}

						|	lvalue[previous] '[' expression ']'								
							{ 
								$$ = Lvalue_newFromHash($previous, $expression); 
							}
						;

expression				: 	argument														
							{ 
								$$ = Expression_newFromArgument($argument); 
							}

						| 	'(' expression[main] ')'										
							{ 
								$$ = Expression_new($main, "", NULL); 
							}

						| 	expression[left] PLUS_SG expression[right] 						
							{ 
								$$ = Expression_new($left, "+", $right); 
							}

						| 	expression[left] MINUS_SG expression[right] 					
							{ 
								$$ = Expression_new($left, "-", $right); 
							}

						| 	expression[left] MULT_SG expression[right] 						
							{ 
								$$ = Expression_new($left, "*", $right); 
							}

						| 	expression[left] DIV_SG expression[right] 						
							{ 
								$$ = Expression_new($left, "/", $right); 
							}

						| 	expression[left] MOD_SG expression[right] 						
							{ 
								$$ = Expression_new($left, "%", $right); 
							}

						|	expression[left] AND expression[right]							
							{ 
								$$ = Expression_new($left, "&&", $right); 
							}

						|	expression[left] OR expression[right]							
							{ 
								$$ = Expression_new($left, "||", $right); 
							}

						|	expression[left] XOR expression[right]							
							{ 
								$$ = Expression_new($left, "^^", $right); 
							}

						| 	MINUS_SG expression[main] %prec UMINUS 							
							{ 
								$$ = Expression_new($main, "u-", NULL); 
							} 
						;

rel_expression			:	expression[left] comparison_op expression[right] 				
							{ 
								$$ = RelExpression_new($left, $comparison_op, $right); 
							}

						|	'(' rel_expression[main] ')'									
							{ 
								$$ = $main; 
							}
						;

bool_expression 		:	expression 														
							{ 
								$$ = BoolExpression_newFromExpression($expression); 
							}

						| 	rel_expression 													
							{ 
								$$ = BoolExpression_new($rel_expression, "", NULL); 
							}

						|	bool_expression[left] BOOL_AND bool_expression[right] 			
							{ 
								$$ = BoolExpression_new($left, $BOOL_AND, $right); 
							}

						|	bool_expression[left] BOOL_OR bool_expression[right] 			
							{ 
								$$ = BoolExpression_new($left, $BOOL_OR, $right); 
							}

						| 	bool_expression[left] BOOL_XOR bool_expression[right]			
							{ 
								$$ = BoolExpression_new($left, $BOOL_XOR, $right); 
							}

						| 	'(' bool_expression[left] BOOL_AND bool_expression[right] ')' 	
							{ 
								$$ = BoolExpression_new($left, $BOOL_AND, $right); 
							}

						| 	'(' bool_expression[left] BOOL_OR bool_expression[right] ')' 	
							{ 
								$$ = BoolExpression_new($left, $BOOL_OR, $right); 
							}

						| 	'(' bool_expression[left] BOOL_XOR bool_expression[right] ')' 	
							{ 
								$$ = BoolExpression_new($left, $BOOL_XOR, $right); 
							}
						;

expressions				:	expression 														
							{ 
								$$ = Expressions_new(); 
								Expressions_add($$, $expression); 
							}

						| 	expressions[previous] ',' expression 							
							{ 
								Expressions_add($previous, $expression); 
								$$ = $previous;
							}
						;

//==============================
// Statements
//==============================

if_st					:	bool_expression ':' statement %prec "THEN"						
							{ 
								$$ = IfSt_new($bool_expression, $statement, NULL); 
							}

						|	bool_expression ':' statement[main] ELSE ':' statement[else_st] 
							{ 
								$$ = IfSt_new($bool_expression, $main, $else_st); 
							}
						;

function_call_st		:	function_call ';'												
							{ 
								$$ = FunctionCallSt_new($function_call); 
							}

						|	argument '.' function_call ';'									
							{ 
								$$ = FunctionCallSt_newWithArgument($function_call, $argument); 
							}
						;

function_decl_st		:	ID '(' ')' FUNC_EQ '{' statements '}'  							
							{ 
								$$ = FunctionDecl_new($ID, Expressions_new(), $statements); 
							}

						|	ID '(' expressions ')' FUNC_EQ '{' statements '}' /* CH*/ 		
							{ 
								$$ = FunctionDecl_new($ID, $expressions, $statements); 
							}

						|	ID '(' ')' FUNC_EQ bool_expression ';'								
							{ 
								void* st = Statements_new(); 
								void* returnSt = ReturnSt_new($bool_expression);
								POS(returnSt);
								Statements_add(st, returnSt); 
								$$ = FunctionDecl_new($ID, Expressions_new(), st); 
							}

						| 	ID '(' expressions ')' FUNC_EQ bool_expression ';'	  			
							{ 
								void* st = Statements_new(); 
								void* returnSt = ReturnSt_new($bool_expression);
								POS(returnSt);
								Statements_add(st, returnSt); 
								$$ = FunctionDecl_new($ID, $expressions, st); 														
							}

						|	ID '(' ')' FUNC_EQ '#' dictionary '{' statements '}'  			
							{ 
								$$ = FunctionDecl_newWithDesc($ID, Expressions_new(), $statements,$dictionary); 
							}

						|	ID '(' expressions ')' '#' dictionary FUNC_EQ '{' statements '}' 
							{ 
								$$ = FunctionDecl_newWithDesc($ID, $expressions, $statements,$dictionary); 
							}

						|	ID '(' ')' '#' dictionary FUNC_EQ bool_expression ';'								
							{ 
								void* st = Statements_new(); 
								void* returnSt = ReturnSt_new($bool_expression);
								POS(returnSt);
								Statements_add(st, returnSt); 
								$$ = FunctionDecl_newWithDesc($ID, Expressions_new(), st, $dictionary); 
							}

						| 	ID '(' expressions ')' '#' dictionary FUNC_EQ bool_expression ';'	
							{ 
								void* st = Statements_new(); 
								void* returnSt = ReturnSt_new($bool_expression);
								POS(returnSt);
								Statements_add(st, returnSt); 
								$$ = FunctionDecl_newWithDesc($ID, $expressions, st, $dictionary); 	
							}
						;

fact_st					:	ID '(' expressions ')' BOOL_NOT 								
							{ 
								$$ = FactDecl_new($ID,$expressions); 
							}
						;

function_ref_st			:	EXTERNAL ID '(' ')' FUNC_EQ expression ';'						
							{ 
								$$ = FunctionDecl_newFromReference($ID, Expressions_new(), $expression); 
							}

						|	EXTERNAL ID '(' expressions ')' FUNC_EQ expression ';' 			
							{ 
								$$ = FunctionDecl_newFromReference($ID, $expressions, $expression); 
							}

						|	EXTERNAL ID '(' ')' '#' dictionary FUNC_EQ expression ';'						
							{ 
								$$ = FunctionDecl_newFromReferenceWithDesc($ID, Expressions_new(), $expression, $dictionary); 
							}

						|	EXTERNAL ID '(' expressions ')' '#' dictionary FUNC_EQ expression ';' 			
							{ 
								$$ = FunctionDecl_newFromReferenceWithDesc($ID, $expressions, $expression, $dictionary); 
							}
						;

function_desc_st		:	DESCRIBE ID '(' ')' FUNC_EQ expression ';'						
							{ 
								$$ = FunctionDesc_new($ID, Expressions_new(), $expression); 
							}

						|	DESCRIBE ID '(' expressions ')' FUNC_EQ expression ';' 			
							{ 
								$$ = FunctionDesc_new($ID, $expressions, $expression); 
							}
						;

rule_decl_st			:	ID '(' expressions ')' RULE_EQ expression ';'					
							{ 
								$$ = RuleDecl_new($ID, $expressions, $expression); 
							}
						;

assignment_st			:	lvalue EQ expression ';'										
							{ 
								$$ = Assignment_new($lvalue, $expression,"="); 
							}

						|	lvalue PLUS_EQ expression ';'									
							{ 
								$$ = Assignment_new($lvalue, $expression,"+="); 
							}

						|	lvalue MINUS_EQ expression 	';'									
							{ 
								$$ = Assignment_new($lvalue, $expression,"-="); 
							}

						|	lvalue MULT_EQ expression ';'									
							{ 
								$$ = Assignment_new($lvalue, $expression,"*="); 
							}

						|	lvalue DIV_EQ expression ';'									
							{ 
								$$ = Assignment_new($lvalue, $expression,"/="); 
							}

						|	lvalue MOD_EQ expression ';'									
							{ 
								$$ = Assignment_new($lvalue, $expression,"%="); 
							}

						|	lvalue AND_EQ expression ';'									
							{ 
								$$ = Assignment_new($lvalue, $expression,"&&="); 
							}

						|	lvalue OR_EQ expression ';'										
							{ 
								$$ = Assignment_new($lvalue, $expression,"||="); 
							}

						|	lvalue XOR_EQ expression ';'									
							{ 
								$$ = Assignment_new($lvalue, $expression,"^^="); 
							}
						;

loop_st					:	'@' bool_expression ':' statement 								
							{ 
								$$ = Loop_new($bool_expression, $statement); 
							}
						;

foreach_st				:	'@' ID FOREACH expression ':' statement 						
							{ 
								$$ = Foreach_new($ID, $expression, $statement); 
							}

						|	'@' ID[key] ',' ID[value] FOREACH expression ':' statement      
							{ 
								$$ = Foreach_newFromKeyValue($key, $value, $expression, $statement); 
							}
						;

block_st 				: 	'{' statements '}'												
							{ 
								$$ = Block_new($statements); 
							}
						;

module_st				:	ID NAMED_BLOCK_START '{' statements '}'							
							{ 
								$$ = Module_new($ID, $statements); 
							}

						|	ID[main] '~' ID[inherit] NAMED_BLOCK_START '{' statements '}'	
							{ 
								$$ = Module_new($main, $statements); 
							}			
						;

return_st				:	RETURN bool_expression ';'											
							{ 
								$$ = ReturnSt_new($bool_expression); 
							}
						;

break_st				:	BREAK ';'														
							{ 
								$$ = BreakSt_new(); 
							}
						;

out_st					:	OUT expression ';'												
							{ 
								$$ = OutSt_new($expression); 
							}
						;

in_st					:	IN ID ';'														
							{ 
								$$ = InSt_new($ID); 
							}
						;

import_st				:	IMPORT identifier ';'											
							{ 
								$$ = ImportSt_new($identifier); 
							}
						;

exec_st					:	EXEC expression ';'												
							{ 
								$$ = ExecSt_new($expression); 
							}
						;

panic_st				:	PANIC expression ';'												
							{ 
								$$ = PanicSt_new($expression); 
							}
						;

null_st					: 	';'																
							{ 
								$$ = NullSt_new(); 
							}
						;

statement 				:	assignment_st													
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	block_st 														
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	loop_st															
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	foreach_st														
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	module_st														
							{ 
								$$ = $1; 
								POS($$); 
							}

						| 	function_decl_st												
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	fact_st															
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	function_ref_st													
							{ 
								$$ = $1; POS($$); 
							}

						|	function_desc_st												
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	rule_decl_st													
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	return_st														
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	break_st														
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	out_st															
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	function_call_st												
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	in_st															
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	import_st														
							{ 
								$$ = $1; 
								POS($$); 
							}

						| 	if_st															
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	exec_st															
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	panic_st														
							{ 
								$$ = $1; 
								POS($$); 
							}

						|	null_st															
							{ 
								$$ = $1; 
								POS($$); 
							}
						;

statements 				:	statements[previous] statement 									
							{ 
								void* st = $previous; Statements_add(st, $statement); 
								$$ = st; 
							}
						|	/* Nothing */																
							{ 
								$$ = Statements_new(); 
							}
						;

//==============================
// Entry point
//==============================

program					:	statements 														
							{ 
								Program_set(_program, $statements); 
							}
						;

%%

/****************************************
  This is the end,
  my only friend, the end...
 ****************************************/
