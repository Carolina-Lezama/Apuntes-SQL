-- Módulo 2: Manipulación de Datos (DML)

-- Tema 1: Hacer inserciones a tablas
-- Una insercion
INSERT INTO clientes (nombre, edad, ciudad)
VALUES ('Juan', 25, 'Puebla');

INSERT INTO clientes(nombre,email) VALUES ('juan','juan@gmail.com');

-- Multi insercion
INSERT INTO clientes (nombre, edad, ciudad)
VALUES 
('Ana', 30, 'CDMX'),
('Luis', 28, 'Guadalajara'),
('Maria', 22, 'Monterrey');

-- Insert sin especificar columnas, solo si conoces el orden exacto de las columnas
INSERT INTO clientes
VALUES ('Pedro', 40, 'Puebla');

-- Tema 2: UPDATE (Actualizar registros)
-- modificar valores ya existentes.
UPDATE usuarios 
SET email = 'nuevo_email@gmail.com', nombre = 'Carolina'
WHERE id_usuario = 5;

UPDATE productos SET precio = precio + 10 WHERE categoria = 'Electronica';

UPDATE clientes SET telefono = '555-1234' WHERE id_cliente = 45;

UPDATE clientes 
SET email = 'sin_correo@test.com'
WHERE email IS NULL;

-- Tema 3: DELETE (Borrar registros)
DELETE FROM usuarios 
WHERE id_usuario = 5;

DELETE FROM suscripciones WHERE fecha_vencimiento < '2024-01-01';

/*
NUNCA ejecutes un UPDATE o un DELETE sin una cláusula WHERE.
    Si ejecutas DELETE FROM usuarios; (sin el WHERE), borrarás todos los registros de la tabla de un solo golpe.
    Si ejecutas UPDATE productos SET precio = 0;, todos tus productos ahora valen cero.

Antes de hacer un borrado, ejecuta un SELECT con el mismo WHERE para estar segura de qué filas vas a afectar.
*/

-- Tema 4: TRUNCATE vs DELETE
DELETE FROM tabla; -- borra filas (puedes controlar cuáles), Lento en muchas filas

-- DELETE (borrado controlado), algunos registros.
DELETE FROM clientes
WHERE ciudad = 'Puebla';

-- Borrar todos los registros (forma lenta)
DELETE FROM clientes;

TRUNCATE TABLE tabla; -- borra TODO rápido (resetea la tabla), no usa where

-- Reinicia IDs (AUTO_INCREMENT)
TRUNCATE TABLE clientes;

/*
TRUNCATE es más eficiente porque no registra fila por fila, sino que reinicia la estructura de almacenamiento
*/

-- Tema 5: Quitar filas duplicadas DISTINCT
SELECT DISTINCT CITY -- Devuelve solo valores únicos (sin duplicados)
FROM STATION
WHERE MOD(ID, 2) = 0;

SELECT DISTINCT nombre FROM clientes;   

SELECT DISTINCT nombre, ciudad -- elimina duplicados considerando la combinación completa de columnas
FROM clientes;
-- combinaciones únicas de nombre + ciudad

-- have an even ID number = numeros pared de ID

-- Tema 6: Funciones de Agregación (El poder estadístico)

COUNT()	 -- Cuenta el número de filas o valores.	¿Cuántos clientes tenemos?
SUM()	 -- Suma los valores de una columna numérica.	¿Cuánto se vendió hoy?
AVG()	 -- Calcula el promedio (Average).	¿Cuál es el salario promedio?
MIN()	 -- Encuentra el valor más bajo.	¿Cuál es el producto más barato?
MAX()	 -- Encuentra el valor más alto.	¿Cuál es la venta máxima?

/*
Regla no escrita: cada funcion de agregacion lleva un alias para evitar un No column name

Las funciones de agregación no van exclusivamente en el SELECT
Las funciones de agregación (excepto COUNT(*)) ignoran los valores NULL.

no puedes usar agregaciones directamente en WHERE
*/

