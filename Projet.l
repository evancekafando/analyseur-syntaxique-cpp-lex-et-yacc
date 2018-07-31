%{
  #include <iostream>
  #include "y.tab.h"
  extern "C" int yylex();
  using namespace std;
%}

CHIFFRE	[0-9]
LETTRE	[a-zA-Z]
ENTIER	{CHIFFRE}+
REEL	({CHIFFRE}+"."{CHIFFRE}*)|({CHIFFRE}*"."{CHIFFRE}+)
IDENT	{LETTRE}({LETTRE}|{CHIFFRE})*

%% 

{ENTIER}		{ return NOMBRE; }
{REEL}			{ return NOMBRE; }
{IDENT}			{ return IDENT; }
"("                     { return '('; }
")"                     { return ')'; }
"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
\n                      { return '\n'; }
[\t ]+                  { ; /* On ignore */ } 
.                       { cout<<" Autre ?\n"; }

%%
