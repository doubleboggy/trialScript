%{
#include <cstdlib>
#include <errno.h>
#include <limits.h>
#include <string>
#include "Scanner.hpp"

// a patch for flex'bug (ver2.5.31-2.5.33)
#undef yywrap
#define yywrap() 1

// yyterminate() returns 0 originally.
#define yyterminate() return token::END
#define YY_USER_ACTION yylloc->columns(yyleng);
%}

%option c++
%option yyclass="Scanner"
%option noyywrap nounput batch debug

%%
%{
	yylloc->step();
	typedef yy::Parser::token token;
	typedef yy::Parser::token_type token_type;
%}
[ \t]+		{ yylloc->step(); }
[\n]		{ yylloc->lines(yyleng); yylloc->step(); }
[-+={}]		{ return yy::Parser::token_type (yytext[0]); }
[0-9]+		{ yylval->ival = atoi(yytext); return token::NUMBER; }
$[a-zA-Z]+[a-zA-Z0-9]*		{ yylval->sval = new std::string(yytext); return token::VARIABLE_NAME; }
.			{ driver.error(*yylloc, "invalid charactor"); }
%%