COUNT(*) --cuenta todas las filas, incluso si están vacías.
COUNT(email) --solo cuenta las filas donde el email no sea NULL.

SELECT 
    COUNT(*) AS total_pedidos,
    SUM(monto) AS ingresos_totales,
    AVG(monto) AS promedio_venta
FROM ventas;

-- Funciones de agregacion en HAVING
SELECT departamento, AVG(salario) AS promedio_salario
FROM empleados
GROUP BY departamento
HAVING AVG(salario) > 10000;

-- subconsulta para usar agregaciones en where
SELECT *
FROM empleados
WHERE salario > (
    SELECT AVG(salario) FROM empleados
);

-- En ORDER BY
SELECT departamento, AVG(salario) AS promedio
FROM empleados
GROUP BY departamento
ORDER BY promedio DESC;

/*
MAX() y MIN() NO necesitan LIMIT, por defecto devuelven un solo valor
las funciones de agregacion siempre regresan 1 fila con 1 valor, no importa cuántos registros haya.

Cuando usas agregación sola sin GROUP BY,todas las funciones de agregación devuelven un solo valor
*/
-- devolver todas las filas del maximo
SELECT * 
FROM empleados
WHERE salario = (
    SELECT MAX(salario) FROM empleados
);

-- devolver multiples resultados con GROUP BY y funciones de agregacion
SELECT departamento, AVG(salario)
FROM empleados
GROUP BY departamento;

SELECT COUNT(telefono) AS cantidad_telefono 
FROM usuarios;

SELECT MAX(precio) AS articulo_caro, MIN(precio) AS articulo_barato 
FROM productos;

SELECT AVG(salirio) AS promedio_salarial 
FROM empleados;

SELECT SUM(total_pago) 
FROM pedidos 
WHERE fecha BETWEEN '2026-01-01' AND '2026-12-31';

-- Tema 7: GROUP BY (Agrupamiento)
/*
el GROUP BY es el "separador por categorías"(grupos específicos de datos.).
Genera categorias a las cuales se les pueden caplicar funciones de agregacion que mostraran un resultado por categoria, en lugar de uno total.
*/

SELECT 
    pais, 
    COUNT(*) AS total_clientes
FROM 
    clientes
GROUP BY 
    pais;

-- el motor separa a los clientes por país y luego cuenta cuántos hay en cada montón.

-- Agrupamiento por múltiples columnas
SELECT 
    anio, 
    mes, 
    SUM(monto) AS total_mes
FROM 
    ventas
GROUP BY 
    anio, mes;

/*
Sin GROUP BY: Si pides SUM(valor), la base de datos toma todo el balde y te da un solo número (el total de dinero).
Con GROUP BY: Si pides SELECT pais, SUM(valor) ... GROUP BY pais, agrupa por categorias, valores diferentes, aplica la funcion de agregacion, regresa un resultado.

En el SELECT solo puedes tener dos tipos de cosas:
1. Columnas que están en el GROUP BY
2. Funciones de agregación
*/

SELECT id_vendedor, SUM(monto_venta) 
FROM ventas 
GROUP BY id_vendedor;

/*
Escenario                                            ¿Uso GROUP BY?
"Quiero el total de ventas de toda la historia."            NO
"Quiero el total de ventas por cada mes."                   SÍ

En motores modernos y estrictos. 
El motor te dirá: "La columna debe aparecer en la cláusula GROUP BY o ser utilizada en una función de agregación".

Revisar si realmente necesitas un GROUP BY o solo un ORDER BY
*/

SELECT materia, MAX(calificacion) 
FROM clases GROUP 
BY materia;

SELECT departamento, ciudad, COUNT(*) 
FROM empleados 
GROUP BY departamento, ciudad;

/*
La diferencia de poner Ciudad en el GROUP BY: Si haces GROUP BY departamento, ciudad, SQL ya no hace una bandeja por departamento, sino una bandeja por combinación única.
Bandeja 1: Ventas - Puebla.
Bandeja 2: Ventas - CDMX.
Bandeja 3: RRHH - Puebla.
*/

