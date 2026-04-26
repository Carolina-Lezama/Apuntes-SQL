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














-- ejercicios tema actual
SELECT nombre, precio
FROM productos
WHERE precio < (
    SELECT AVG(precio)
    FROM productos
)






-- futuros temas
explica mejor esto:
El "Single Row" Error: Si tu subconsulta en el WHERE usa un operador como =, >, < (comparación simple), la subconsulta DEBE devolver un solo valor. Si la subconsulta devuelve 10 filas, el query principal se romperá con un error: "Subquery returned more than 1 value".
TRY_CAST
Solución: Si esperas varios valores, usa el operador IN.
right y left para obtener caracteres

uso de FLOOR() Busca el entero menor más cercano.
CEIL() el siguiente entero superior.
ROUND() Redondea al más cercano (hacia arriba si es .5 o más).
aprender WHERE MOD(ID, 2) = 0
FULL OUTER JOIN y CROSS JOIN (casos de uso específicos).
Lógica Condicional
Aprender a usar CASE WHEN: Crear categorías o etiquetas sobre la marcha (útil para Feature Engineering).
COUNT(*), COUNT(1), COUNT(columna),

/*
*/
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
