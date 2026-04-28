-- Tema 1: CAST, CONVERTIR TIPO DE DATO
/*
Cuando usas funciones como REPLACE, el resultado suele ser una cadena de texto (String).
si quiere usar funciones de agregacion primero debe volver a ser INT.

Enteros:	INT, INTEGER, SIGNED, UNSIGNED
Decimales:	DECIMAL(p,s), FLOAT, REAL
Texto:	CHAR, VARCHAR, TEXT
Fechas:	DATE, DATETIME, TIME
*/

-- Convertir el texto '2500' en un entero
SELECT CAST('2500' AS UNSIGNED); -- En MySQL
SELECT CAST('2500' AS INT);      -- En SQL Server/Postgres

-- Convertir Números a Texto
SELECT 'El ID del usuario es: ' + CAST(ID AS VARCHAR)
FROM Usuarios;

-- Quitar decimales (Redondear truncando)
SELECT CAST(150.99 AS SIGNED); 
-- Resultado: 150

SELECT AVG(CAST(REPLACE(Salary, '0', '') AS DECIMAL))
FROM EMPLOYEES;


-- Tema 2: Subconsultas (Queries dentro de Queries)
/*
Utiles para realizar un filtro basado en un cálculo que no conoces de antemano. 
Es como preguntarle a la base de datos: "Dame todos los productos cuyo precio sea mayor al promedio" (Primero necesitas saber el promedio, ¿cierto?).

¿Dónde se pueden usar?
    En el WHERE: Para filtrar.
    En el FROM: Como si fuera una "tabla temporal".
    En el SELECT: Para traer un valor único calculado.
*/

-- Subconsulta en WHERE
SELECT nombre, salario
FROM empleados
WHERE salario >
(
    SELECT AVG(salario)
    FROM empleados
); -- Calcula promedio salarial, luego muestra empleados mayores al promedio.

-- Subconsulta en SELECT
SELECT nombre,
       salario,
       (SELECT AVG(salario) FROM empleados) AS promedio_empresa
FROM empleados;

-- Subconsulta en FROM
SELECT *
FROM
(
    SELECT id_departamento,
           AVG(salario) AS promedio
    FROM empleados
    GROUP BY id_departamento
) t
WHERE promedio > 2000;

-- Subconsulta en WHERE + SELECT + FROM al mismo tiempo
SELECT t.departamento,
       t.promedio,
       (SELECT MAX(salario) FROM empleados) AS salario_maximo
FROM
(
    SELECT id_departamento AS departamento,
           AVG(salario) AS promedio
    FROM empleados
    GROUP BY id_departamento
) t
WHERE t.promedio >
(
    SELECT AVG(salario)
    FROM empleados
);

-- Subconsultas de diferentes tablas
SELECT nombre
FROM empleados
WHERE id_departamento IN (
    SELECT id
    FROM departamentos
    WHERE ciudad = 'Puebla'
);

SELECT nombre
FROM empleados
WHERE salario >
(
   SELECT AVG(e.salario)
   FROM empleados e
   JOIN departamentos d
   ON e.id_departamento = d.id
   WHERE d.nombre = 'IT'
);

SELECT nombre
FROM empleados e1
WHERE salario >
(
   SELECT AVG(salario)
   FROM empleados e2
   WHERE e2.id_departamento = e1.id_departamento
);

SELECT nombre, precio
FROM productos
WHERE precio < (
    SELECT AVG(precio)
    FROM productos
);

SELECT c.id, c.nombre
FROM clientes c
WHERE c.id IN(
    SELECT p.id_cliente
    FROM pedidos p
    WHERE categoria = 'Electrónica'
)

SELECT *
FROM pedidos
WHERE fecha = (
    SELECT MAX(fecha)
    FROM pedidos
)
LIMIT 1; -- dependiendo el resultado

SELECT c.nombre, COALESCE(p.monto, 0) AS monto
FROM clientes c
LEFT JOIN pedidos p
ON c.id = p.id_cliente

SELECT d.id, d.nombre, COUNT(e.id) AS cantidad_empleados
FROM departamentos d
INNER JOIN empleados e
ON d.id = e.id_departamento
GROUP BY d.id, d.nombre
HAVING COUNT(e.id) >
(
    SELECT AVG(cantidad)
    FROM (    
        SELECT COUNT(*) AS cantidad
        FROM empleados
        GROUP BY id_departamento) primera
);

-- Tema 3: CASE WHEN (El motor de Feature Engineering)
/*
es el equivalente al if-elif-else de cualquier lenguaje de programación, pero adaptado a bases de datos.

El motor evalúa de arriba hacia abajo. 
En el momento en que una condición se cumple (es TRUE), asigna el valor y ignora el resto de los WHEN para esa fila. 
Pon siempre las condiciones más restrictivas primero.

Si no escribes la cláusula ELSE y una fila no cumple ninguno de tus WHEN, la base de datos pondrá un NULL automáticamente
*/
SELECT 
    nombre,
    edad,
    CASE 
        WHEN edad < 18 THEN 'Menor de Edad'
        WHEN edad BETWEEN 18 AND 60 THEN 'Adulto'
        ELSE 'Tercera Edad'
    END AS categoria_edad
