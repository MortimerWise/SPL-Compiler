%{

 /* Program Summary:
This is the parser which also includes code generation. 

History: 01/12/2017
Version 1.0 */


/* declare some standard headers to be used to import declarations
   and libraries into the parser. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* make forward declarations to avoid compiler warnings */
int yylex (void);
void yyerror (char *);
char thisType;

/* These constants are used later in the code */
#define SYMTABSIZE     50
#define IDLENGTH       15
#define NOTHING        -1
#define INDENTOFFSET    2

  enum ParseTreeNodeType {PROGRAM, BLOCK, STATEMENT, STATEMENT_LIST, ASSIGNMENT_STATEMENT, IF_STATEMENT, DO_STATEMENT, 
						WHILE_STATEMENT, FOR_STATEMENT, WRITE_STATEMENT, READ_STATEMENT, OUTPUT_LIST, 
						CONDITIONAL, VARIABLES, COMPARATOR, EXPRESSION, TERM, VALUE, CONSTANT, CHARACTER_CONSTANT,
						NUMBER_CONSTANT, NUMBER_CONSTANT_MINUS, NUMBER_CONSTANT_NUMBER, NUMBER_CONSTANT_FULLSTOP, DECLARATION_BLOCK, TYPE_C, TYPE_I, TYPE_R,
						AND_CONDITIONAL, OR_CONDITIONAL, NEWLINE_STATEMENT} ;  
                          /* Add more types here, as more nodes
                                           added to tree */

	char *NodeName[] = {"PROGRAM", "BLOCK", "STATEMENT", "STATEMENT_LIST", "ASSIGNMENT_STATEMENT", "IF_STATEMENT", "DO_STATEMENT",
						"WHILE_STATEMENT", "FOR_STATEMENT", "WRITE_STATEMENT", "READ_STATEMENT", "OUTPUT_LIST",
						"CONDITIONAL", "VARIABLES", "COMPARATOR", "EXPRESSION", "TERM", "VALUE", "CONSTANT", "CHARACTER_CONSTANT",
						"NUMBER_CONSTANT", "NUMBER_CONSTANT_MINUS", "NUMBER_CONSTANT_NUMBER", "NUMBER_CONSTANT_FULLSTOP", "DECLARATION_BLOCK", "TYPE_C", "TYPE_I", "TYPE_R",
						"AND_CONDITIONAL", "OR_CONDITIONAL", "NEWLINE_STATEMENT"} ;									   
										   
#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

/* ------------- parse tree definition --------------------------- */

struct treeNode {
    int  item;
    int  nodeIdentifier;
    struct treeNode *first;
    struct treeNode *second;
    struct treeNode *third;
  };

typedef  struct treeNode TREE_NODE;
typedef  TREE_NODE        *TERNARY_TREE;

/* ------------- forward declarations --------------------------- */

TERNARY_TREE create_node(int,int,TERNARY_TREE,TERNARY_TREE,TERNARY_TREE);
#ifdef DEBUG
void PrintTree(TERNARY_TREE,int);
#endif
void PrintCode(TERNARY_TREE);

int forLoops = 0;
/* ------------- symbol table definition --------------------------- */

struct symTabNode {
    char identifier[IDLENGTH];
	char dataType;
};

typedef  struct symTabNode SYMTABNODE;
typedef  SYMTABNODE        *SYMTABNODEPTR;

SYMTABNODEPTR  symTab[SYMTABSIZE]; 

int currentSymTabSize = 0;

%}

/****************/
/* Start symbol */
/****************/

%start  program

/**********************/
/* Action value types */
/**********************/

%union {
    int iVal;
    TERNARY_TREE  tVal;
}

%token SEMICOLON ENDP FULLSTOP DECLARATIONS CODE COMMA TYPE OF CHARACTER INTEGER REAL RIGHT_ARROW THEN IF ENDIF 
%token ELSE WHILE DO ENDDO ENDWHILE IS BY FOR TO ENDFOR WRITE LEFT_BRACKET RIGHT_BRACKET NEWLINE READ NOT COLON
%token EQUALS NOT_EQUAL LESS_THAN GREATER_THAN LESS_EQUALS GREATER_EQUALS PLUS MINUS TIMES DIVIDE APOSTROPHE OR AND ASSIGNS

%token<iVal> IDENTIFIER NUMBER

%type<tVal> program statement_list type declaration_block variables statement assignment_statement if_statement 
%type<tVal> do_statement while_statement for_statement write_statement read_statement output_list conditional 
%type<tVal> comparator expression term value constant character_constant number_constant block

