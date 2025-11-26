all: a.out
	./a.out < ej2.txt

debug: lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -lfl -DYYDEBUG && ./a.out < ej1.txt

a.out:  lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -lfl

lex.yy.c: analizador_lexico.l
	flex analizador_lexico.l

y.tab.c: analizador_sintactico.y
	bison -yd analizador_sintactico.y

clean:
	rm -f y.tab.h y.tab.c a.out lex.yy.c