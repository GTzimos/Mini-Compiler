%option noyywrap
%x error
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser2.tab.h"

extern FILE* yyout;
#define printf(...) fprintf(yyout, __VA_ARGS__)

int lex_warn=0;
int yylineno = 1;
char* strdup(const char*);

extern FILE *yyin;
extern FILE *yyout;

extern int valid_words;
extern int invalid_words;
%}

/* Regular expressions */
DELIMITER              [\t ]+
INTCONST_RE            (0)|([+-]?[1-9][0-9]*)
COMMENT_RE             ;[^\n]*
NEWLINE                (\r?\n)
IDENTIFIER_RE          [a-zA-Z][a-zA-Z0-9_-]*
STRING_RE              \"([^\"\\]|\\.)*\"
 
FLOAT_RE               ([+-]?([1-9][0-9]*|0)(\.[0-9]+)([eE][+-]?([1-9][0-9]*|0))?)
INT_EXP_RE             ([+-]?([1-9][0-9]*|0)[eE][+-]?([1-9][0-9]*|0))
VARIABLE_RE            \?[a-zA-Z0-9]+
BAD_IDENTIFIER_RE      [0-9]+[a-zA-Z0-9_-]+
BAD_IDENTIFIER_2_RE    [_-]+[a-zA-Z0-9_-]+

%%

{DELIMITER}             { /* Skip */ }
{NEWLINE}               { printf("LEXER: NEWLINE\n"); yylineno++;}

"deffacts"      { yylval.str = strdup(yytext); valid_words++; return DEFFACTS; }
"defrule" {
    printf("LEXER: DEFRULE = %s\n", yytext);
    yylval.str = strdup(yytext);
    valid_words++;
    return DEFRULE;
}
"test" {
    printf("LEXER: TEST = %s\n", yytext);
    yylval.str = strdup(yytext);
    valid_words++;
    return TEST;
}
"bind"          { yylval.str = strdup(yytext); valid_words++; return BIND; }
"read"          { yylval.str = strdup(yytext); valid_words++; return READ; }
"printout"      {printf("LEXER: PRINTOUT = %s\n", yytext); yylval.str = strdup(yytext); valid_words++; return PRINTOUT; }
"="             { valid_words++; return EQUAL; }
"+"             { valid_words++; return PLUS; }
"-"             { valid_words++; return MINUS; }
"*"             { valid_words++; return MUL; }
"/"             { valid_words++; return DIV; }

{INTCONST_RE} {
    printf("LEXER: INT = %s\n",yytext);
    yylval.str = strdup(yytext);
    valid_words++;
    return INTCONST;
}

{FLOAT_RE} {
    printf("LEXER: FLOAT = %s\n", yytext);
    yylval.str = strdup(yytext);
    valid_words++;
    return FLOAT;
}

{INT_EXP_RE} {
    printf("LEXER: INT_EXP = %s\n",yytext);
    yylval.str = strdup(yytext);
    valid_words++;
    return INT_EXP;
}

{BAD_IDENTIFIER_RE} {
    printf("LEXER: BAD_IDENTIFIER = %s\n", yytext);
    yylval.str = strdup(yytext);
    invalid_words++;
    return BAD_IDENTIFIER;
}

{BAD_IDENTIFIER_2_RE} {
    yylval.str = strdup(yytext);
    invalid_words++;
    return BAD_IDENTIFIER_2;
}

{STRING_RE} {
    printf("LEXER: STRING = %s\n", yytext);
    yylval.str = strdup(yytext);
    valid_words++;
    return STRING;
}

{IDENTIFIER_RE} {
    printf("LEXER: IDENTIFIER = %s\n", yytext);
    yylval.str = strdup(yytext);
    valid_words++;
    return IDENTIFIER;
}

{COMMENT_RE} {
    printf("Σχόλιο: %s\n", yytext); 
    valid_words++;
   
}

{VARIABLE_RE} {
    printf("LEXER: VARIABLE = %s\n", yytext);
    yylval.str = strdup(yytext);
    valid_words++;
    return VARIABLE;
}

"->" {
    valid_words++;
    return ARROW;
}
"(" {
    printf("LEXER: LEFT PARETNHESIS = %s\n", yytext);
    valid_words++;
    return LPAREN;
}
")" {
    printf("LEXER: RIGHT PARETNHESIS = %s\n", yytext);
    valid_words++;
    return RPAREN;
}

"=>" {
    lex_warn++;
    printf("LEXER: ARROW correction = %s   arrow is supposed to be '->'\n", yytext);
    return ARROW;
}

. {
    printf("LEXER: UNKNOWN = %s\n", yytext);
    yylval.str = strdup(yytext);
    invalid_words++;
    BEGIN(error);
    return UNKNOWN;
}



<error>[ \t]+        { /* Αγνόησε και βγες από error */ BEGIN(0); }
<error>[(]        { BEGIN(0); unput('('); }
<error>[)]        { BEGIN(0); unput(')'); }
<error>\n            { BEGIN(0); yylineno++; }
%%