SELECT id_empleado, SUM(monto) FROM VENTAS GROUP BY id_empleado;
-- CONSEJO: Agrega un alias al SUM(monto) como AS total_ventas para que el reporte sea profesional.

SELECT genero, COUNT(genero) AS cantidad FROM clientes GROUP BY genero;

SELECT pais, ciudad, COUNT(envios) FROM envios GROUP BY pais, ciudad;

SELECT sucursal, producto, SUM(cantidad) FROM inventario GROUP BY sucursal, producto;

-- Tema 8: HAVING (El filtro de los grupos)

/*
¿Cómo filtro los resultados de un GROUP BY?
¿Por qué no puedo usar WHERE? Porque el WHERE actúa antes de agrupar (revisa fila por fila). El HAVING actúa después de agrupar.

WHERE: Filtra filas (ej. solo empleados que ganen más de 10k).
HAVING: Filtra grupos (ej. solo departamentos que, en promedio, ganen más de 50k).
*/

SELECT departamento, AVG(salario) AS promedio
FROM empleados
GROUP BY departamento
HAVING AVG(salario) > 50000;

/*
1. where: ocurre primero, es el filtro inicial, revisa fila por fila
2. group by: este ocurre despues de la primera filtracion es decir, agrupa el resultado anterior
3. having: es el filtro para los grupos, el tercero que se ejecuta en orden.

having funciona similarmente a where, solo muestra resultados que cumplan con la condicion.
Solo se mostrarían los grupos que cumplen la condición del HAVING.

¿Qué pasa si ningún valor cumple? 
Te saldrá un resultado vacío. Verás los nombres de las columnas, pero ninguna fila debajo. Es un "Empty Set".

En HAVING no siempre debes usar una función de agregación.
Puedes usar condiciones sobre columnas agrupadas, dependiendo del motor SQL y de si la columna está en el GROUP BY.

Si la condición no depende del agregado y puede aplicarse antes de agrupar, usa WHERE
*/

SELECT pais, AVG(poblacion) AS promedio
FROM ciudades
GROUP BY pais
HAVING AVG(poblacion) > 5000000;

SELECT pais, COUNT(*) AS total
FROM clientes
GROUP BY pais
HAVING COUNT(*) > 10;

SELECT pais, COUNT(*)
FROM clientes
GROUP BY pais
HAVING pais > 'M'; --Aquí pais está en GROUP BY, así que puede usarse para filtrar grupos.

-- Lo que NO suele ser válido
HAVING salario > 1000 --Usar una columna no agrupada ni agregada, si salario no está en GROUP BY ni dentro de AVG, SUM, etc.

SELECT id_vendedor, SUM(ventas) FROM ventas GROUP BY id_vendedor HAVING SUM(ventas)>1000;

SELECT categoria, sum(cantidad) 
FROM productos 
GROUP BY categoria 
HAVING sum(cantidad) > 5;

-- sum(cantidad) > 5; filtrando por "más de 5 unidades de stock".
-- COUNT(*) > 5; "más de 5 tipos de productos".

SELECT puesto, AVG(salario) AS salario_promedio 
FROM empleados 
WHERE pais = 'Mexico' 
GROUP BY puesto 
HAVING AVG(salario)> 20000;

/*
Error del WHERE COUNT(*) > 10:
El WHERE ocurre antes. Como no se ha agrupado, el motor no puede "contar" todavía.
*/

SELECT id_cliente 
FROM pedidos 
GROUP BY id_cliente 
HAVING COUNT(pedidos)> 3;

SELECT ciudad, SUM(ventas_diarias) AS total_ventas 
FROM tiendas 
GROUP BY ciudad 
HAVING SUM(ventas_diarias) < 5000 
ORDER BY ciudad ASC;

SELECT id_lote, AVG(defectos) AS cantidad_defectos
FROM produccion 
GROUP BY id_lote 
HAVING AVG(defectos) = 0 
ORDER BY id_lote DESC;

