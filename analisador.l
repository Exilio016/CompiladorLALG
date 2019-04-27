%option noyywrap

%{

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

#include <iostream>
#include <string>
#include <math.h>

using namespace std;

int MAX_IDENT = 50; //tamanho maximo de um identificador
int MAX_INT = to_string(INT_MAX).length(); //tamanho maximo de um numero inteiro

int nLines = 1; //(comecar na linha 1) -> para mostrar o numero de linhas correto ao usuario
int nErrors = 0;
string token;

string reservedWords[128];

void initReservedWords();

void errorFunc(string errorString, string errorVar); //exibir erro

bool checkReservedWord(string s); //checar se eh uma palavra reservada

void checkCommentaryLines(string commentaryString); //checa a quantidade de "\n"s no comentario de varias linhas (para nao perder a contagem de linhas)

bool checkIdentSize(string s, int identSize); //checar os tamanhos dos identificadores
bool checkNumberSize(string numberString, string numberType, int numberSize); //c'hecar os tamanhos dos numeros

%}

NUMERO [0-9]
LETRA [a-zA-Z]

NUMERO_INTEIRO {NUMERO}+
NUMERO_REAL {NUMERO}+"."{NUMERO}+
IDENT {LETRA}({LETRA}|{NUMERO}|_)*

NOVA_LINHA "\n"|"\r\n"
CARACTERES_ESPECIAIS {NOVA_LINHA}|" "|"\r"|"\t"|"\s"

COMENTARIO_LINHA "{"[^}\n]*"}"
COMENTARIO_LINHAS "/*"([^\*]|"*"[^/])*"*/"

SIMBOLO_RESERVADO "<>"|">="|"<="|">"|"<"|":="|"="|"+"|"\-"|"*"|"/"|";"|"."|":"|","|"("|")"

IDENT_CARACTERES_NAO_PERMITIDOS [^0-9a-zA-Z"<>"">=""<="">""<"":=""=""+""\-""*""/"";""."":"",""("")"" ""\r""\t""\s""\n"|"\r\n"]
ERRO_IDENTIFICADOR_MAL_FORMADO ({IDENT}{IDENT_CARACTERES_NAO_PERMITIDOS}+({LETRA}|{NUMERO}|_)+)|({NUMERO}+({LETRA}|_)+)

ERRO_COMENTARIO_LINHA_MAL_FORMADO  ("{"[^}\n]*"\n"[^}]*"}")|"{"[^}]*
ERRO_COMENTARIO_LINHAS_MAL_FORMADO  "/*"([^\*]|"*"[^/])*

NUMERO_CARACTERES_NAO_PERMITIDOS [^0-9"<>"">=""<="">""<""=""+""-""*""/""."",""("")"" ""\r""\t""\s""\n"|"\r\n"]
ERRO_NUMERO_INTEIRO_MAL_FORMADO {NUMERO}+{NUMERO_CARACTERES_NAO_PERMITIDOS}+{NUMERO}+
ERRO_NUMERO_REAL_MAL_FORMADO ({NUMERO}+{NUMERO_CARACTERES_NAO_PERMITIDOS}+"."{NUMERO}+)|({NUMERO}+"."{NUMERO_CARACTERES_NAO_PERMITIDOS}+{NUMERO}+)|({ERRO_NUMERO_INTEIRO_MAL_FORMADO}"."({NUMERO}+|{ERRO_NUMERO_INTEIRO_MAL_FORMADO}))|(({NUMERO}+|{ERRO_NUMERO_INTEIRO_MAL_FORMADO})"."{ERRO_NUMERO_INTEIRO_MAL_FORMADO})

%%

{COMENTARIO_LINHA} {}

{ERRO_COMENTARIO_LINHA_MAL_FORMADO} {errorFunc("Comentario mal formado.", yytext); checkCommentaryLines(yytext);}
{ERRO_COMENTARIO_LINHAS_MAL_FORMADO} {errorFunc("Comentario mal formado.", yytext); checkCommentaryLines(yytext);}

{NOVA_LINHA} {nLines++;}

{CARACTERES_ESPECIAIS} {} 

{ERRO_NUMERO_REAL_MAL_FORMADO} {errorFunc("Numero real mal formado.", yytext);}
{ERRO_NUMERO_INTEIRO_MAL_FORMADO} {errorFunc("Numero inteiro mal formado.", yytext);}

{NUMERO_INTEIRO} { 	if(checkNumberSize(yytext, "integer", yyleng)){
						token = "NUMERO_INTEIRO";  return 0;
					}
				 } 
{NUMERO_REAL} { if(checkNumberSize(yytext, "real", yyleng)){
					token = "NUMERO_REAL";  return 0;
				}
			  }

{SIMBOLO_RESERVADO} {token = yytext;  return 0;}

{ERRO_IDENTIFICADOR_MAL_FORMADO} {errorFunc("Identificador mal formado.", yytext);}

{IDENT} {	if(checkIdentSize(yytext, yyleng)){
				if(checkReservedWord(yytext)){
					token = yytext;  return 0;
				}else{
					token = "IDENT";  return 0;
				}
			}
		}

<<EOF>> { token = "EOF";	return 0;}

. {errorFunc("Caractere invalido.", yytext);} 

%%
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

}
  
long int hashKey(const char *word){
	int i, len;
	char *str = (char *) malloc (sizeof(char)*(strlen(word)+1));
	double sum = 0;
	long int key;

	strcpy(str,word);

	len = strlen(str);
	
	countingsort(str, len);

	for (i = 0; i < len; i++)
			sum += pow(27,len-(i+1)) * str[i];

	free(str);

	key = sum;
	key = key % 128;

	return key;
}

void initReservedWords(){
	string vec[16] = {"program", "begin", "end", "const", "var", "real", "integer", "procedure", "else", "read", "write", "while", "do", "if", "then", "for"};
	memset(reservedWords, 0, 128);

	for(int i = 0; i < 16; i++){
		long int pos = 0;
		pos = hashKey(vec[i].c_str());
		reservedWords[pos] = vec[i].c_str();
	}
}

//--- Exibir um erro
void errorFunc(string errorString, string errorVar){
	cout << "\nERRO (Linha " <<  nLines << "): " << errorString << " => " << errorVar << "\n" << endl;
	nErrors++;
}
//---

bool checkReservedWord(string s){ //checar se eh uma palavra reservada
	long int i = hashKey(s.c_str());
	return (reservedWords[i].compare(s) == 0);	
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
		if(numberSize > MAX_INT){
			errorFunc("Numero real muito grande.", numberString); 
			return false;
		}
	}
	return true;
}
//---

int main()
{
	initReservedWords();
	while (token.compare("EOF") != 0){
		yylex();
		if(token.compare("EOF") != 0)
			printf("%s - %s\n", yytext, token.c_str());
	}

	printf("\nNumero de linhas de codigo analizadas: %d\n", nLines); 
	printf("\nNumero de erros lexicos encontrados: %d\n", nErrors); 
	return 0;
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
