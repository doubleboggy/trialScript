%{
#include <cstdlib>
#include <errno.h>
#include <limits.h>
#include <string>
#include "Scanner.hpp"

// a patch for flex'bug (ver2.5.31-2.5.33)
#undef yywrap
#define yywrap() 1

// yyterminate() returns 0. compiler says NO because the 0 is not a value of yy::Parser::token_type. to avoid it, we can redefine yyterminate() to return token::END
#define yyterminate() return token::END

%}

%option c++
%option yyclass="Scanner"
%option noyywrap nounput batch debug

id		[a-zA-Z_][a-zA-Z_0-9]*
int		[0-9]+
blank	[ \t]

%{
#define YY_USER_ACTION yylloc->columns(yyleng);
%}

%%

%{
	yylloc->step();
	typedef yy::Parser::token token;
	typedef yy::Parser::token_type token_type;
%}

<INITIAL>{blank}+	{ yylloc->step(); }
<INITIAL>[\n]+		{ yylloc->lines(yyleng); yylloc->step(); }

<INITIAL>[-+*/(),]	{ return yy::Parser::token_type (yytext[0]); }
<INITIAL>{int}		{ yylval->ival = atoi(yytext); return token::NUMBER; }
<INITIAL>{id}		{ yylval->sval = new std::string(yytext); return token::IDENTIFIER;}
<INITIAL>.			{ driver.error(*yylloc, "invalid charactor"); }

%%
