%%

program : IDENTIFIER COLON block ENDP IDENTIFIER FULLSTOP
			{ TERNARY_TREE ParseTree;
				ParseTree = create_node($1,PROGRAM,$3,create_node($5,PROGRAM,NULL,NULL,NULL),NULL);
#ifdef DEBUG				
				PrintTree(ParseTree,0);
#endif
				PrintCode(ParseTree);			
			}
	;		
block : DECLARATIONS declaration_block CODE statement_list 
			{
				$$ = create_node(NOTHING, BLOCK, $2, $4, NULL);
			}			
			| CODE statement_list
			{
				$$ = create_node(NOTHING, BLOCK, $2, NULL, NULL);
			}	
	;
variables : IDENTIFIER COMMA variables 
			{
				$$ = create_node($1, VARIABLES, $3, NULL, NULL);
			}
			| IDENTIFIER
			{
				$$ = create_node($1, VARIABLES, NULL, NULL, NULL);
			}
	;
declaration_block : variables OF TYPE type SEMICOLON declaration_block
			{
				$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, $6);
			}				
			| variables OF TYPE type SEMICOLON
			{
				$$ = create_node(NOTHING, DECLARATION_BLOCK, $1, $4, NULL);
			}
	;							
type : CHARACTER
			{
				$$ = create_node(NOTHING, TYPE_C, NULL, NULL, NULL);
			}
			| INTEGER
			{
				$$ = create_node(NOTHING, TYPE_I, NULL, NULL, NULL);
			}
			| REAL	
			{
				$$ = create_node(NOTHING, TYPE_R, NULL, NULL, NULL);
			}
	;				
statement_list : statement
				{
					$$ = create_node(NOTHING, STATEMENT_LIST, $1, NULL, NULL );
				}
				| statement SEMICOLON statement_list
				{
					$$ = create_node(NOTHING, STATEMENT_LIST, $1, $3, NULL);
				}
	;				
statement : assignment_statement
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| if_statement
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| do_statement
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| while_statement
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| for_statement
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| write_statement
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
			| read_statement
			{
				$$ = create_node(NOTHING, STATEMENT, $1, NULL, NULL);
			}
	;
assignment_statement : expression RIGHT_ARROW IDENTIFIER
			{
				$$ = create_node($3, ASSIGNMENT_STATEMENT, $1, NULL, NULL);
			}
	;
if_statement : IF conditional THEN statement_list ENDIF
			{
				$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, NULL);
			}
			|	IF conditional THEN statement_list ELSE statement_list ENDIF
			{
				$$ = create_node(NOTHING, IF_STATEMENT, $2, $4, $6);
			}
	;		
do_statement : DO statement_list WHILE conditional ENDDO
			{
				$$ = create_node(NOTHING, DO_STATEMENT, $2, $4, NULL);
			}
	;
while_statement : WHILE conditional DO statement_list ENDWHILE
			{
				$$ = create_node(NOTHING, WHILE_STATEMENT, $2, $4, NULL);
			}
	;
for_statement : FOR IDENTIFIER IS expression BY expression TO expression DO statement_list ENDFOR
			{
				$$ = create_node($2, FOR_STATEMENT, $4, $6, create_node(NOTHING, FOR_STATEMENT, $8, $10, NULL));
			}
	;
write_statement : WRITE LEFT_BRACKET output_list RIGHT_BRACKET
			{
				$$ = create_node(NOTHING, WRITE_STATEMENT, $3, NULL, NULL);
			}
				| NEWLINE
			{
				$$ = create_node(NOTHING, NEWLINE_STATEMENT, NULL, NULL, NULL);
			}	
	;
read_statement : READ LEFT_BRACKET IDENTIFIER RIGHT_BRACKET
			{
				$$ = create_node($3, READ_STATEMENT, NULL, NULL, NULL);
			}
	;
output_list : value
			{
				$$ = create_node(NOTHING, OUTPUT_LIST, $1, NULL, NULL);
			}
			| value COMMA output_list
			{
				$$ = create_node(NOTHING, OUTPUT_LIST, $1, $3, NULL);
			}
	;			

