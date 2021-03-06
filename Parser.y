%skeleton "lalr1.cc"
%require "2.1a"
%defines
%define parser_class_name { Parser }
%code requires {
	#include "ASTnodes.hpp"
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

%union {
	int			 ival;
	std::string *sval;
	AST_program *program;
	AST_statement *statement;
//	AST_command *command;
	AST_cmd_print  *cmd_print;
	AST_cmd_ifelse *cmd_ifelse;
//	AST_expression *expression;
	AST_exp_variable *variable;
	AST_exp_assignment *assignment;
	AST_exp_numeric_literal *numeric_literal;
	AST_exp_binary_operator *binary_operator;
};

%{

#include "ParseDriver.hpp"			// not to forget to include it here
// new yylex() function for Parser
yy::Parser::token_type
yylex(yy::Parser::semantic_type* yylval,
yy::Parser::location_type* yylloc,
ParseDriver& driver) {
	return driver.scanner->scan(yylval, yylloc, driver);
}

// bison's spec: it's our duty to implement error routine
void yy::Parser::error(const yy::Parser::location_type& l, const std::string& m) {
	driver.error(l, m);
}

%}

%token			END 0			"end of file"
%token <sval>	VARIABLE_NAME	"variable name"
%token <ival>	NUMBER			"number"
%token IF ELSE PRINT '{' '}'
%right '='
%left  EQUAL NEQUAL
%left  '+'
%left  '-'

%printer	{ debug_stream() << *$$; } "variable name"
%destructor	{ delete $$; } "variable name"
%printer	{ debug_stream() << $$; } "number"

%%

program		:
			| program statement
;
statement	: command
			| expression
;
command		: IF expression '{' program '}' ELSE '{' program '}'
			| PRINT expression
;
expression	: NUMBER
			| VARIABLE_NAME
			| VARIABLE_NAME '=' expression
			| expression '+' expression
			| expression '-' expression
			| expression EQUAL  expression
			| expression NEQUAL expression
;
%%





















