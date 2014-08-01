/*
 * sqlb - quick and dirty SQL beautifier
 * comments and strings are untouched
 * understands only lowercase keywords
 * compile as - "lex sqlb.l, cc -o sqlb lex.yy.c -lfl, rm lex.yy.c"
 * Use as - cat sqlfile|sqlb|awk NF
 *          awk NF will remove blank lines
 */
DIGIT    [0-9]
ID       [:A-Za-z]+[A-Za-z0-9_]*
SPACE    [ \t\n]
CONSTSTRING  "'"[^']*"'" 
%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#define TOKIDUS          1
#define TOKFROM          2
#define TOKWHERE         3
#define TOKJOIN          4
#define TOKANDOR         5 
#define TOKBRACKET       6 
#define TOKFROMBRACKET   7 
#define TOKTABLEBRACKET  8
#define TOKTABLE         9
#define TOKFIELD         10
#define TOKTABLEBRACKETIN 11 
#define TOKUDF            12 
#define TOKINSERT         12 
#define TOKINSERTTABLE    13 
#define TOKINSERTBRACKET  14 
#define TOKEXISTS         15 
#define TOKCOMMA          16 
#define TOKRESERVED       17 
#define TOKNULL          0 

#define DEFIND          4 
int currindent=0;
int currlen=0;
int si=0;
int state[100]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int idtsp[100]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
%}
%%
"/*".*\n.*"*/" { ECHO; } /* multi line comments */

"/*".*"*/" { ECHO; } /* one line comments */

"--".*"\n"|"rem"{SPACE}+.*"\n" { ECHO;} /* one line comments */

{CONSTSTRING} { printfield(); }


","     { printcomma();  }
"lock"{SPACE}+"table"   { printf( "\n%s ", "LOCK TABLE "); state[si]=TOKIDUS; }
"locking"{SPACE}+"rows"   { printf( "\n%s ", "LOCKING ROWS "); state[si]=TOKIDUS; }
"insert"{SPACE}+"into"|"ins"{SPACE}+"into"   { printf( "\n%s ", "INSERT INTO"); currindent=0;state[si]=TOKINSERT; }
"delete"{SPACE}+"from"|"del"{SPACE}+"from"   { printf( "\n%s ", "DELETE FROM"); state[si]=TOKIDUS; }
"hash"{SPACE}+"by"   { printf( "\n"); currindent--; printm(); currindent++; printf("%s ", "HASH BY"); }
"local"{SPACE}+"order"{SPACE}+"by"  { printf( "\n");currindent--;  printm();currindent++;  printf("%s ", "LOCAL ORDER BY"); }
sel|del|upd|select|delete|update   { printtokenincindent(); state[si]=TOKIDUS; }
exists|declare|begin  { printtokenincindent(); state[si]=TOKEXISTS; }

elsif { printtokendecindent(); }

from { printfrom(); }
table { printtable();  }
where { printuppertextspacedecind(); state[si]=TOKWHERE;}
and|or { currindent++;printuppertextspacesameind(); currindent--;state[si]=TOKANDOR; }
"case"{SPACE}+"when" { printtokenincindent();  }
"case" { printtokenincindent();  }
end { currindent--;printf("\n");printm(); printuppertextspace();  }
when|exception|else|set|end|end{SPACE}+if { printtokensameindent(); }
left|right|inner {printf( "\n");  printm();  printf("%s ", yytext); }
on {printf( "\n");  printm();  printf("%s ", yytext); }

