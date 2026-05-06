-- Tema 1: OUTER JOINS (LEFT y RIGHT JOIN)
/*
1. LEFT JOIN
Trae todas las filas de la tabla de la izquierda (la que está en el FROM) y las coincidencias de la derecha.
Si no hay coincidencia, rellena con NULL.

Uso típico: "Quiero ver todos los clientes, hayan comprado algo o no".
*/

/*
2. RIGHT JOIN
Es exactamente lo mismo pero prioriza la tabla de la derecha.

Casi no se suele usar esta, solo cambias el orden de las tablas en left join para obtener el resultado contrario.
*/

/*
3. ¿Por qué son vitales los NULLs aquí?
Cuando usas un LEFT JOIN, las filas que no tienen pareja aparecerán con valores vacíos (NULL). 
Esto te permite encontrar faltantes.
*/

-- Ejemplo: ¿Qué clientes nunca han hecho un pedido?
SELECT c.nombre
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE p.id IS NULL; -- Si el ID del pedido es NULL, es que no existe.

/*
Si haces un LEFT JOIN y luego pones un filtro en el WHERE sobre la tabla de la derecha, ¡puedes convertirlo accidentalmente en un INNER JOIN

Cuándo usar esto:
Cuando ya hiciste el join y quieres filtrar, pero conservando filas sin match.
*/

-- LEFT JOIN normal
SELECT c.nombre, p.monto
FROM clientes c
LEFT JOIN pagos p
ON c.id = p.cliente_id;

-- Error al usar WHERE, Filtra después del join.
SELECT c.nombre, p.monto
FROM clientes c
LEFT JOIN pagos p
ON c.id = p.cliente_id
WHERE p.monto > 100;

--Solucion 1 - Poner filtro en ON, cuando se unen
SELECT c.nombre, p.monto
FROM clientes c
LEFT JOIN pagos p
ON c.id = p.cliente_id
AND p.monto > 100; -- Solo une pagos mayores a 100, pero conserva todos los clientes.

/*
Las personas que no cumplen con la condicion no desaparecen, solo queda en null
Eso mantiene el propósito del LEFT JOIN:
conservar todas las personas.
*/

--Solucion 2 - Manejar NULL en WHERE, despues del join
SELECT c.nombre, p.monto
FROM clientes c
LEFT JOIN pagos p
ON c.id = p.cliente_id
WHERE p.monto > 100
   OR p.monto IS NULL;

/*
se quitaran todas las filas que no cumplan, si permites nulos estos se mostraran, pero seguira habiendo filas que no cumplieron
No se mostraran
*/

/*
Si la condición pertenece a la relación:
Usa ON

Si la condición pertenece al resultado final:
Usa WHERE
*/

SELECT c.nombre
FROM clientes c
LEFT JOIN pagos p
ON c.id = p.cliente_id
WHERE p.cliente_id IS NULL; --Clientes sin pagos.

SELECT c.nombre, p.id_pedido
FROM clientes c
LEFT JOIN pedidos p
ON c.id = p.cliente_id

SELECT d.nombre, COUNT(e.id_empleado) AS total_empleados -- Usar COUNT(*), incluso los d con 0 contarian porque la fila existe
FROM departamentos d
LEFT JOIN empleados e
ON d.id = e.id_departamento 
GROUP BY d.nombre

SELECT p.nombre, c.nombre
FROM productos p
LEFT JOIN categoria c
ON p.id_categoria = c.id

SELECT c.id, UPPER(c.nombre), MAX(p.fecha)
FROM clientes c
LEFT JOIN pedidos p
ON c.id = p.id_cliente
GROUP BY c.id

-- Tema de Refuerzo 2: El manejo de NULLs (COALESCE)
/*
imputación de datos.

La función COALESCE(valor, reemplazo) toma el primer valor que no sea nulo.
*/
SELECT c.id, UPPER(c.nombre), COALESCE(MAX(fecha), 'Sin pedidos')
FROM clientes c
LEFT JOIN pedidos p
ON c.id = p.id_cliente
GROUP BY c.id

-- Tema 3: Funciones de Ventana (Window Functions) - OVER y PARTITION BY
/*
El Problema de GROUP BY
El GROUP BY colapsa (aplasta) las filas. 
Pierdes el detalle de quién es el empleado, porque todo se resume a una fila por grupo.

*/



-- ejercicios tema actual


-- futuros temas

TRY_CAST
Solución: Si esperas varios valores, usa el operador IN.

aprender WHERE MOD(ID, 2) = 0

Explícame cómo hacer más simple con HAVING, JOIN, o ventana
2. La forma "Pro": CTE (Cláusula WITH)

Funciones de Ventana (Window Functions) — Indispensable en 2026
subconsultas

SELECT *
FROM
(
    SELECT id_cliente, SUM(total) ventas
    FROM Pedidos
    GROUP BY id_cliente
) p
INNER JOIN
(
    SELECT id_cliente, MAX(fecha) ultima_fecha
    FROM Visitas
    GROUP BY id_cliente
) v
ON p.id_cliente = v.id_cliente;
RANK(), DENSE_RANK(), ROW_NUMBER() (para eliminar duplicados).
JOINS
LAG() y LEAD() (Fundamentales para análisis de series temporales, como lo que hiciste con los taxis).
Función ventana.
Subconsultas y Modularización

Subconsultas en el WHERE y en el FROM.

CTEs (Common Table Expressions): Aprender a usar WITH. Es mucho más limpio y profesional que las subconsultas anidadas.

Manipulación de Tipos de Datos

Funciones de Fecha: DATE_TRUNC(), EXTRACT(), DATEDIFF().

Funciones de String: CONCAT(), SUBSTR(), COALESCE() (para manejar nulos).


