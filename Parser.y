%skeleton "lalr1.cc"
%require "2.1a"

%defines
%define parser_class_name { Parser }
%code requires {
	class ParseDriver;
}
%debug
%error-verbose

%parse-param { ParseDriver& driver }	// the 1st param of Parser's constructor
%lex-param	 { PaersDriver& driver }	// the 3rd param of yylex()

%locations
%initial-action
{
	// refer "location.hh", "position.hh"
	@$.begin.filename = @$.end.filename = &driver.file;
};

%{
	// do nothing
%}

%union {
	int			 ival;
	std::string *sval;
};

%token			END 0		"end of file"
%token <sval>	IDENTIFIER	"identifier"
%token <ival>	NUMBER		"number"

%printer	{ debug_stream() << *$$; } "identifier"
%destructor	{ delete $$; } "identifier"
%printer	{ debug_stream() << $$; } "number"

%{
#include "ParseDriver.hpp"			// not to forget to include it here
// new yylex() function for Parser
// confusing..., it's not same as '#define YY_DECL'
yy::Parser::token_type
yylex(yy::Parser::semantic_type* yylval,
	  yy::Parser::location_type* yylloc,
	  ParseDriver& driver) {
	return driver.scanner->scan(yylval, yylloc, driver);
}

// bison's spec: it's our duty to implement error routine
// it's confusing.., function below is not the same function ParseDriver::error() <- 's 1st param type is yy::location!
// however below calls the ParserDriver::error() at last internally.. will the yy::Parser::location_type be converted to yy:location ?
void
yy::Parser::error(const yy::Parser::location_type& l,
				  const std::string& m) {
	driver.error(l, m);
}

%}

%%

stmts	: stmt
		| stmts stmt
;

stmt	: IDENTIFIER
		| NUMBER
;

%%





















