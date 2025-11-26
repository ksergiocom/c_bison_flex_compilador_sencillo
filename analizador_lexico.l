%{
#include "y.tab.h"
%}

%%

%{ 
	/* Expresiones para atrapar comentarios multilinea y una sola multilinea
	 * Ignoramos todo lo que vaya comentado.
	 *
	 * Podría usar estados para simplificar esto, pero he decidido probar
	 * aplicando expresiones regulares.
	 */
%}
\/\*([^*]|\*[^/])*\*\/		{;}
\/\/.*						{;}


%{ 
	// TOKENs para palabras reservadas de nuestro lenguaje de "alto" nivel 
%}
"sino" 						{return SINO;}
"si" 						{return SI;}
"mientras" 					{return MIENTRAS;}
"hacer" 					{return HACER;}
"imprimir" 					{return IMPRIMIR;}


%{
	// TOKENs para símbolos del lenguaje
%}
"(" 						{return LPAREN;}
")" 						{return RPAREN;}
"{" 						{return LBRACE;}
"}" 						{return RBRACE;}
";" 						{return SEMICOLON;}
"+" 						{return PLUS;}
"-" 						{return MINUS;}
"*" 						{return MULT;}
"/" 						{return DIV;}
"=" 						{return ASSIGN;}
"+=" 						{return PLUS_ASSIGN;}
"-=" 						{return MINUS_ASSIGN;}
"*=" 						{return MULT_ASSIGN;}
"/=" 						{return DIV_ASSIGN;}


%{
	/* TOKENs para NUM e IDs
	 *
	 * NUM: son numeros enteros manejados con el tipo int dentro de C
	 *
	 * ID: son identificadores alfanuméricos de variables que pueden
	 *   contener "_" y no pueden empezar por número
	 */
%}
[0-9]+ 						{yylval.v_int=atoi(yytext); 	return NUM;}
[a-zA-Z_][a-zA-Z0-9_]* 		{yylval.v_str=strdup(yytext);	return ID;}


%{
	/* Ignoramos todos los espacios, tabuladores y saltos de líneas
	 * (Por simplicidad, no nos preocupamos por otros caracteres no imprimibles)
	 */
%}
[" "\n\t]					{;}


%{
	/* Cualquier otro carácter que no hayamos tratado especificamente deben
	 * de producir un error. Por ello lo pasamos a Bison y esperamos que sea
	 * él quien lance el error al tratar un token "desconocido".
	 */
%}
.							{return yytext[0];}