conditional : NOT conditional
			{
				$$ = create_node(NOTHING, CONDITIONAL, $2, NULL, NULL);
			}
			| expression comparator expression AND conditional
			{
				$$ = create_node(NOTHING, AND_CONDITIONAL, $1, $2, create_node(NOTHING, CONDITIONAL, $3, $5, NULL));
			}
			| expression comparator expression OR conditional
			{
				$$ = create_node(NOTHING, OR_CONDITIONAL, $1, $2, create_node(NOTHING, CONDITIONAL, $3, $5, NULL));
			}
			| expression comparator expression
			{
				$$ = create_node(NOTHING, CONDITIONAL, $1, $2, $3);
			}
	;		
comparator : EQUALS
			{
				$$ = create_node(EQUALS, COMPARATOR, NULL, NULL, NULL);
			}
			| NOT_EQUAL
			{
				$$ = create_node(NOT_EQUAL, COMPARATOR, NULL, NULL, NULL);
			}
			| LESS_THAN
			{
				$$ = create_node(LESS_THAN, COMPARATOR, NULL, NULL, NULL);
			}
			| GREATER_THAN
			{
				$$ = create_node(GREATER_THAN, COMPARATOR, NULL, NULL, NULL);
			}
			| LESS_EQUALS
			{
				$$ = create_node(LESS_EQUALS, COMPARATOR, NULL, NULL, NULL);
			}
			| GREATER_EQUALS
			{
				$$ = create_node(GREATER_EQUALS, COMPARATOR, NULL, NULL, NULL);
			}
	;
expression : term PLUS expression
			{
				$$ = create_node(PLUS, EXPRESSION, $1, $3, NULL);
			}
			| term MINUS expression
			{
				$$ = create_node(MINUS, EXPRESSION, $1, $3, NULL);
			}
			| term
			{
				$$ = create_node(TERM, EXPRESSION, $1, NULL, NULL);
			}
	;
term : value TIMES term
			{
				$$ = create_node(TIMES, TERM, $1, $3, NULL);
			}
			| value DIVIDE term
			{
				$$ = create_node(DIVIDE, TERM, $1, $3, NULL);
			}
			| value
			{
				$$ = create_node(VALUE, TERM, $1, NULL, NULL);
			}
	;	
value : IDENTIFIER
			{
				$$ = create_node($1, VALUE, NULL, NULL, NULL);
			}
			| constant
			{
				$$ = create_node(NOTHING, VALUE, $1, NULL, NULL);
			}
			| LEFT_BRACKET expression RIGHT_BRACKET
			{
				$$ = create_node(NOTHING, VALUE, $2, NULL, NULL);
			}
	;	
constant : number_constant
			{
				$$ = create_node(NOTHING, CONSTANT, $1, NULL, NULL);
			}
			| character_constant
			{
				$$ = create_node(NOTHING, CONSTANT, $1, NULL, NULL);
			}
	;		

character_constant : APOSTROPHE IDENTIFIER APOSTROPHE
			{
				$$ = create_node($2, CHARACTER_CONSTANT, NULL, NULL, NULL);
			}
	;
number_constant : MINUS NUMBER
				{
				$$ = create_node($2, NUMBER_CONSTANT_MINUS, NULL, NULL, NULL);
				}
				| NUMBER
				{
				$$ = create_node($1, NUMBER_CONSTANT_NUMBER, NULL, NULL, NULL);
				}
				| MINUS NUMBER FULLSTOP NUMBER
				{
				$$ = create_node($2, NUMBER_CONSTANT_MINUS, create_node($4,NUMBER_CONSTANT_FULLSTOP, NULL, NULL, NULL), NULL, NULL);
				}
				| NUMBER FULLSTOP NUMBER
				{
				$$ = create_node($1, NUMBER_CONSTANT_NUMBER, create_node($3, NUMBER_CONSTANT_FULLSTOP, NULL, NULL, NULL), NULL, NULL);
				}
	;			
				
%%

/* Code for routines for managing the Parse Tree */

TERNARY_TREE create_node(int ival, int case_identifier, TERNARY_TREE p1,
			 TERNARY_TREE  p2, TERNARY_TREE  p3)
{
    TERNARY_TREE t;
    t = (TERNARY_TREE)malloc(sizeof(TREE_NODE));
    t->item = ival;
    t->nodeIdentifier = case_identifier;
    t->first = p1;
    t->second = p2;
    t->third = p3;
    return (t);
}

/* Put other auxiliary functions here */

