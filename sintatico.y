%{
#include <stdio.h>
int yylex();
void yyerror(const char *s);
extern void initReservedWords();
extern int nLines;
%}

%token PROGRAM IDENT BEGIN_ END CONST VAR REAL INTEGER PROCEDURE ELSE READ WRITE WHILE DO IF THEN ATRIB DIF MAIOR_IGUAL MENOR_IGUAL NUMERO_INT NUMERO_REAL FOR
%define parse.error verbose
%define parse.lac full
%%
programa: PROGRAM IDENT ';' corpo '.'
        | PROGRAM IDENT ';' error '.' {yyerrok;}
        | error ';' corpo '.' {yyerrok;}
        | error '.' {yyerrok;}
        ;
corpo: dc BEGIN_ comandos END
     | error BEGIN_ comandos END {yyerrok;}
     | error END {yyerrok;}
     ;
dc: dc_c dc_v dc_p 
  | error dc_v dc_p {yyerrok;}
  | error dc_p {yyerrok;}
  ;
dc_c: CONST IDENT '=' numero ';' dc_c 
    | CONST IDENT '=' error ';' dc_c {yyerrok;}
    |
    ;
dc_v: VAR variaveis ':' tipo_var ';' dc_v 
    | VAR error ':' tipo_var ';' dc_v {yyerrok;}
    | VAR variaveis ':' error ';' dc_v {yyerrok;}
    |
    ;
tipo_var: REAL 
        | INTEGER
        ;
variaveis: IDENT mais_var
         | error mais_var {yyerrok; }
         ;
mais_var: ',' variaveis 
        | 
        ; 
dc_p: PROCEDURE IDENT parametros ';' corpo_p dc_p 
    | PROCEDURE IDENT error ';' corpo_p dc_p {yyerrok;}
    | PROCEDURE IDENT parametros ';' error dc_p {yyerrok;}
    | error IDENT parametros ';' corpo_p dc_p {yyerrok; }
    | PROCEDURE error parametros ';' corpo_p dc_p {yyerrok; }
    | error ';' corpo_p dc_p {yyerrok;}
    | error dc_p {yyerrok;}  
    |
    ;
parametros: '(' lista_par ')' 
          |  error ')' {yyerrok;}
          | '(' error ')' {yyerrok; }
          |
          ;
lista_par: variaveis ':' tipo_var mais_par
         | error ':' tipo_var mais_par {yyerrok;}
         | variaveis ':' error mais_par {yyerrok;}
         | error mais_par {yyerrok; }
         ;
mais_par: ';' lista_par 
        | error lista_par {yyerrok;}
        |
        ;
corpo_p: dc_loc  BEGIN_ comandos END ';'
       | error BEGIN_ comandos END ';' {yyerrok; }
       | dc_loc error comandos END ';' {yyerrok;}
       | dc_loc BEGIN_ error END ';' {yyerrok;}
       | dc_loc BEGIN_ comandos error ';' {yyerrok;}
       | error END ';' {yyerrok;}
       | error ';' {yyerrok;}
       ;
dc_loc: dc_v
      ;
lista_arg: '(' argumentos ')' 
         | error ')' {yyerrok;}
         | '(' error ')' {yyerrok;}
         |
         ;
argumentos: IDENT mais_ident
          | error mais_ident {yyerrok;}
          ;
mais_ident: ';' argumentos 
          | error argumentos {yyerrok;}
          |
          ; 
pfalsa: ELSE cmd 
      | error cmd {yyerrok;}
      |
      ;
comandos: cmd ';' comandos 
        | error ';' comandos {yyerrok;}
        | cmd error comandos {yyerrok;}
        | error comandos {yyerrok;}
        |
        ;
cmd: READ '(' variaveis ')'
   | READ error ')'   {yyerrok;}
   | WRITE '(' variaveis ')'
   | WRITE error ')' ';' {yyerrok;}
   | WHILE '(' condicao ')' DO cmd
   | WHILE error DO cmd  {yyerrok;}
   | IF condicao THEN cmd pfalsa
   | IF error THEN cmd pfalsa  {yyerrok;}
   | IDENT ATRIB expressao
   | IDENT lista_arg
   | BEGIN_ comandos END
   ;
condicao: expressao relacao expressao
        ;
relacao: '=' 
       | DIF 
       | MAIOR_IGUAL 
       | MENOR_IGUAL 
       | '>' 
       | '<'
       ;
expressao: termo outros_termos
         ;
op_un: '+' 
     | '-' 
     | 
     ;
outros_termos: op_ad termo outros_termos 
             |
             ;
op_ad: '+' 
     | '-'
     ;
termo: op_un fator mais_fatores
     ;
mais_fatores: op_mul fator mais_fatores 
            |
            ;
op_mul: '*' 
      | '/'
      ;
fator: IDENT 
     | numero 
     | '(' expressao ')'
     ;
numero: NUMERO_INT 
      | NUMERO_REAL
      ;

%%

int main(){
  initReservedWords();
	yyparse();
}

void yyerror(const char *s){
      printf("%s on line %d\n", s, nLines);
}
