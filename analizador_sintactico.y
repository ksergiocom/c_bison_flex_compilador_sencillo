%{
      /* Debemos definir una union para que Bison sepa que tipos de datos vamos a utilizar para intercambiar datos en la pila.
       * Estos datos se especifican más adelante en las acciones semánticas para saber si es de tipo "int" o "*char"
       * Además especificamos el tipo de ID y NUM tanto en la declaración de los tokenes en este fichero como en el analizador
       * léxico de flex al retornarlos con yylval.
       */
%}
%union{
    int      v_int;
    char    *v_str;

}

%{
      /* Definición de todos los TOKENs que acepta bison.
       * Especifico aquí los tipos para NUM e ID, aunque luego en las acciones semánticas lo vuelvo a hacer explícito.
       *
       * Si flex nos llegase a pasar algún TOKEN no definidio aquí produciría un error que atrapamos y tratamos con yyerror.
       */
%}
%token SI SINO MIENTRAS HACER IMPRIMIR LPAREN RPAREN LBRACE RBRACE SEMICOLON PLUS MINUS MULT DIV ASSIGN PLUS_ASSIGN MINUS_ASSIGN MULT_ASSIGN DIV_ASSIGN
%token <v_int>NUM
%token <v_str>ID


%{
      /* He decidido juntar todas las expresiones válidas en una única producción llamada "expr".
       * Para evitar conflictos debemos especificar el orden de asociación de las operaciones.
       * 
       * Al especificar la multiplicación y división debajo le damos mayor precedencia respecto a la suma y resta.
       */
%}
%left PLUS MINUS
%left MULT DIV


%{
#include <stdio.h>
#include <stdlib.h>

// Variable para activar el debug rápidamente
int yydebug=0;

// Función que mantiene el número de etiquetas de forma global
int getNextNumber()
{
   static int nextNumber=0;
   return nextNumber++; // Quiero empezar en 0 y después de ser llamado lo incremento.
}

// Necesitamos dejar la signature para que no se queje el compilador.
int yyerror (char*);
int yylex ();
%}

%%

/* Gramática del lenguaje.
 * 
 * He adaptado algunas de las producciones para que me resulten más sencillas de entender.
 * Es necesario desambiguar "expr" con %left para especificar que se asocia a izquierdas.
 * Es necesario crear una producción ficticia en "sel_stmt" para resolver otra ambigüedad del parser
 * (también podríamos factorizar, pero me resulta más sencillo de entender así).
 */

// Axioma: Lista de sentencias recursiva
list_sntcs:
      sntnc SEMICOLON list_sntcs 
    | sntnc SEMICOLON 
    ;

// Sentencias (if, while, asignación, print)
sntnc:
      sel_stmt 
    | iter_stmt 
    | assig_stmt 
    | print_stmt 
    ;

// Orden de print de la expresión evaluada
print_stmt: 
    IMPRIMIR LPAREN expr RPAREN {printf("\tprint\n");}
    ;

// Producción para control de flujo tipo "if" o "if...else..."
sel_stmt:
      SI LPAREN expr RPAREN si_falso_vea LBRACE list_sntcs RBRACE {printf("LBL%d\n", $<v_int>5);}
    | SI LPAREN expr RPAREN si_falso_vea LBRACE list_sntcs RBRACE {printf("\tvea LBL%d\n", $<v_int>$=getNextNumber());} SINO {printf("LBL%d\n", $<v_int>5);} LBRACE list_sntcs RBRACE {printf("LBL%d\n", $<v_int>9);}
    ;
// Producción ficticia para resolver conflicto en la anterior.
si_falso_vea:
    {printf("\tsifalsovea LBL%d\n", $<v_int>$=getNextNumber());}

// Producción para bucles tipo "while" o "do...while"
iter_stmt: 
      MIENTRAS {printf("LBL%d\n", $<v_int>$=getNextNumber());} LPAREN expr RPAREN {printf("\tsifalsovea LBL%d\n", $<v_int>$=getNextNumber());} LBRACE list_sntcs RBRACE {printf("\tvea LBL%d\n", $<v_int>2); printf("LBL%d\n", $<v_int>6);}
    | HACER {printf("LBL%d\n", $<v_int>$=getNextNumber());} LBRACE list_sntcs RBRACE MIENTRAS LPAREN expr RPAREN {printf("\tsiciertovea LBL%d\n", $<v_int>2);} 
    ;

// Asignaciones a variables incluyendo las asignaciones "compuestas"
assig_stmt: 
      ID {printf("\tvalori %s\n", $1); free($1);} ASSIGN expr {printf("\tasigna\n");}
    | ID {printf("\tvalori %s\n\tvalord %s\n", $1, $1); free($1);} PLUS_ASSIGN expr     {printf("\tsum\n");} 
    | ID {printf("\tvalori %s\n\tvalord %s\n", $1, $1); free($1);} MINUS_ASSIGN expr    {printf("\tsub\n");} 
    | ID {printf("\tvalori %s\n\tvalord %s\n", $1, $1); free($1);} MULT_ASSIGN expr     {printf("\tmul\n");} 
    | ID {printf("\tvalori %s\n\tvalord %s\n", $1, $1); free($1);} DIV_ASSIGN expr      {printf("\tdiv\n");} 
    ;

/* Expresiones
 * Producción básica para evaluar cualquier cosa que se evalua en ultima instancia en un valor.
 * Tanto en un valor literal como en el valor que pueda tener una variable.
 */
expr: 
      expr PLUS expr          {printf("\tsum\n\tasigna\n");}
    | expr MINUS expr         {printf("\tsub\n\tasigna\n");}
    | expr DIV expr           {printf("\tdiv\n\tasigna\n");}
    | expr MULT expr          {printf("\tmul\n\tasigna\n");}
    | LPAREN expr RPAREN 
    | val 
    ;

// Valor; los valores son ó Enteros "literales" (tal cual) o identificadores (variables).
val: 
      NUM   {printf("\tmete %i\n", $1);}            
    | ID    {printf("\tvalord %s\n", $1); free($1);}            
    ;

%%

/* Funcion para manejar posibles errores que se produzcan durante el analisis.
 * Simplemente sacamos el error por salida estandar para poder hacer desde el
 * exterior algo como 2> hacía donde necesitemos.
 */
int yyerror(char *s) {
    fprintf(stderr,"%s\n",s); 
    exit(-1);
}

/* Inicio del análsis.
 * 
 * Aquí solo analizo desde la entrada estándar. Para leer cualquier fichero simplemente
 * debemos pasarlo como:
 * 
 * ./a.out < "nombre_fichero"
 *
 * *(Donde a.out es el nombre del fichero ya compilado y nombre_fichero el ficheor que
 *  contiene el código a traducir).
 */
int main() { 
    yyparse();
    return 0;
}