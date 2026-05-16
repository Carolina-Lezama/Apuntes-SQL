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
/*
Agrega y compara sin colapsar las filas
las funciones de ventana más potentes para Series de Tiempo y Feature Engineering: LAG() y LEAD().
*/

-- anatomía completa de una función de ventana
FUNCIÓN() OVER (
    PARTITION BY columna_agrupacion -- 1. Crea los "muros" o subgrupos
    ORDER BY columna_ordenamiento   -- 2. Define el orden interno de la ventana
    [Cláusula de Marco]             -- 3. Opcional: Define límites móviles (Rolling)
)

/*
LAG() y LEAD() (Desplazamientos)
Con LAG y LEAD, puedes "mirar" hacia atrás o hacia adelante en la misma columna.

Para que LAG y LEAD o un ROW_NUMBER funcionen de forma determinista (que den exactamente el mismo resultado cada vez que ejecutes el query):
el ORDER BY de tu ventana debe ser único.

Acostúmbrate a usar un criterio de desempate en la ventana, como:
ORDER BY fecha_pedido ASC, id_pedido ASC
*/

/*
LAG(columna, desfase, valor_por_defecto): Mirar hacia atrás
Trae el valor de la fila anterior (o $N$ filas atrás) dentro de tu partición.
El tercer parámetro 0 le dice que si no hay fila anterior, ponga un cero en lugar de NULL
*/
SELECT 
    id_vendedor,
    mes,
    ventas_actuales,
    -- Miramos 1 fila hacia atrás para traer las ventas del mes pasado
    LAG(ventas_actuales, 1, 0) OVER(PARTITION BY id_vendedor ORDER BY mes ASC) AS ventas_mes_anterior
FROM ventas_mensuales;

/*
LEAD(columna, desfase, valor_por_defecto): Mirar hacia adelante
Trae el valor de la fila siguiente dentro de tu partición.
*/
SELECT 
    id_cliente,
    fecha_pedido AS fecha_actual,
    LEAD(fecha_pedido, 1) OVER(PARTITION BY id_cliente ORDER BY fecha_pedido ASC) AS proximo_pedido
FROM pedidos;

/*
solo el ORDER BY es estrictamente obligatorio. El PARTITION BY es totalmente opcional.
Para funciones como LAG() (fila anterior) y LEAD() (fila siguiente), el concepto de "anterior" y "siguiente" no existe a menos que los datos estén formados en una fila.

Si NO usas PARTITION BY: SQL simplemente trata a toda la tabla como un solo grupo gigante.
*/

SELECT 
    fecha,
    ventas_totales,
    LAG(ventas_totales) OVER(ORDER BY fecha ASC) AS ventas_dia_anterior
FROM resumen_diario;

SELECT 
    id_vendedor,
    mes,
    ventas_totales,
    LAG(ventas_totales) OVER(PARTITION BY id_vendedor ORDER BY mes ASC) AS ventas_mes_anterior
FROM resumen_vendedores;

SELECT 
    id_usuario,
    fecha_login,
    LAG(fecha_login) OVER(PARTITION BY id_usuario ORDER BY fecha_login ASC) AS login_anterior
FROM inicios_sesion
-- Si pones 1, miras el inicio de sesión inmediatamente anterior, 1 por defecto

WITH cte_creado AS (
    SELECT 
        tienda,
        mes,
        ventas_actuales,
        LAG(ventas_actuales, 1, 0) OVER(PARTITION BY tienda ORDER BY MES ASC) AS ventas_pasadas
    FROM
        empresa
);
SELECT 
    tienda,
    mes,
    ventas_actuales,
    ventas_pasadas,
    ((ventas_actuales - ventas_pasadas) / NULLIF(ventas_pasadas, 0)) * 100 AS crecimiento -- dividir entre NULL da NULL (en lugar de error), tu consulta sobrevive
FROM cte_creado;

SELECT 
    id_camion,
    ciudad_actual,
    orden_parada,
    LEAD(ciudad_actual, 1) OVER(PARTITION BY id_camion ORDER BY orden_parada ASC) AS proxima_ciudad
FROM entregas;

SELECT
    nombre,
    clase,
    promedio,
    MAX(promedio) OVER(PARTITION BY clase ) AS maxima_calificacion
FROM estudiantes;

-- Tema 3: Funciones de Fecha y Tiempo (Series Temporales)

-- ejercicios del tema actual

-- futuros temas




subconsultas
JOINS
Función ventana.
Subconsultas y Modularización
CTEs (Common Table Expressions): Aprender a usar WITH. Es mucho más limpio y profesional que las subconsultas anidadas.
Manipulación de Tipos de Datos

Funciones de String: CONCAT(), SUBSTR(), COALESCE() (para manejar nulos).