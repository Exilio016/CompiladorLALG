%option noyywrap

%{

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <iostream>
#include <string>
#include <math.h>

#include "y.tab.h"

using namespace std;

int MAX_IDENT = 50; //tamanho maximo de um identificador
int MAX_INT = to_string(INT_MAX).length(); //tamanho maximo de um numero inteiro

int nLines = 1; //(comecar na linha 1) -> para mostrar o numero de linhas correto ao usuario
int nErrors = 0;
int token;

typedef struct {
	string word;
	int token;
} hash_t;

hash_t reservedWords[128];

void initReservedWords();

void errorFunc(string errorString, string errorVar); //exibir erro

bool checkReservedWord(string s, int *token); //checar se eh uma palavra reservada

void checkCommentaryLines(string commentaryString); //checa a quantidade de "\n"s no comentario com erro (para nao perder a contagem de linhas)

bool checkIdentSize(string s, int identSize); //checar os tamanhos dos identificadores
bool checkNumberSize(string numberString, string numberType, int numberSize); //c'hecar os tamanhos dos numeros

int toToken(string token);

%}

NUMERO [0-9]
LETRA [a-zA-Z]

NUMERO_INTEIRO {NUMERO}+
NUMERO_REAL {NUMERO}+"."{NUMERO}+
IDENT {LETRA}({LETRA}|{NUMERO}|_)*

NOVA_LINHA "\n"|"\r\n"
CARACTERES_ESPECIAIS {NOVA_LINHA}|" "|"\r"|"\t"|"\s"

COMENTARIO_LINHA "{"[^}\n]*"}"

SIMBOLO_RESERVADO "<>"|">="|"<="|">"|"<"|":="|"="|"+"|"\-"|"*"|"/"|";"|"."|":"|","|"("|")"

IDENT_CARACTERES_NAO_PERMITIDOS [^0-9a-zA-Z"<>"">=""<="">""<"":=""=""+""\-""*""/"";""."":"",""("")"" ""\r""\t""\s""\n"|"\r\n"]
ERRO_IDENTIFICADOR_MAL_FORMADO ({IDENT}{IDENT_CARACTERES_NAO_PERMITIDOS}+({LETRA}|{NUMERO}|_)+)|({NUMERO}+({LETRA}|_)+)

ERRO_COMENTARIO_LINHA_MAL_FORMADO  ("{"[^}\n]*"\n"[^}]*"}")|"{"[^}\n]*

NUMERO_CARACTERES_NAO_PERMITIDOS [^0-9"<>"">=""<="">""<""=""+""\-""*""/""."",""("")"" ""\r""\t""\s""\n"|"\r\n"]
ERRO_NUMERO_INTEIRO_MAL_FORMADO {NUMERO}+{NUMERO_CARACTERES_NAO_PERMITIDOS}+{NUMERO}+
ERRO_NUMERO_REAL_MAL_FORMADO ({NUMERO}+{NUMERO_CARACTERES_NAO_PERMITIDOS}+"."{NUMERO}+)|({NUMERO}+"."{NUMERO_CARACTERES_NAO_PERMITIDOS}+{NUMERO}+)|({ERRO_NUMERO_INTEIRO_MAL_FORMADO}"."({NUMERO}+|{ERRO_NUMERO_INTEIRO_MAL_FORMADO}))|(({NUMERO}+|{ERRO_NUMERO_INTEIRO_MAL_FORMADO})"."{ERRO_NUMERO_INTEIRO_MAL_FORMADO})

%%

{COMENTARIO_LINHA} {}

{ERRO_COMENTARIO_LINHA_MAL_FORMADO} {errorFunc("Comentario mal formado.", yytext); checkCommentaryLines(yytext);}

{NOVA_LINHA} {nLines++;}

{CARACTERES_ESPECIAIS} {} 

{ERRO_NUMERO_REAL_MAL_FORMADO} {errorFunc("Numero real mal formado.", yytext);}
{ERRO_NUMERO_INTEIRO_MAL_FORMADO} {errorFunc("Numero inteiro mal formado.", yytext);}

{NUMERO_INTEIRO} { 	if(checkNumberSize(yytext, "integer", yyleng)){
						return NUMERO_INT;
					}
				 } 
{NUMERO_REAL} { if(checkNumberSize(yytext, "real", yyleng)){
					return NUMERO_REAL;
				}
			  }

{SIMBOLO_RESERVADO} { return toToken(yytext);}

{ERRO_IDENTIFICADOR_MAL_FORMADO} {errorFunc("Identificador mal formado.", yytext);}

{IDENT} {	if(checkIdentSize(yytext, yyleng)){
				if(checkReservedWord(yytext, &token)){
					return token;
				}else{
					return IDENT;
				}
			}
		}

. {errorFunc("Caractere invalido.", yytext);} 

%%

int toToken(string token){
	if(token.length() == 1)
		return token.c_str()[0];

		if (token.compare("<>") == 0) 
			return DIF;
		if (token.compare("<=") == 0)
			return MENOR_IGUAL;
		if (token.compare("<=") == 0)
			return MAIOR_IGUAL;
		if (token.compare(":=") == 0)
			return ATRIB;
}

