#ifndef __AST_NODES_HPP__
#define __AST_NODES_HPP__

#include <vector>
#include <string>

using namespace std;

// ///////////////////////////////////
// main implements for each node　will be written in Visitor::visit()
class Visitor;

// ///////////////////////////////////
//
class AST_node;
class AST_program;
class AST_statement;		// no implement
class AST_statement_list;
class AST_command;			// no implement
class AST_cmd_print;
class AST_cmd_ifelse;
class AST_expression;		// no implement
class AST_exp_variable;
class AST_exp_assignment;
class AST_exp_numeric_literal;
class AST_exp_binary_operator;

// ///////////////////////////////////
class AST_node
{
protected:
	void delete_all_vector_members(vector<AST_node*> &vec);
public:
	// all children has same function 'accept()' to dispatch to certain process for certain type of node
	virtual int accept(Visitor &v) = 0;
	virtual ~AST_node();
};
// ----
// ///////////////////////////////////
class AST_program : public AST_node
{
	friend class Visitor;
	AST_statement_list *statement_list;
public:
	virtual int accept(Visitor &v);
	AST_program(AST_statement_list *stmt_list);
	virtual ~AST_program();
};
// ///////////////////////////////////
class AST_statement : public AST_node
{
	// no implement
};
class AST_statement_list : public AST_node
{
	friend class Visitor;
	vector<AST_statement *> statement_list;
public:
	virtual int accept(Visitor &v);
	void push_back(AST_statement *stmt);
	virtual ~AST_statement_list();
};
// ///////////////////////////////////
class AST_command : public AST_statement
{
	// no implement
};
// ----
class AST_cmd_print : public AST_command
{
	friend class Visitor;
	AST_expression *expression;
public:
	virtual int accept(Visitor &v);
	AST_cmd_print(AST_expression *exp);
	virtual ~AST_cmd_print();
};
// ----
class AST_cmd_ifelse : public AST_command
{
	friend class Visitor;
	AST_expression *expression;
	AST_program *program_then;
	AST_program *program_else;
public:
	virtual int accept(Visitor &v);
	AST_cmd_ifelse(AST_expression *exp, AST_program *prog_then, AST_program *prog_else);
	virtual ~AST_cmd_ifelse();
};

// ///////////////////////////////////
class AST_expression : public AST_statement
{
	// no implement
};
// ----
class AST_exp_numeric_literal : public AST_expression
{
	friend class Visitor;
	int value;
public:
	virtual int accept(Visitor &v);
	AST_exp_numeric_literal(int i);
};
// ----
class AST_exp_variable : public AST_expression
{
	friend class Visitor;
	string variable_name;
public:
	virtual int accept(Visitor &v);
	AST_exp_variable(string *nm);
};
// ----
class AST_exp_assignment : public AST_expression
{
	friend class Visitor;
	AST_exp_variable *variable;
	AST_expression *expression;
public:
	virtual int accept(Visitor &v);
	AST_exp_assignment(AST_exp_variable *var, AST_expression *exp);
	~AST_exp_assignment();
};
// ----
class AST_exp_binary_operator : public AST_expression
{
	friend class Visitor;
	AST_expression *expression1;
	int operator_kind;
	AST_expression *expression2;
public:
	enum { none=0, add, subtract, equal, not_equal };
	virtual int accept(Visitor &v);
	AST_exp_binary_operator(AST_expression *exp1, int op, AST_expression *exp2);
	virtual ~AST_exp_binary_operator();
};

// ///////////////////////////////////
// ///////////////////////////////////
class Visitor
{
public:
	int visit(AST_program *program);
	int visit(AST_statement_list *statement_list);
	int visit(AST_cmd_print *cmd_print);
	int visit(AST_cmd_ifelse *cmd_ifelse);
	int visit(AST_exp_variable *exp_variable);
	int visit(AST_exp_assignment *exp_assignment);
	int visit(AST_exp_numeric_literal *exp_numeric_literal);
	int visit(AST_exp_binary_operator *exp_binary_operaotor);

};

#endif

