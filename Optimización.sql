-- Tema 1: El Operador Módulo (MOD) - Filtrado por Residuos
/*
el módulo es una operación que devuelve el residuo (o resto) de una división entre dos números
*/

-- Filtrar únicamente las filas con ID PAR
SELECT * FROM usuarios WHERE MOD(id, 2) = 0;
-- Filtrar únicamente las filas con ID IMPAR
SELECT * FROM usuarios WHERE MOD(id, 2) = 1;

-- Otra posible sintaxis en otros motores:
SELECT * FROM usuarios WHERE id_cliente % 2 = 0

-- necesitas extraer una muestra rápida del 10% sin saturar tu memoria RAM
SELECT * FROM transacciones WHERE MOD(id_transaccion, 10) = 0;

-- Si tienes que ejecutar un proceso pesado de actualización sobre millones de usuarios, puedes dividir el trabajo en "hilos" independientes para que termine más rápido
WHERE MOD(id, 3) = 0 -- El Script 1 
WHERE MOD(id, 3) = 1 -- El Script 2
WHERE MOD(id, 3) = 2 --El Script 3

/*
Aplicar MOD(id, 2) = 0 en el WHERE sufre del mismo mal que las funciones de texto: invalida la búsqueda directa en el índice.
el motor de la base de datos se ve obligado a tomar fila por fila, hacer la división matemáticamente en el procesador y evaluar el resultado.
*/

SELECT id_pedido, fecha, total
FROM pedidos
WHERE MOD(id_pedido, 2) = 1;

SELECT *
FROM lecturas_iot
WHERE MOD(id_lectura, 5) = 0;

SELECT id_cliente,
    CASE
        WHEN MOD(id_cliente,2) = 0 THEN 'Grupo A'
        ELSE 'Grupo B'
        END AS grupo_experimental
FROM clientes


SELECT id_vendedor, SUM(TRY_CAST(monto AS INT)) AS total_vendido
FROM facturas
WHERE MOD(id_factura, 2) = 0 AND TRY_CAST(monto AS INT) IS NOT NULL
GROUP BY id_vendedor;

-- Tema 2: Repaso Magistral: Funciones de Ventana (Window Functions)

-- ejercicios del tema actual


-- futuros temas




subconsultas
JOINS
LAG() y LEAD() (Fundamentales para análisis de series temporales, como lo que hiciste con los taxis).
Función ventana.
Subconsultas y Modularización
CTEs (Common Table Expressions): Aprender a usar WITH. Es mucho más limpio y profesional que las subconsultas anidadas.
Manipulación de Tipos de Datos
Funciones de Fecha: DATE_TRUNC(), EXTRACT(), DATEDIFF().
Funciones de String: CONCAT(), SUBSTR(), COALESCE() (para manejar nulos).