void countingsort(char *vec, int len){
	int min, max, j;
	max = vec[0];

	for(int i = 0; i < len; i++){
		if(vec[i] > max)
			max = vec[i];
	}

	int *count = new int[max+1];
	memset(count, 0, max+1);

	for (int i = 0; i < len; i++){
		count[vec[i]]++;
	}

	j = 0;
	for (int i = 0; i < len; i++){
		while(count[j] == 0)
			j++;
		
		vec[i] = j;
		count[j]--;
	}

	delete count;
}
  
long int hashKey(const char *word){
	int i, len;
	char *str = new char[strlen(word)];
	double sum = 0;
	long int key;

	strcpy(str,word);

	len = strlen(str);
	
	countingsort(str, len);

	for (i = 0; i < len; i++)
			sum += pow(27,len-(i+1)) * str[i];

	delete str;
	
	key = sum;
	key = key % 128;

	return key;
}

void initReservedWords(){
	long int pos = 0;

	pos = hashKey("program");
	reservedWords[pos].word = "program";
	reservedWords[pos].token = PROGRAM;

	pos = hashKey("begin");
	reservedWords[pos].word = "begin";
	reservedWords[pos].token = BEGIN_;

	pos = hashKey("end");
	reservedWords[pos].word = "end";
	reservedWords[pos].token = END;

	pos = hashKey("const");
	reservedWords[pos].word = "const";
	reservedWords[pos].token = CONST;

	pos = hashKey("var");
	reservedWords[pos].word = "var";
	reservedWords[pos].token = VAR;

	pos = hashKey("real");
	reservedWords[pos].word = "real";
	reservedWords[pos].token = REAL;

	pos = hashKey("integer");
	reservedWords[pos].word = "integer";
	reservedWords[pos].token = INTEGER;

	pos = hashKey("procedure");
	reservedWords[pos].word = "procedure";
	reservedWords[pos].token = PROCEDURE;

	pos = hashKey("else");
	reservedWords[pos].word = "else";
	reservedWords[pos].token = ELSE;

	pos = hashKey("read");
	reservedWords[pos].word = "read";
	reservedWords[pos].token = READ;

	pos = hashKey("write");
	reservedWords[pos].word = "write";
	reservedWords[pos].token = WRITE;

	pos = hashKey("while");
	reservedWords[pos].word = "while";
	reservedWords[pos].token = WHILE;

	pos = hashKey("do");
	reservedWords[pos].word = "do";
	reservedWords[pos].token = DO;

	pos = hashKey("if");
	reservedWords[pos].word = "if";
	reservedWords[pos].token = IF;

	pos = hashKey("then");
	reservedWords[pos].word = "then";
	reservedWords[pos].token = THEN;

	pos = hashKey("for");
	reservedWords[pos].word = "for";
	reservedWords[pos].token = FOR;

}

//--- Exibir um erro
void errorFunc(string errorString, string errorVar){
	cout << "\nERRO (Linha " <<  nLines << "): " << errorString << " => " << errorVar << "\n" << endl;
	nErrors++;
}
//---

bool checkReservedWord(string s, int *token){ //checar se eh uma palavra reservada
	long int i = hashKey(s.c_str());
	if (reservedWords[i].word.compare(s) == 0){
		*token = reservedWords[i].token;
		return true;
	}	

	return false;
}

void checkCommentaryLines(string commentaryString){ //checa a quantidade de "\n"s no comentario de varias linhas (para nao perder a contagem de linhas)
	for(int i = 0; i < commentaryString.length(); i++){
		if(commentaryString[i] == '\n') nLines++;
	}
}

//--- Checar os tamanhos dos identificadores e dos numeros
bool checkIdentSize(string s, int identSize){
	if(identSize > MAX_IDENT){
		errorFunc("Identificador muito grande.", s); 
		return false;
	}
	return true;
}

bool checkNumberSize(string numberString, string numberType, int numberSize){
	if(numberType.compare("integer") == 0){
		if(numberSize > MAX_INT){
			errorFunc("Numero inteiro muito grande.", numberString); 
			return false;
		}
	}else if(numberType.compare("real") == 0){
		if(numberSize > 2*MAX_INT){
			errorFunc("Numero real muito grande.", numberString); 
			return false;
		}
	}
	return true;
}

//Compilar e Executar: 
//flex exemplo10.l
//g++ lex.yy.c -o out.exe -std=c++11 -O3
//out.exe < input.txt
	
//simbolos e palavras reservadas => ["program", "begin", "end", "const", "var", "real", "integer", "procedure", "else", "read", "write", "while", "do", "if", "then"]
//								 => [";", ".", "=", ",", ":", "(", ")", ":=", "<>", ">=", "<=", ">", "<", "+", "-", "*", "/"]
//								 +  ident, numero_inteiro, numero_real
//								 +  for, etc.
// flex regex => http://people.cs.aau.dk/~marius/sw/flex/Flex-Regular-Expressions.html
//https://blog.xrds.acm.org/2017/12/flex-lexical-analysis/
//http://dinosaur.compilertools.net/flex/index.html