absolute|action|add|all|allocate|alter                      { printuppertextspace(); }
and|any|are|as|asc|assertion|at|authorization               { printuppertextspace(); }
avg|begin|between|bit|bit_length|both|by|byte|byteint|call  { printuppertextspace(); }
cascade|cascaded|rase|cast|catalog|char|char_length         { printuppertextspace(); }
character|character_length|check|close|coalesce|collate     { printuppertextspace(); }
collation|column|commit|condition|connect|connection        { printuppertextspace(); }
constraint|constraints|contains|continue|convert            { printuppertextspace(); }
corresponding|count|create|cross|current|current_date       { printuppertextspace(); }
current_path|current_time|current_timestamp|current_user    { printuppertextspace(); }
cursor|date|day|deallocate|dec|decimal|declare              { printuppertextspace(); }
default|deferrable|deferred|desc|describe|descriptor        { printuppertextspace(); }
deterministic|diagnostics|disconnect|distinct|do            { printuppertextspace(); }
domain|double|drop|else|elseif|end|escape|except            { printuppertextspace(); }
exception|exec|execute|exists|exit|external|extract         { printuppertextspace(); }
false|fetch|first|float|for|foreign|format|found|from       { printuppertextspace(); }
full|function|get|global|go|goto|grant|group                { printuppertextspace(); }
handler|having|hour|identity|if|immediate|in                { printuppertextspace(); }
indicator|initially|inner|inout|input|insensitive           { printuppertextspace(); }
int|integer|intersect|interval|into|is|isolation            { printuppertextspace(); }
join|key|language|last|leading|leave|left|level             { printuppertextspace(); }
like|local|loop|lower|match|max|min|minute|module           { printuppertextspace(); }
month|names|national|natural|nchar|next|no|not|null         { printuppertextspace(); }
nullif|numeric|octet_length|of|on|only|open|option          { printuppertextspace(); }
or|order|out|outer|output|overlaps|pad|parameter            { printuppertextspace(); }
partial|path|position|precision|prepare|preserve            { printuppertextspace(); }
primary|prior|privileges|procedure|public|read              { printuppertextspace(); }
real|references|relative|repeat|resignal|restrict           { printuppertextspace(); }
return|returns|revoke|right|rollback|routine|rows           { printuppertextspace(); }
schema|scroll|second|section|set|signal|size|smallint       { printuppertextspace(); }
some|space|specific|sql|sqlcode|sqlerror|sqlexception       { printuppertextspace(); }
substring|substr|sum|system_user|temporary|then             { printuppertextspace(); }
time|timestamp|timezone_hour|timezone_minute|to|trailing    { printuppertextspace(); }
transaction|translate|translation|trim|true|undo            { printuppertextspace(); }
union|unique|unknown|until|upper|usage|user                 { printuppertextspace(); }
using|value|values|varchar|varying|view|when|whenever       { printuppertextspace(); }
while|with|work|write|year|zone                             { printuppertextspace(); }

";"     { printf("\n;\n\n");printm(); }
"("   { printleftbracket(); }
")"   { printrightbracket(); }

"<"|">"|"="|"+"|"-"|"*"|"/"  { printuppertextspace(); }
":="|">="|"<="|"!="|"<>"  { printuppertextspace(); }
"||"  { printnewline(); printuppertextspace(); }

"%"|"."|"_" { printtext();}

{ID}|{ID}[%@.]{ID}|{DIGIT}+|{DIGIT}+"."{DIGIT}+ { printfield(); }

{SPACE}+          {;}/* eat up whitespace */

.           printf( "Unrecognized character: %s\n", yytext );
%%

char * upper(char *str) {
    int i=0;
    for( i = 0; str[ i ]; i++)
        str[ i ] = toupper( str[ i ] );
    return str;
}

  
int
printm()
{
    int i=0;
    while(i<currindent*DEFIND)

    {
        printf(" ");
        i++;
    }
}

printtokensameindent()
{
    printf( "\n");
    printm();
    printf( "%s\n", upper(yytext));
    printm();
    currlen = 0;
}

printtokenincindent()
{
    printf( "\n");
    printm();
    printf( "%s\n", upper(yytext));
    currindent++;
    printm();
    currlen = 0;
}

printtokendecindent()
{
    currindent--;
    printf("\n");
    currlen = 0;
    printm();
    printf( "%s ", upper(yytext) );
}

