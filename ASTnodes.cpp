#include "ASTnodes.hpp"
#include <string>
#include <vector>
#include <map>

using namespace std;

map<string, int> variable_table;

// ///////////////////////////////////
AST_node::~AST_node() {
	// do nothing, I don't care what destructors drived are going to do
}
// ----
int AST_program::accept(Visitor &v)
{
	return v.visit(this);
}
void AST_program::push_back(AST_statement *stmt)
{
	statement_list.push_back(stmt);
}
AST_program::~AST_program()
{
	for (auto it = statement_list.begin(); it != statement_list.end(); it++) {
		delete *it;
	}
	statement_list.clear();
}
// ----
int AST_cmd_print::accept(Visitor &v)
{
	return v.visit(this);
}
AST_cmd_print::AST_cmd_print(AST_expression *exp)
{
	expression = exp;
}
AST_cmd_print::~AST_cmd_print()
{
	delete expression;
}
// ----
int AST_cmd_ifelse::accept(Visitor &v)
{
	return v.visit(this);
}
AST_cmd_ifelse::AST_cmd_ifelse(AST_expression *exp, AST_program *prog_then, AST_program *prog_else)
{
	expression = exp;
	program_then = prog_then;
	program_else = prog_else;
}
AST_cmd_ifelse::~AST_cmd_ifelse()
{
	delete expression;
	delete program_then;
	delete program_else;
}
// ///////////////////////////////////
int AST_exp_numeric_literal::accept(Visitor &v)
{
	return v.visit(this);
}
AST_exp_numeric_literal::AST_exp_numeric_literal(int i)
{
	value = i;
}
// ----
int AST_exp_variable::accept(Visitor &v)
{
	return v.visit(this);
}
AST_exp_variable::AST_exp_variable(string nm)
{
	variable_name = nm;
}
// ----
int AST_exp_assignment::accept(Visitor &v)
{
	return v.visit(this);
}
AST_exp_assignment::AST_exp_assignment(AST_exp_variable *var, AST_expression *exp)
{
	variable = var;
	expression = exp;
}
AST_exp_assignment::~AST_exp_assignment()
{
	delete variable;
	delete expression;
}
// ----
int AST_exp_binary_operator::accept(Visitor &v)
{
	return v.visit(this);
}
AST_exp_binary_operator::AST_exp_binary_operator(AST_expression *exp1, int op, AST_expression *exp2)
{
	expression1 = exp1;
	operator_kind = op;
	expression2 = exp2;
}
AST_exp_binary_operator::~AST_exp_binary_operator()
{
	delete expression1;
	delete expression2;
}

// ///////////////////////////////////
// visitor implemetation
// ----
int Visitor::visit(AST_program *program)
{
	for (auto it = program->statement_list.begin(); it != program->statement_list.end(); it++) {
		(*it)->accept(*this);
	}
	return 0;
}
// ----
int Visitor::visit(AST_cmd_print *cmd_print)
{
	int value = cmd_print->expression->accept(*this);
	printf("%d\n", value);
	return 0;
}
// ----
int Visitor::visit(AST_cmd_ifelse *cmd_ifelse)
{
	int value = cmd_ifelse->expression->accept(*this);
	if (value != 0) {
		cmd_ifelse->program_then->accept(*this);
	} else {
		cmd_ifelse->program_else->accept(*this);
	}
	return 0;
}
// ----
int Visitor::visit(AST_exp_variable *exp_variable)
{
	string name = exp_variable->variable_name;

	// search the name designated by exp_variable
	auto it = variable_table.find(name);
	if (it != variable_table.end()) {
		// returns the value of variable when found
		return it->second;
	}
	// returns 0 when the variable was not defined
	return 0;
}
// ----
int Visitor::visit(AST_exp_assignment *exp_assignment)
{
	string name = exp_assignment->variable->variable_name;
	int value = exp_assignment->expression->accept(*this);

	// save the value into variable_table
	variable_table.insert(make_pair(name, value));
	// then returns the same value as a result of this *expression* 'assignment'
	return value;
}
// ----
int Visitor::visit(AST_exp_numeric_literal *exp_numeric_literal)
{
	// simply returns an integer value that stored in the numeric_literal instance
	return exp_numeric_literal->value;
}
// ----
int Visitor::visit(AST_exp_binary_operator *exp_binary_operaotor)
{
	// this function covers following all binary operators
	//  +, -, ==, !=
	int ans = 0;
	int op_kind = AST_exp_binary_operator::none;
	int value1=0, value2=0;
	
	value1 = exp_binary_operaotor->expression1->accept(*this);
	value2 = exp_binary_operaotor->expression2->accept(*this);
	if (op_kind == AST_exp_binary_operator::add) {
		ans = value1 + value2;
	} else if (op_kind == AST_exp_binary_operator::subtract) {
		ans = value1 - value2;
	} else if (op_kind == AST_exp_binary_operator::equal) {
		ans = (value1 == value2) ? 1 : 0;
	} else if (op_kind == AST_exp_binary_operator::not_equal) {
		ans = (value1 != value2) ? 1 : 0;
	}
	
	return ans;
}


















