%{
#include<stdio.h>
int yylex();
void yyerror(const char *s);
%}

%token PROGRAM IDENT BEG END CONST VAR REAL INTEGER PROCEDURE ELSE READ WRITE WHILE DO IF THEN ATRIB DIF MAIOR_IGUAL MENOR_IGUAL NUMERO_INT NUMERO_REAL FOR

%%
programa: PROGRAM IDENT ';' corpo '.'
        ;
corpo: dc BEG comandos END
     ;
dc: dc_c dc_v dc_p
  ;
dc_c: CONST IDENT '=' numero ';' dc_c 
    | 
    ;
dc_v: VAR variaveis ':' tipo_var ';' dc_v 
    | 
    ;
tipo_var: REAL 
        | INTEGER
        ;
variaveis: IDENT mais_var
         ;
mais_var: ',' variaveis 
        | 
        ; 
dc_p: PROCEDURE IDENT parametros ';' corpo_p dc_p 
    | 
    ;
parametros: '(' lista_par ')' 
          |
          ;
lista_par: variaveis ':' tipo_var mais_par
         ;
mais_par: ';' lista_par 
        |
        ;
corpo_p: dc_loc  BEG comandos END ';'
       ;
dc_loc: dc_v
      ;
lista_arg: '(' argumentos ')' 
         |
         ;
argumentos: IDENT mais_ident
          ;
mais_ident: ';' argumentos 
          |
          ; 
pfalsa: ELSE cmd 
      |
      ;
comandos: cmd ';' comandos 
        |
        ;
cmd: READ '(' variaveis ')' 
   | WRITE '(' variaveis ')' 
   | WHILE '(' condicao ')' DO cmd 
   | IF condicao THEN cmd pfalsa 
   | IDENT ATRIB expressao 
   | IDENT lista_arg 
   | BEG comandos END
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
	yyparse();
}

void yyerror(const char *s){
  printf("%s\n", s);
}