DIGITO [0-9]
LETRA [a-zA-Z]
LETRA_DIGITO [0-9a-zA-Z]
INVALIDO [^0-9a-zA-Z" "\t\n\r"=""\-""+"","":""("")""{""}""*"">""<""/"";""("")"",""."]
ESPACOS [" "\t\n\r]
%%
{ESPACOS} {}
"{".*"}" {}
{INVALIDO} {printf("%s - caracter inválido\n", yytext);}
{LETRA}+{LETRA_DIGITO}* {printf("%s - identificador\n", yytext);}
{DIGITO}+ {printf("%s - inteiro\n", yytext);}
{DIGITO}+"."{DIGITO}+ {printf("%s - real\n", yytext);}
":""=" {printf("%s - :=\n", yytext);}
":" {printf("%s - :\n", yytext);}
"=" {printf("%s - =\n", yytext);}
">""=" {printf("%s - >=\n", yytext);}
"<""=" {printf("%s - <=\n", yytext);}
">" {printf("%s - >\n", yytext);}
"<" {printf("%s - <\n", yytext);}
"+" {printf("%s - +\n", yytext);}
"\-" {printf("%s - -\n", yytext);}
"*" {printf("%s - *\n", yytext);}
"/" {printf("%s - /\n", yytext);}
";" {printf("%s - ;\n", yytext); }
"(" {printf("%s - (\n", yytext);}
")" {printf("%s - )\n", yytext);}
"," {printf("%s - ,\n", yytext);}
"." {printf("%s - .\n", yytext);}
%%