SELECT carrera, AVG(promedio) AS promedio_general 
FROM estudiantes 
WHERE Semestre = '3er' 
GROUP BY carrera 
HAVING AVG(promedio) >8.5 ORDER BY promedio_general DESC ; -- Es posible usar los alias ya que estoy existen cuando se usa el select

SELECT proveedor, COUNT(*) 
FROM proveedores 
GROUP BY proveedor 
HAVING COUNT(*) >10 
ORDER BY proveedor;

-- Tema 9: El Alma de las Relaciones (PK y FK)
/*
Las llaves son los puentes que conectan la información.

1. Primary Key (PK) - La Llave Primaria
    Es el identificador único de una fila.
    No puede haber dos filas con la misma PK, Jamás puede estar vacía, No debería cambiar nunca, Una tabla solo puede tener una PK

2. Foreign Key (FK) - La Llave Foránea
    Es una columna en una tabla (Tabla B) que hace referencia a la Primary Key de otra tabla (Tabla A). Es el vínculo.

jamás, crees una tabla que dependa de otra sin definir explícitamente una FOREIGN KEY
*/

/*
3. ¿Borrado físico o "Soft Delete" (Estatus)?
Es una excelente práctica y, en el mundo profesional, es casi obligatoria. Se le llama Borrado Lógico.

¿Por qué?: Si borras un usuario (DELETE), pierdes toda su historia de compras, logs y métricas. 
Si solo cambias su estatus a 'inactivo', mantienes la integridad de los datos para reportes históricos, pero el usuario ya no puede iniciar sesión.
*/

/*
2. Nombres de PK y FK
No es obligatorio, pero es la convención estándar, las llaves foraneas se llaman igual que las primary keys
*/

/*
3. El "Trap" de los Alias en HAVING
Según el estándar SQL (ANSI), el HAVING ocurre antes que el SELECT, por lo tanto, el alias no existe todavía.
*/

-- Tema 10: Funciones de Texto (Manipulación de Strings)
/*
Función                         Propósito                           Ejemplo
LENGTH()                        Cuenta los caracteres de un texto.  LENGTH('Hola') -> 4
"LEFT(texto, n)"                Extrae los primeros n caracteres.   LEFT('Puebla', 3) -> 'Pue'
"RIGHT(texto, n)"               Extrae los últimos n caracteres.    RIGHT('Puebla', 2) -> 'la'
"SUBSTRING(t, inicio, largo)"   Extrae una parte específica.        SUBSTRING('DataScience', 5, 7) -> 'Science'
ROUND()
CONCAT()
SUBSTR()


Herramientas de Limpieza y Formato
UPPER() / LOWER()
TRIM(): Elimina espacios vacíos al inicio y al final.
REPLACE(texto, 'viejo', 'nuevo')
*/

-- Evita usar funciones de texto en el WHERE sobre columnas indexadas.
-- el motor de la base de datos no puede usar el índice de la columna email porque tiene que transformar cada fila a mayúsculas antes de comparar

SELECT UPPER(nombre), LOWER(email)
FROM usuarios;

SELECT RIGHT(sku, 5)
FROM productos;

SELECT TRIM(nombre)
FROM clientes;

SELECT nombre, LEFT(contraseña, 3) AS pista
FROM clientes;

SELECT LENGTH(nombre) AS ciudades
FROM sedes
WHERE LENGTH(nombre) > 10
ORDER BY ciudades DESC;

-- Tema 11: INNER JOIN (La intersección pura)
/*
Si las tablas fueran conjuntos, el INNER JOIN es la parte donde ambos círculos se enciman. Solo devuelve las filas donde hay una coincidencia exacta en ambas tablas.

Necesitas tres cosas:
    Tabla A (Izquierda).
    Tabla B (Derecha).
    La Condición (ON)

¿Qué pasa si no hay coincidencia?
esas filas desaparecen del resultado. El INNER JOIN es estricto: "O están los dos, o no está nadie".
*/

SELECT e.nombre, d.nombre_depto
FROM empleados AS e
INNER JOIN departamentos AS d ON e.id_depto = d.id_depto;