#ifdef DEBUG
void PrintTree(TERNARY_TREE t, int indent)
{	int i;
	if (t == NULL) return;
	for (i=indent; i; i-- ) printf(" ");
	if (t->nodeIdentifier == NUMBER)
		printf("Number: %d ", t->item);
	else if (t->nodeIdentifier == IDENTIFIER ||
			t->nodeIdentifier == ASSIGNMENT_STATEMENT)
			if (t->item >= 0 && t->item < SYMTABSIZE)
				printf("Identifier: %s ",symTab[t->item]->identifier);
			else printf("Unknown Identifier: %d ",t->item);
	else if (t->item != NOTHING) printf (" Item: %d ", t->item);
	if (t->nodeIdentifier < 0 || t->nodeIdentifier > sizeof(NodeName))
	 printf("Unknown nodeIdentifier: %d\n",t->nodeIdentifier);
    else 
	 printf("%s\n",NodeName[t->nodeIdentifier]);
    PrintTree(t->first,indent+3);
    PrintTree(t->second,indent+3);
    PrintTree(t->third,indent+3);
}
#endif

void PrintCode(TERNARY_TREE t)
{
	if (t == NULL) return;
		switch(t->nodeIdentifier)
		{

/*PROGRAM*/
		case(PROGRAM) :
			printf("#include <stdio.h>\n");
			printf("int main(void) {\n");
			PrintCode(t->first);
			printf("}\n");
			return;
		
/*STATEMENT*/		
		case(STATEMENT) :
			PrintCode(t->first);
			/*printf(";\n");*/
			PrintCode(t->second);
			return;

/*IF STATEMENT*/		
		case(IF_STATEMENT) :
			printf("if (");
			PrintCode(t->first);
			printf(") {\n");
			PrintCode(t->second);
			printf("}\n");
			
			if (t->third) {
				printf("else {\n");
				PrintCode(t->third);
				printf("}\n");
			}
			return;

/*WHILE_STATEMENT*/			
		case(WHILE_STATEMENT) :
			printf("while (");
			PrintCode(t->first);
			printf(")\n {\n");
			PrintCode(t->second);
			printf("}\n");
			return;

/*DO_STATEMENT*/			
		case(DO_STATEMENT) :
			printf("do {");
			PrintCode(t->first);
			printf("} while (\n");
			PrintCode(t->second);
			printf(");\n");
			return;

/*ASSIGNMENT_STATEMENT*/		
		case(ASSIGNMENT_STATEMENT) :
			if (t->item >= 0 && t->item < SYMTABSIZE)
				printf("%s",symTab[t->item]->identifier);
			else printf("UnknownIdentifier:%d",t->item);
			printf(" = ");
			PrintCode(t->first);
			printf(";\n");
			return;
		
/*FOR_STATEMENT*/					
		case(FOR_STATEMENT) :
		
		if (forLoops < 1)
		{
			printf("register int _by ;\n");
			printf("register int _to;\n");
		}	
			printf("_to = ");
			PrintCode(t->third->first);
			printf(";\n");			
			printf("for (%s =", symTab[t->item]->identifier);
			PrintCode(t->first);
			printf("; _by=");
			PrintCode(t->second);
			printf(",(%s - _to", symTab[t->item]->identifier);
			printf(") * ((_by > 0) - (_by < 0)) <=0 ; %s += _by)", symTab[t->item]->identifier);			
			printf("\n { \n");
			PrintCode(t->third->second);
			printf("}\n");				
			forLoops++;		
			return;

/*READ_STATEMENT*/			
		case(READ_STATEMENT) :
		
			if (symTab[t->item]->dataType == 'c')
			{ 						
				printf("scanf (\" %%c\", &%s);\n", symTab[t->item]->identifier); 
			}
			else if (symTab[t->item]->dataType == 'i')
			{
				printf("scanf (\"%%d\", &%s);\n", symTab[t->item]->identifier);
			}
			else if (symTab[t->item]->dataType == 'r')
			{
				printf("scanf (\"%%f\", &%s);\n", symTab[t->item]->identifier);
			}			
			return;	

/*WHILE_STATEMENT*/			
		case(WRITE_STATEMENT) :
		
			if(t->first->first->item != NOTHING)
			{				
				if(symTab[t->first->first->item]->dataType == 'c')
				{						
					printf("printf(\"%%c\",");
				}
				if (symTab[t->first->first->item]->dataType == 'i')
				{
					printf("printf(\"%%d\",");
				}
					
				if (symTab[t->first->first->item]->dataType == 'r')
				{
					printf("printf(\"%%.6g\",");
				}
				
				PrintCode(t->first);
				printf(");\n");						
			}	
			else
			{
				if (NodeName[t->first->first->first->nodeIdentifier] == "EXPRESSION") {
					printf("printf(\"%%d\",");
					PrintCode(t->first);
					printf(");\n");
				}
				else {
					printf("printf (\"");
					if (t->first) {
						PrintCode(t->first);
					} else {
						printf("\\n");
					}
					printf("\"); \n");
				}
			}
			return;

/*NEWLINE_STATEMENT*/			
		case(NEWLINE_STATEMENT):
			printf("printf(\"\\n\");\n");
			return;

/*OUTPUT_LIST*/			
		case(OUTPUT_LIST) :
			PrintCode(t->first);
			if (t->second)
			{
				PrintCode(t->second);
			}
			return;

/*DECLARATION_BLOCK*/			
		case(DECLARATION_BLOCK) :
			PrintCode(t->second);
			printf(" ");
			PrintCode(t->first);
			
			if(t->third)
			{
				PrintCode(t->third);
			}					
			return;		
		
		case(TYPE_C) :
			thisType = 'c';
			printf("char");	
			return;
			
		case(TYPE_I) :
			thisType = 'i';
			printf("int");
			return;
			
		case(TYPE_R) :
			thisType = 'r';
			printf("float");
			return;

/*CONDITIONAL*/			
		case(CONDITIONAL) :
			if(!t->second && !t->third)
			{
			printf("!(");
			PrintCode(t->first);
			printf(")");
			}
			else
			{
				PrintCode(t->first);
				PrintCode(t->second);
				PrintCode(t->third);
			}
			return;

/*AND_CONDITIONAL*/			
		case(AND_CONDITIONAL):
			PrintCode(t->first);
			PrintCode(t->second);
			PrintCode(t->third->first);
			printf("&&");
			PrintCode(t->third->second);	
			return;
			
/*OR_CONDITIONAL*/		
		case(OR_CONDITIONAL):
			PrintCode(t->first);
			PrintCode(t->second);
			PrintCode(t->third->first);			
			printf("||");			
			PrintCode(t->third->second);
			return;

/*VARIABLES*/		
		case(VARIABLES) :
			if(t->first)
			{
				symTab[t->item]->dataType = thisType;
				printf("%s, ", symTab[t->item]->identifier);
				PrintCode(t->first);
			}
			else
			{		
				symTab[t->item]->dataType = thisType;
				printf("%s;\n", symTab[t->item]->identifier);				
			}	
			return;

/*COMPARATOR*/					
		case(COMPARATOR) :
			switch(t->item) {
				case EQUALS:
					printf("==");
					break;
				case NOT_EQUAL:
					printf("!=");
					break;
				case LESS_THAN:
					printf("<");
					break;
				case GREATER_THAN:
					printf(">");
					break;
				case LESS_EQUALS:
					printf("<=");
					break;
				case GREATER_EQUALS:
					printf(">=");
					break;
			}
			return;

/*EXPRESSION*/			
		case(EXPRESSION) :
			switch(t->item){
				case PLUS:
					PrintCode(t->first);
					printf("+");
					PrintCode(t->second);
					break;
				case MINUS:
					PrintCode(t->first);
					printf("-");
					PrintCode(t->second);
					break;
				case TERM:
					PrintCode(t->first);
					break;
			}			
			return;

/*TERM*/			
		case(TERM) :
			switch(t->item){
				case TIMES:
					PrintCode(t->first);
					printf("*");
					PrintCode(t->second);
					break;
				case DIVIDE:
					PrintCode(t->first);
					printf("/");
					PrintCode(t->second);
					break;
				case VALUE:
					PrintCode(t->first);
					break;
			}				
			return;

/*VALUE*/			
		case(VALUE) :
		if (t->item != NOTHING)
		{
			printf("%s", symTab[t->item]->identifier);			
		}		
		PrintCode(t->first);	
			return;			
		
		case(CHARACTER_CONSTANT) :
			printf("%s", symTab[t->item]->identifier);
			return;				
				
		case(NUMBER_CONSTANT_MINUS) :
			printf("-");
			printf("%d", t->item);
			PrintCode(t->first);
			return;

		case(NUMBER_CONSTANT_NUMBER):
			printf("%d", t->item);
			PrintCode(t->first);
			return;
		
		case(NUMBER_CONSTANT_FULLSTOP) :			
			printf(".%d", t->item);
			return;									
		}
			
	PrintCode(t->first);
	PrintCode(t->second);
	PrintCode(t->third);
}

#include "lex.yy.c"