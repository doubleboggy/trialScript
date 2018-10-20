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
	AST_statement_list *statement_list;
	AST_command *command;
//	AST_cmd_print  *cmd_print;
//	AST_cmd_ifelse *cmd_ifelse;
	AST_expression *expression;
//	AST_exp_variable *variable;
//	AST_exp_assignment *assignment;
//	AST_exp_numeric_literal *numeric_literal;
//	AST_exp_binary_operator *binary_operator;
};

// -- move to later part
%type <program> program "program"
%type <statement_list> statement_list "statement_list"
%type <statement> statement "statement"
%type <command> command "command"
%type <expression> expression "expression"
// --

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

program : statement_list { $$ = new AST_program($1); driver.program = $$; }
;
statement_list		: statement_list statement {
								  $$->push_back($2);
					}
					| statement { $$ = new AST_statement_list();
								  $$->push_back($1); }
;
statement	: command { $$ = $1; }
			| expression { $$ = $1; }
;
command		: IF expression '{' program '}' ELSE '{' program '}' { $$ = new AST_cmd_ifelse($2, $4, $8); }
			| PRINT expression { $$ = new AST_cmd_print($2); }
;
expression	: NUMBER { $$ = new AST_exp_numeric_literal($1); }
			| VARIABLE_NAME { $$ = new AST_exp_variable($1); }
			| VARIABLE_NAME '=' expression { AST_exp_variable *var = new AST_exp_variable($1);$$ = new AST_exp_assignment(var, $3); }
			| expression '+' expression { $$ = new AST_exp_binary_operator($1, AST_exp_binary_operator::add, $3); }
			| expression '-' expression { $$ = new AST_exp_binary_operator($1, AST_exp_binary_operator::subtract, $3); }
			| expression EQUAL  expression  { $$ = new AST_exp_binary_operator($1, AST_exp_binary_operator::equal, $3); }
			| expression NEQUAL expression  { $$ = new AST_exp_binary_operator($1, AST_exp_binary_operator::not_equal, $3); }
;
%%





















