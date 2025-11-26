## Disclaimer

1. [https://youtu.be/pz3UgkyhgXk?si=0DyISvyZncHgYgPd&t=5651](https://youtu.be/pz3UgkyhgXk?si=0DyISvyZncHgYgPd&t=5651)
2. [https://youtu.be/pz3UgkyhgXk?si=J0mKRE_gSRfgMpi1](https://youtu.be/pz3UgkyhgXk?si=J0mKRE_gSRfgMpi1)

*¡En realidad me ha parecido un experimento muy divertida y didáctico!*

# Minicompilador (Flex+Bison)

Se trata de utilizar bison para obtener un compilador que traduzca un **lenguaje de alto nivel** a **código máquina** de pila abstracta

El lenguaje de alto nivel es muy sencillo. No tiene declaración de tipos y el** único tipo** que permite es el **tipo entero**. En las condiciones de los condicionales y bucles *(si y mientras)* el valor 0 se interpreta como falso y cualquier otro valor como verdadero.

Los comentarios son en línea comenzando con los carácteres '//', y multilínea entre ('/*' y '*/').

El terminal **NUM** representa un número entero positivo e **ID** un identificador/variable del lenguaje. Los identificadores pueden estar formados por letras, números o guiones bajos (pero no pueden comenzar por número). Las palabras reservadas son en minúsculas.

## Notas

Para poder ejecutar nuestro compilador primero tenemos que compilarlo con **flex** y **bison**. Para ello debemos tenerlos instalados en nuestra máquina y para facilitarnos la vida incluyo un **Makefile**.

**make** compila todo y le pasa un fichero de prueba con ćodigo a traducir. Tendremos nuestro binario con el nombre **a.out** por defecto que podemos usar con:

```bash
# Compilar y realizar una prueba
make
# Ahora podemos usar el binario compilado pasandole el código por stdin
./a.out < "nombre_fichero_código"
```

## Ejemplos

```c
// Inicio programa
_i = 0;          // Inicialización de variable
si (_i-10)       // Evalúa la expresión
{
    imprimir(_i);
}
sino{
    imprimir((100));
};
// Fin del condicional
vAriAble=(0-1+2)* x - (_i);
// Fin del programa
```

```bash
Debería mostrar (excepto quizá el número de las etiquetas):

	valori _i
	mete 0
	asigna
	valord _i
	mete 10
	sub
	sifalsovea LBL0
	valord _i
	print 
	vea LBL1
LBL0
	mete 100
	print 
LBL1
	valori vAriAble
	mete 0
	mete 1
	sub
	mete 2
	sum
	valord x
	mul
	valord _i
	sub
	asigna
```


---

```c
a = 10;
mientras ( a ) {
    imprimir  (a);
    a -= 1;
};
b = 33;
si (x - y) {a = b;};
imprimir(5*6-3-2*8/2);
si(_myVar-7)
{a=1;}
sino
{b=2;};
imprimir((0));
c l{var_do*=5;}mientras(x);
```


```bash
	valori a
	mete 10
	asigna
LBL0
	valord a
	sifalsovea LBL1
	valord a
	print 
	valori a
	valord a
	mete 1
	sub
	asigna
	vea LBL0
LBL1
	valori b
	mete 33
	asigna
	valord x
	valord y
	sub
	sifalsovea LBL2
	valori a
	valord b
	asigna
LBL2
	mete 5
	mete 6
	mul
	mete 3
	sub
	mete 2
	mete 8
	mul
	mete 2
	div
	sub
	print 
	valord _myVar
	mete 7
	sub
	sifalsovea LBL4
	valori a
	mete 1
	asigna
	vea LBL5
LBL4
	valori b
	mete 2
	asigna
LBL5
	mete 0
	print 
LBL6
	valori var_do
	valord var_do
	mete 5
	mul
	asigna
	valord x
	siciertovea LBL6
```

---


```c
/* Ejemplo de un bucle anidado:
   - El primero es un bucle infinito que inicializa var1, var2 y var3 e imprime var1
   - El segundo se repite mientras var1-var2 y actualiza var1 incrementándole con var2
*/
hacer {
    var1 = 10;
    var2 = 100;
    var3 = 5;
    imprimir ( var1 );
    mientras (var1-var3) {
        var1 += var2;
    };
    imprimir (variable);
} mientras (1);
```

```bash
LBL0
	valori var1
	mete 10
	asigna
	valori var2
	mete 100
	asigna
	valori var3
	mete 5
	asigna
	valord var1
	print 
LBL1
	valord var1
	valord var3
	sub
	sifalsovea LBL2
	valori var1
	valord var1
	valord var2
	sum
	asigna
	vea LBL1
LBL2
	valord variable
	print 
	mete 1
	siciertovea LBL0
```