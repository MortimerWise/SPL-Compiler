%{

/* Program Summary: 
This is the Lexical Analyser. 
History: 01/12/2017 
 Version 1.0 */

#ifdef PRINT
#define TOKEN(t) printf("Token: " #t "\n");
#define NUMBER_TOKEN(t) printf("Number %d Token: " #t "\n",atoi(yytext));
#define ID_TOKEN(t) printf("ID %s TOKEN: " #t "\n", yytext);
#else
#define TOKEN(t) return(t);
#define NUMBER_TOKEN(t) yylval.iVal = atoi(yytext); return(t);
#define ID_TOKEN(t) yylval.iVal = installId(yytext); return(t);
#include <string.h>

/* Declare Symbol Table Type and Array as imported types */

extern SYMTABNODEPTR symTab[SYMTABSIZE];
extern int currentSymTabSize;
int installId(char *);
#endif
%}

delim       		[ \r\t\n]
ws          		{delim}+
digit      			[0-9]	
character   		[A-Za-z]        
number			    {digit}+
identifier			{character}({character}|{digit})*
number_constant		{number}+
character_constant	{character}+	
		
constant			{(number_constant)|(character_constant)}
	
%%
						int k;						
						
{number}    			NUMBER_TOKEN(NUMBER);
						
{ws}        			; /* Do nothing when white space is seen */
	
NEWLINE					TOKEN(NEWLINE);  
CODE					TOKEN(CODE);
DECLARATIONS			TOKEN(DECLARATIONS);

IS						TOKEN(IS);	
IF   		    		TOKEN(IF);
DO			          	TOKEN(DO);
BY						TOKEN(BY);
TO						TOKEN(TO);
WRITE					TOKEN(WRITE);
WHILE					TOKEN(WHILE);
FOR						TOKEN(FOR);
ENDDO					TOKEN(ENDDO);
ENDP					TOKEN(ENDP);
NOT						TOKEN(NOT);
AND						TOKEN(AND);
OR						TOKEN(OR);
OF						TOKEN(OF);

READ					TOKEN(READ);

THEN        			TOKEN(THEN);
ELSE        			TOKEN(ELSE);
ENDIF					TOKEN(ENDIF);
ENDFOR					TOKEN(ENDFOR);
ENDWHILE				TOKEN(ENDWHILE);

REAL					TOKEN(REAL);
TYPE					TOKEN(TYPE);
INTEGER					TOKEN(INTEGER);
CHARACTER				TOKEN(CHARACTER);	

"->"					TOKEN(RIGHT_ARROW);		
":="					TOKEN(ASSIGNS);
";"         			TOKEN(SEMICOLON);
"+"         			TOKEN(PLUS);
"-"         			TOKEN(MINUS);
"*"         			TOKEN(TIMES);
"/"        				TOKEN(DIVIDE);	
"<" 					TOKEN(LESS_THAN);
">" 					TOKEN(GREATER_THAN);
"<>"					TOKEN(NOT_EQUAL);
"="						TOKEN(EQUALS);
"("						TOKEN(LEFT_BRACKET);
")"						TOKEN(RIGHT_BRACKET);
","						TOKEN(COMMA);
">="					TOKEN(GREATER_EQUALS);
"<="					TOKEN(LESS_EQUALS);
":"						TOKEN(COLON);
"'"						TOKEN(APOSTROPHE);
"."						TOKEN(FULLSTOP);

{identifier}   			ID_TOKEN(IDENTIFIER);
.						printf("Error: Unexpected symbol in lexical analyser: %s (%d)\n", yytext,yytext[0]); /*prints out anything not known*/

%%

#ifndef PRINT
/* Here is the code for the library of symbol table routines */

/* code for a simple symbol table, which is an array of pointers to
   structs, each of which contains an identifier.
*/


SYMTABNODEPTR newSymTabNode()
{
    return ((SYMTABNODEPTR)malloc(sizeof(SYMTABNODE)));
}

int lookup(char *s)
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE];
    extern int currentSymTabSize;
    int i;

    for(i=0; i<currentSymTabSize; i++)
    {
        if(strncmp(s,symTab[i]->identifier,IDLENGTH) == 0)
        {
            return (i);
        }
    }
    return (-1);    
}


/* Look up an identifier in the symbol table, if its there return
   its index.  If its not there, put it in the end position,
   as long as the table isn't full, and return its index.
*/

int installId(char *id) 
{
    extern SYMTABNODEPTR symTab[SYMTABSIZE]; 
    extern int currentSymTabSize;
    int index;

    index = lookup(id);
    if (index >= 0)
    {
        return (index);
    }
    else 
       if (currentSymTabSize >= SYMTABSIZE) 
          /* SYMTAB is full */
          return (NOTHING) ;
    else
    {
       symTab[currentSymTabSize] = newSymTabNode();
       /* Recommended code for preventing buffer overrun on bounded strings */
       strncpy(symTab[currentSymTabSize]->identifier,id,IDLENGTH);
       symTab[currentSymTabSize]->identifier[IDLENGTH-1] = '\0';
       return(currentSymTabSize++);
    }
}
#endif