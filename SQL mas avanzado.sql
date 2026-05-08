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

Las funciones de ventana se ejecutan CASI AL FINAL del query.
Se calculan después del WHERE, después del GROUP BY y después del HAVING, pero antes del ORDER BY.

Si necesitas filtrar por el resultado de una función de ventana, forzosamente tienes que meterla en un CTE (WITH) o subconsulta primero.
*/

/*
OVER()
Calcula funciones de agregación, pero no aplasta las filas. Muestra el resultado al lado de cada fila original.
*/

SELECT 
    nombre, 
    salario, 
    AVG(salario) OVER() AS promedio_global 
FROM empleados;

/*
PARTITION BY
PARTITION BY va dentro de los paréntesis del OVER(). Es como un GROUP BY, pero sin colapsar. Divide el set de datos en "ventanas" (grupos) lógicas y calcula la función solo para esa ventana.
*/

SELECT 
    nombre, 
    departamento,
    salario, 
    AVG(salario) OVER(PARTITION BY departamento) AS promedio_depto
FROM empleados;

SELECT nombre, grado, calificacion
FROM (
    SELECT 
        nombre, 
        grado, 
        calificacion,
        AVG(calificacion) OVER(PARTITION BY grado) AS promedio_del_grado
    FROM alumnos
) AS tabla_temporal -- ¡El alias es obligatorio!
WHERE calificacion > promedio_del_grado; 

SELECT
    id_venta,
    fecha,
    monto,
    SUM(monto) OVER() AS total_ventas
FROM ventas;

SELECT
    nombre,
    categoria,
    precio,
    MAX(precio) OVER(PARTITION BY categoria) AS maximo_categoria
FROM productos;

SELECT
    nombre,
    salario,
    departamento,
    salario - avg(salario) OVER(PARTITION BY departamento) AS diferencia_promedio
FROM empleados;

SELECT  
    id_pedido,
    id_cliente,
    COUNT(id_cliente) OVER(PARTITION BY id_cliente) AS cantidad_pedidos
FROM pedidos;

WITH promedios_departamentos AS (
    SELECT 
        nombre, 
        departamento, 
        salario,
        AVG(salario) OVER(PARTITION BY departamento) AS promedio_departamento
    FROM empleados
)
SELECT  *
FROM promedios_departamentos
WHERE salario > promedio_departamento

SELECT nombre, departamento, salario, promedio_departamento
FROM (
    SELECT 
        nombre, 
        departamento, 
        salario,
        AVG(salario) OVER(PARTITION BY departamento) AS promedio_departamento
    FROM empleados
) AS promedios_departamentos 
WHERE salario > promedio_departamento; 

-- en producción evitamos las subconsultas correlacionadas en tablas gigantes.
SELECT 
    e1.nombre,
    e1.departamento,
    e1.salario
FROM empleados e1 
WHERE e1.salario > (
    -- Esta subconsulta calcula el promedio SOLO para el grado que se está leyendo
    SELECT AVG(e2.salario)
    FROM empleados e2
    WHERE e1.departamento = e2.departamento 
);

-- Tema 4: JOIN de Subconsultas (Tablas Derivadas / Pre-agregación)
/*
En lugar de hacer un JOIN entre dos tablas físicas (que están guardadas en el disco), estamos haciendo un JOIN entre dos resultados temporales calculados al vuelo.

Sí, al realizar un JOIN con subconsultas (tablas derivadas o pre-agregaciones), es necesario tener un campo en común —como un ID, código o clave foránea— para establecer la relación lógica entre el conjunto de resultados derivado y la otra tabla o subconsulta

Se ejecutan bloques que crean tablas virtuales, Finalmente, hace un INNER JOIN entre esas dos tablas virtuales que solo existen en la memoria RAM durante ese milisegundo.
Agrupa primero, une después

Alias Obligatorios

*/
SELECT *
FROM (
    SELECT id_cliente, SUM(total) ventas
    FROM Pedidos
    GROUP BY id_cliente
) p
INNER JOIN (
    SELECT id_cliente, MAX(fecha) ultima_fecha 
    FROM Visitas
    GROUP BY id_cliente
) v
ON p.id_cliente = v.id_cliente;

SELECT 
    t1.id, 
    t2.total_ventas
FROM TablaPrincipal AS t1
JOIN (
    -- TABLA DERIVADA / PRE-AGREGACIÓN
    SELECT 
        cliente_id, 
        SUM(monto) AS total_ventas
    FROM Ventas
    GROUP BY cliente_id
) AS t2 ON t1.id = t2.cliente_id; -- CAMPO COMÚN (id/cliente_id)