FROM usuarios;

-- Feature Engineering: Variables Dummy (One-Hot Encoding manual)
SELECT 
    id_cliente,
    pais,
    CASE WHEN pais = 'Mexico' THEN 1 ELSE 0 END AS is_mexico,
    CASE WHEN pais = 'Colombia' THEN 1 ELSE 0 END AS is_colombia
FROM clientes;

-- CASE dentro de Funciones de Agregación
SELECT 
    departamento,
    SUM(CASE WHEN genero = 'F' THEN 1 ELSE 0 END) AS total_mujeres,
    SUM(CASE WHEN genero = 'M' THEN 1 ELSE 0 END) AS total_hombres
FROM empleados
GROUP BY departamento;

SELECT nombre, precio,
    CASE 
        WHEN precio < 500 THEN 'Económico'
        WHEN precio BETWEEN 500 AND 1500 THEN 'Estándar'
        ELSE 'Premium'
    END AS rango_precio
FROM productos

SELECT
    CASE
        WHEN estatus IN ('Activo', 'A') THEN 'ACTIVO'
        ELSE 'INACTIVO'
    END AS estatus_limpio
FROM clientes

SELECT
    SUM(CASE WHEN metodo_pago = 'Tarjeta' THEN 1 ELSE 0 END) AS total_tarjeta,
    SUM(CASE WHEN metodo_pago = 'Efectivo' THEN 1 ELSE 0 END) AS total_efectivo
FROM pedidos

SELECT e.id, e.nombre,
    CASE
        WHEN SUM(v.monto) IS NULL THEN 'Sin Ventas'
        WHEN SUM(v.monto) < 5000 THEN 'Junior'
        WHEN SUM(v.monto) >= 5000 THEN 'Senior'
        ELSE 'Sin Ventas'
    END AS nivel_ventas
FROM empleados e
LEFT JOIN ventas v
ON e.id = v.id_empleado
GROUP BY e.id, e.nombre

-- Tema 4: Funciones Matemáticas de Precisión (ROUND, CEIL, FLOOR)
-- Aplica ROUND(), CEIL() o FLOOR() únicamente en la cláusula SELECT final.

-- 1. ROUND(número, decimales): El Redondeo Estándar
/*
Redondea al más cercano (hacia arriba si es .5 o más)
Regla: Si omites el segundo parámetro, redondea a enteros (cero decimales).
*/

ROUND(149.49) -- 149
ROUND(149.50) -- 150
ROUND(149.456, 2) -- 149.46

-- 2. CEIL(número) / CEILING(): El Techo
/*
Fuerza el número al entero superior más cercano, sin importar qué tan pequeño sea el decimal.
*/
CEIL(2.1) -- 3
CEIL(2.9) -- 3

SELECT CEIL(AVG(Salary) - AVG(CAST(REPLACE(Salary, '0', '') AS DECIMAL)))
FROM EMPLOYEES 

-- 3. FLOOR(número): El Piso
/*
Fuerza el número al entero inferior más cercano, truncando (cortando) todos los decimales.
*/
FLOOR(15.8) -- 15
FLOOR(15.1) -- 15

SELECT FLOOR(AVG(POPULATION))
FROM CITY;

SELECT nombre, ROUND(precio * 1.16, 2) AS precio_final
FROM productos;

SELECT id_envio, CEIL(unidades_totales / 12.0)
FROM envios;

SELECT nombre, FLOOR(meses_antiguedad / 12.0)
FROM empleados;

SELECT ROUND(45.5), CEIL(45.5), FLOOR(45.5);

-- Tema 5: El Misterio de los Conteos (COUNT(*), COUNT(1), COUNT(columna))





-- ejercicios tema actual




-- futuros temas
explica mejor esto:
El "Single Row" Error: Si tu subconsulta en el WHERE usa un operador como =, >, < (comparación simple), la subconsulta DEBE devolver un solo valor. Si la subconsulta devuelve 10 filas, el query principal se romperá con un error: "Subquery returned more than 1 value".
TRY_CAST
Solución: Si esperas varios valores, usa el operador IN.
right y left para obtener caracteres
aprender WHERE MOD(ID, 2) = 0
FULL OUTER JOIN y CROSS JOIN (casos de uso específicos).

Explícame cómo hacer más simple con HAVING, JOIN, o ventana

Este nivel es el que te diferenciará en las entrevistas técnicas de alto nivel.
UNION ALL
Funciones de Ventana (Window Functions) — Indispensable en 2026
subconsultas
Aprender a usar OVER y PARTITION BY.
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