printtokentmpindent()
{
    currindent--;
    printf("\n");
    currlen = 0;
    printm();
    printf( "%s\n", upper(yytext) );
    currlen = 0;
    currindent++;
    printm();
}

printnewline()
{ 
    if ( currlen + currindent*DEFIND > 50 ) {
         printf( "\n");
         printm();
         currlen = 0;
    }
}

printtextspace()
{ 
    //printf( "[ %d-%d ] %s", si,state[si], yytext ); 
    printf( "%s ",  yytext ); 
    currlen += strlen(yytext) ;
}

printuppertextspace()
{ 
    printf( "%s ", upper(yytext) ); 
    currlen += strlen(yytext) ;
    if ( state[si]!=TOKBRACKET ) 
        state[si] = TOKRESERVED;
}

printuppertextspacesameind()
{ 
    printf( "\n");
    printm();
    printf( "%s ", upper(yytext) ); 
    currlen += strlen(yytext) ;
}

printuppertextspacedecind()
{ 
    currindent--;
    printf( "\n");
    printm();
    printf( "%s ", upper(yytext) ); 
    currlen += strlen(yytext) ;
}

printuppertextspaceincind()
{ 
    currindent++;
    printf( "\n");
    printm();
    printf( "%s ", upper(yytext) ); 
    currlen += strlen(yytext) ;
}

printtext()
{ 
    printf( "%s", yytext ); 
    currlen += strlen(yytext) ;
}

printleftbracket()
{
    idtsp[si]=currindent; 
    if ( state[si]==TOKFROM  ) {
        printtokensameindent();
    } else if ( state[si]==TOKINSERTTABLE  ) {
        printtokenincindent();
    } else { 
        printtextspace(); 
    } 
    si++; 
    if ( state[si-1]==TOKINSERTTABLE ) {
        state[si]=TOKFIELD; 
    } else if ( state[si-1]==TOKTABLE ) {
        state[si]=TOKTABLEBRACKET; 
    } else if ( state[si-1]==TOKTABLEBRACKET ) {
        state[si]=TOKFIELD; 
    } else if ( state[si-1]==TOKTABLEBRACKETIN ) {
        state[si]=TOKFIELD; 
    } else { 
        state[si]=TOKBRACKET; 
    } 
}

printrightbracket()
{
    si--;
    if ( state[si]==TOKFROM  ) {
        printtokensameindent();
    } else if ( state[si]==TOKTABLE ) {
        printtokendecindent();
    } else if ( state[si]==TOKINSERTTABLE ) {
        printtokendecindent();
    } else if ( state[si]==TOKEXISTS ) {
        printtokensameindent();
    } else if ( state[si]==TOKUDF ) {
        currindent++;
        printtokendecindent();
        currindent--;
    } else {
        printtextspace(); 
    }
    currindent=idtsp[si];
}

printfield()
{
    if (state[si]!=TOKFIELD && state[si]!=TOKBRACKET && state[si]!=TOKTABLEBRACKET 
        && state[si]!=TOKTABLEBRACKETIN && state[si]!=TOKINSERT ) {
        state[si]=TOKFIELD; 
    }
    if (state[si]==TOKINSERT) {
        state[si]=TOKINSERTTABLE;
    }
    if (state[si]==TOKTABLEBRACKET) {
        printf( "\n");
        printm();
        currindent++;
        state[si]=TOKTABLEBRACKETIN;
    }
    printtextspace(); 
}

printfrom()
{
    printtokendecindent(); 
    state[si]=TOKFROM;
    currindent++;
}

printcomma()
{
    if ( state[si] != TOKBRACKET ) {
        printnewline(); 
        state[si] = TOKCOMMA;
    }
    else if ( si > 0 ) {
        if ( state[si-1]==TOKFIELD ) {
            state[si-1]=TOKUDF; 
            state[si]=TOKFIELD; 
            currindent++;
        }
    }
    printtextspace();
}

printtable()
{ 
    printm();
    printtokenincindent();  
    idtsp[si]=currindent; 
    state[si]=TOKTABLE; 
}