WITH historial_completo AS (
    -- Metemos toda la operación de apilado aquí adentro
    SELECT id_cliente, 'Hizo un pedido' AS accion
    FROM pedidos
    
    UNION ALL
    
    SELECT id_cliente, 'Hizo una visita' AS accion
    FROM visitas
)
-- Y luego simplemente llamamos al resultado
SELECT * 
FROM historial_completo;

WITH 
-- 1. Empaquetamos todo lo de Pedidos
tabla_pedidos AS (
    SELECT id_cliente, total_comprado
    FROM pedidos
    WHERE estado = 'Completado'
), -- <--- ¡ESTA COMA ES LA CLAVE MAGICA!
-- 2. Empaquetamos todo lo de Visitas
tabla_visitas AS (
    SELECT id_cliente, fecha_visita
    FROM visitas
    WHERE fecha_visita > '2023-01-01'
)
-- 3. Finalmente, unimos nuestros dos paquetes limpios
SELECT p.id_cliente, p.total_comprado, v.fecha_visita
FROM tabla_pedidos p
JOIN tabla_visitas v ON p.id_cliente = v.id_cliente;

SELECT *
FROM (
    SELECT id_usuario, SUM(monto) gasto
    FROM compras 
    GROUP by id_usuario
) c
INNER JOIN (
    SELECT id_usuario, COUNT(id_ticket) tickets
    FROM soporte
    GROUP by id_usuario
) s
ON c.id_usuario = s.id_usuario
WHERE gasto > 1000

WITH 
todos_pedidos AS 
(
    SELECT id_cliente, SUM(total) ventas
    FROM Pedidos
    GROUP BY id_cliente
), 
todos_visitas AS
(
    SELECT id_cliente, MAX(fecha) ultima_fecha
    FROM Visitas
    GROUP BY id_cliente
)
SELECT *
FROM todos_pedidos p
JOIN todos_visitas v
ON p.id_cliente = v.id_cliente;

SELECT 
    d.id_departamento,
    d.nombre,
    e.num_empleados
FROM departamentos AS d
JOIN (
    SELECT 
        id_departamento, 
        COUNT(*) AS num_empleados
    FROM empleados
    GROUP BY id_departamento
) AS e ON d.id_departamento = e.id_departamento; 

-- Tema 5: El Ranking de los Datos (ROW_NUMBER, RANK, DENSE_RANK)
/*
Estas tres son Funciones de Ventana (Window Functions), por lo que usan la cláusula OVER(). Su propósito es asignar un número secuencial a las filas.
aquí es obligatorio usar un ORDER BY dentro del paréntesis, porque el motor necesita saber bajo qué criterio va a repartir los números (del 1 al N)

ROW_NUMBER() (El Estricto): Ignora los empates. Asigna un número único y secuencial sin importar nada.
(El desempate es aleatorio o según otra columna)

RANK() (El Justo pero con huecos): Reconoce el empate y les da el mismo lugar, pero se salta los números siguientes.
Ana: 1, Luis: 2, Carlos: 2, Zoe: 4. (Nadie quedó en 3er lugar).

DENSE_RANK() (El Compacto): Reconoce el empate pero no deja huecos.
Ana: 1, Luis: 2, Carlos: 2, Zoe: 3.
*/

/*
Eliminar Duplicados (Deduplicación)

*/
SELECT 
    id_cliente, 
    nombre, 
    fecha_registro,
    ROW_NUMBER() OVER(PARTITION BY id_cliente ORDER BY fecha_registro DESC) AS rn
FROM clientes;

-- ejercicios tema actual


-- futuros temas

TRY_CAST
Solución: Si esperas varios valores, usa el operador IN.

aprender WHERE MOD(ID, 2) = 0

Explícame cómo hacer más simple con HAVING, JOIN, o ventana
2. La forma "Pro": CTE (Cláusula WITH)

Funciones de Ventana (Window Functions) — Indispensable en 2026
subconsultas


JOINS
LAG() y LEAD() (Fundamentales para análisis de series temporales, como lo que hiciste con los taxis).
Función ventana.
Subconsultas y Modularización

Subconsultas en el WHERE y en el FROM.

CTEs (Common Table Expressions): Aprender a usar WITH. Es mucho más limpio y profesional que las subconsultas anidadas.

Manipulación de Tipos de Datos

Funciones de Fecha: DATE_TRUNC(), EXTRACT(), DATEDIFF().

Funciones de String: CONCAT(), SUBSTR(), COALESCE() (para manejar nulos).


