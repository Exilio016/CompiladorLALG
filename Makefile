all: compile

lex:
	flex analisador.l

compile: lex
	g++ -g lex.yy.c -o comp -lfl
