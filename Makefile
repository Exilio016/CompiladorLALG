all: clean compile clean

lex:
	flex analisador.l

yacc:
	bison -v -d sintatico.y -o y.tab.c

compile: yacc lex
	g++ y.tab.c lex.yy.c -o comp -std=c++11

clean:
	find *.h *.c *.o | xargs rm -f