-- ejemplo completo de todo en uno.
SELECT
    t1.columna,
    COUNT(*),
    SUM(t2.valor)
FROM tabla1 t1
INNER JOIN tabla2 t2
    ON t1.id = t2.id
WHERE condicion
GROUP BY t1.columna
HAVING SUM(t2.valor) > 100
ORDER BY SUM(t2.valor) DESC;

-- Si declaraste el alias en el FROM o en el JOIN, debes usar el alias en el WHERE.
/*
Una vez que le asignas un alias a una tabla en una consulta el motor de la base de datos "olvida" el nombre original por el resto de la ejecución de ese query.
*/

/*
Posible error en consultas si existen columnas de mismo nombre en ambas tablas.

usuarios
| id | nombre |

compras
| id | usuario_id | fecha |

¿Cuál id quieres?
Eso genera error tipo: Column 'id' is ambiguous
*/

-- error
SELECT nombre, fecha, id
FROM usuarios
INNER JOIN compras ON usuarios.id = compras.usuario_id;

-- solucion
SELECT nombre, fecha, usuarios.id --o compras.id
FROM usuarios
INNER JOIN compras
ON usuarios.id = compras.usuario_id;

SELECT p.nombre, c.categoria_nombre
FROM productos AS p
INNER JOIN categorias AS c ON p.id_categoria = c.id_categoria
WHERE p.precio > 100; -- Aquí usamos 'p'

SELECT C.nombre, p.monto
FROM clientes AS C
INNER JOIN pedidos AS p
ON ON C.id = p.id_cliente;
-- Error: C.id = p.id, casi siempre suele ser llave primaria

SELECT e.nombre, s.ciudad
FROM empleados AS e
INNER JOIN sedes AS s
ON e.id_sede = s.id_sede;
WHERE e.nombre LIKE 'A%'
-- El orden estricto es FROM -> JOIN -> WHERE

SELECT 
    c.nombres, 
    COUNT(*)
FROM productos AS p
INNER JOIN categorias AS c
    ON p.id_categoria = c.id_categoria
GROUP BY c.nombres;

SELECT l.titulo, UPPER(a.nombre) 
FROM autores AS a
INNER JOIN libros AS l
ON a.id_autor = l.id_autor
WHERE LENGTH(l.titulo) > 15;

/*
¿Se pueden unir más de dos tablas?
Sí. Un INNER JOIN puede unir 3, 4 o más tablas siempre que exista relación entre ellas.
El resultado de la unión de la Tabla A y B se convierte en una "tabla virtual" a la que luego le pegas la Tabla C

Nunca unas tablas por columnas que no tengan el mismo tipo de dato. 
Si id_cliente en una tabla es INT y en la otra es VARCHAR, el motor tendrá que hacer una conversión implícita en cada fila.
*/

SELECT 
    u.nombre,
    c.id_compra,
    p.producto,
    p.precio,
    pa.metodo
FROM usuarios u
INNER JOIN compras c
    ON u.id_usuario = c.id_usuario
INNER JOIN productos p
    ON c.id_producto = p.id_producto
INNER JOIN pagos pa
    ON c.id_compra = pa.id_compra;
-- No todas las tablas deben tener la misma columna ni el mismo nombre de llave.

SELECT 
    u.nombre,
    COUNT(c.id_compra) AS total_compras,
    SUM(p.precio) AS gasto_total
FROM usuarios u
INNER JOIN compras c
    ON u.id_usuario = c.id_usuario
INNER JOIN productos p
    ON c.id_producto = p.id_producto
GROUP BY u.nombre;











aprender WHERE MOD(ID, 2) = 0;

LEFT JOIN: Vital para encontrar datos faltantes (muy común en limpieza de datos).
FULL OUTER JOIN y CROSS JOIN (casos de uso específicos).
Lógica Condicional
Aprender a usar CASE WHEN: Crear categorías o etiquetas sobre la marcha (útil para Feature Engineering).


/*
*/

