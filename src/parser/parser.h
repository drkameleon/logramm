/**********************************************************
 **
 ** LOGRAMM
 ** Interpreter
 ** 
 ** (c) 2009-2014, Dr.Kameleon
 **
 **********************************************************
 ** src/parser/parser.h
 **********************************************************/

#ifndef __PARSER_H_
#define __PARSER_H_

//================================================
// Definitions
//================================================ 

#define LGM_LOGO 			"\x1B[32mLogramm/03\n\x1B[0m(c) 2009-2014 Dr.Kameleon\n\n"
#define LGM_ERROR_TEMPLATE 	"\x1B[31mSyntax Error  \x1B[37m| \x1B[0mFile:\x1B[37m %s\n              | \x1B[0mLine:\x1B[37m %d\n\n              | %s\n\n"

//================================================
// Macros
//================================================ 

#define POS(X) Set_Position(X,Position_new(yylineno,yyfilename));

//================================================
// Declarations
//================================================

// Utils

char* str_replace(char *orig, char *rep, char *with); 
char* reformat_error_msg(const char* msg);

//================================================
// External Globals
//================================================

extern void* _program;

//================================================
// D routine bindings
//================================================

extern void  Program_set(void* p, void* s);

extern void* Statements_new();
extern void  Statements_add(void* s, void* st);

extern void* Expressions_new();
extern void  Expressions_add(void* e, void* ex);
extern void  Expressions_addFromExpressions(void* e, void* ex);

extern void* Identifiers_new();
extern void  Identifiers_add(void* i, char* n);

extern void* Lvalue_new(char* n);
extern void* Lvalue_newFromId(void* l, char* n);
extern void* Lvalue_newFromHash(void* l, void* e);

extern void* Assignment_new(void* l, void* r, char* op);

extern void* Loop_new(void* b, void* s);

extern void* Foreach_new(char* i, void* e, void* s);
extern void* Foreach_newFromKeyValue(char* k, char* v, void* e, void* s);

extern void* Block_new(void* s);

extern void* Module_new(char* n, void* s);

extern void* Argument_new(char* t, char* v);
extern void* Argument_newFromFunction(void* f);
extern void* Argument_newFromDictionary(void* d);
extern void* Argument_newFromArray(void* a);
extern void* Argument_newFromHashItem(void* a, void* e);
extern void* Argument_newFromHashItemExpr(void* e, void* ex);
extern void* Argument_newFromSlice(void* s, void* a);
extern void* Argument_newFromSliceExpr(void* s, void* e);
extern void* Argument_newFromDotItem(void* a, char* i);
extern void* Argument_newFromDotItemExpr(void* e, char* i);
extern void* Argument_newFromFunctionWithParent(void* f, void* a);
extern void* Argument_newFromFunctionWithParentExpr(void* f, void* e);

extern void* HashItem_new(char* n, void* e);
extern void* HashItem_newFromArgument(char* a, void* e);
extern void* HashItem_newFromParent(void* h, void* e);

extern void* ArrayAr_new(void* e);
extern void* ArrayAr_newFromRange(void* l, void* r);
extern void* Slice_new(void* l, void* r);

extern void* Dictionary_new(void* d);

extern void* Pairs_new();
extern void* Pairs_add(void* p, void* pa);

extern void* Pair_new(void* k, void* v);

extern void* Expression_new(void* l, char* op, void* r);
extern void* Expression_newFromArgument(void* a);

extern void* RelExpression_new(void* l, char* op, void* r);

extern void* BoolExpression_new(void* l, char* op, void* r);
extern void* BoolExpression_newFromExpression(void* e);

extern void* FunctionDecl_new(char* n, void* i, void* s);
extern void* FunctionDecl_newWithDesc(char* n, void* i, void* s, void* d);
extern void* FunctionDecl_newFromReference(char* n, void* i, void* e);
extern void* FunctionDecl_newFromReferenceWithDesc(char* n, void* i, void* e, void* d);

extern void* FunctionDesc_new(char* n, void* i, void* d);

extern void* FactDecl_new(char* n, void* e);

extern void* RuleDecl_new(char* n, void* e, void* ex);

extern void* FunctionCall_new(char* n, void* e);
extern void* FunctionCall_newWithModule(char* m, void* f);

extern void* FunctionCallSt_new(void* f);
extern void* FunctionCallSt_newWithArgument(void* f, void* a);

extern void* ReturnSt_new(void* e);
extern void* BreakSt_new();

extern void* OutSt_new(void* e);
extern void* InSt_new(char* n);

extern void* IfSt_new(void* b, void* s, void* e);

extern void* ImportSt_new(char* n);

extern void* ExecSt_new(void* e);

extern void* PanicSt_new(void* e);

extern void* NullSt_new();

extern void* Position_new(int l, char* f);
extern void Set_Position(void* i, void* p);

#endif

