all: compile

lex:
	flex analisador.l

compile: lex
	gcc -g lex.yy.c -o comp -lfl
