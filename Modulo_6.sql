-- Tema 1: Funciones de Ventana Avanzadas (Framing y NTILE)
/*
1. El Marco de la Ventana (La Cláusula ROWS BETWEEN)
OVER(PARTITION BY...), opera sobre toda la partición al mismo tiempo.
Pero en el análisis de series de tiempo, a veces no quieres mirar toda la historia, sino solo una "ventana móvil" (un marco que avanza fila por fila).
*/

/*
El Acumulado Histórico (Running Total)
    Si omites la partición y solo pones ORDER BY, SQL asume automáticamente un marco que va "desde el principio de los tiempos hasta la fila actual"
    Esto sirve para sumar ventas acumuladas día a día.
    No, no te devuelve una sola fila. ¡Te devuelve exactamente el mismo número de filas que tiene tu tabla original
*/

SELECT 
    fecha, 
    ventas_del_dia,
    SUM(ventas_del_dia) OVER(ORDER BY fecha ASC) AS total_acumulado
FROM reporte_ventas;

/*
Ejemplo
fecha       ventas_del_dia total_acumulado 
2026-05-01  10             10
2026-05-02  20             30
2026-05-03  5              35
2026-05-04  15             50
*/

/*
La Suma Normal (La que colapsa filas)
SELECT SUM(ventas_del_dia) FROM tabla; (sin el OVER), SQL actúa como una aplanadora.
Agarra todas las ventas, las suma, colapsa toda la tabla y efectivamente te devuelve 1 sola fila con el gran total.

La Función de Ventana (OVER)
No aplanes mi tabla. Mantén todas mis filas intactas, pero pégales una columna extra al lado con este cálculo

El efecto del ORDER BY (El Total Acumulado)
Le estás diciendo a SQL que no solo mantenga las filas, sino que vaya sumando renglón por renglón cronológicamente. 
Esto crea lo que en finanzas se llama un Running Total (Suma Acumulada)
*/

/*
El Promedio Móvil (Moving Average)
Es una técnica que se usa para "suavizar" una línea de tendencia, eliminando el "ruido" de las subidas y bajadas extremas del día a día, para que puedas ver hacia dónde va realmente el negocio.

Para entender la tendencia real, calculas un Promedio Móvil de 3 días. 
Esto significa que cada día vas a promediar las ventas de ese día y de los dos días anteriores.

    Para el Miércoles: Promedias Lunes(10) + Martes(15) + Miércoles(5) / 3 = 10
    Para el Jueves: Promedias Martes(15) + Miércoles(5) + Jueves(20) / 3 = 13.3
    Para el Viernes: Promedias Miércoles(5) + Jueves(20) + Viernes(40) / 3 = 21.6

¿Por qué es tan valioso?
Elimina anomalías (Ruido)
Identifica tendencias reales

    UNBOUNDED PRECEDING: Desde la primera fila de la partición.
    [N] PRECEDING: N filas hacia atrás.
    CURRENT ROW: La fila actual.
    [N] FOLLOWING: N filas hacia adelante.
*/

SELECT 
    fecha, 
    ventas_del_dia,
    AVG(ventas_del_dia) OVER(
        ORDER BY fecha ASC 
        -- El marco: "Desde 2 filas atrás hasta la fila actual" (Total 3 filas)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS promedio_movil_3dias
FROM reporte_ventas;

/*
Si pones un ORDER BY dentro de una ventana, SQL SIEMPRE aplica un marco (ROWS/RANGE), aunque tú no lo escribas.

ROWS es FÍSICO: Cuenta renglones literales, sin importarle qué datos hay adentro. Es ciego a los empates.
RANGE es LÓGICO: Se fija en los valores de la columna de tu ORDER BY. Si encuentra valores repetidos (empates), los agrupa y los procesa al mismo tiempo.

Rows puede devolver varias filas para el resultado de un mismo dia, las suma pero las toma como independientes.
range encuentra empates y las suma, esto se le suma al original dando solo una fila por dia, no por venta como rows, pero se mostrara 2 veces

ROWS
fecha      venta Total_con_ROWS ¿Qué pensó el motor?
2026-05-01 10    10             """Fila 1. Llevo 10."""
2026-05-02 20    30             """Fila 2. Llevo 10 + los 20 de aquí = 30."""
2026-05-02 30    60             """Fila 3. Llevo 30 + los 30 de aquí = 60."""
2026-05-03 10    70             """Fila 4. Llevo 60 + los 10 de aquí = 70."""

RANGE
fecha      venta Total_con_RANGE ¿Qué pensó el motor?
2026-05-01 10    10              """Día 1. Llevo 10."""
2026-05-02 20    60              """¡Espera! Hay dos transacciones hoy (20+30). Suman 50. Más los 10 de ayer = 60. Le pondré 60 a todo lo de este día."""
2026-05-02 30    60              """Sigue siendo Día 2. El total al final de este bloque lógico es 60."""
2026-05-03 10    70              """Día 3. Llevo 60 + 10 = 70."""

El problema de RANGE es que si hay fechas duplicadas (empates en el ORDER BY), tratará a todos los empates como si fueran una sola fila gigante, distorsionando tu promedio móvil.
*/

-- Esto:
SUM(ventas) OVER(ORDER BY fecha ASC)
-- Es igual a esto:
SUM(ventas) OVER(
    ORDER BY fecha ASC 
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)

/*
NTILE(n): Cuartiles y Deciles (Estadística Pura)
NTILE(n) divide tus datos ordenados en n "cubetas" o grupos lo más idénticos posible en tamaño, y le asigna un número a cada fila.
*/

SELECT 
    nombre_cliente, 
    total_gastado,
    -- Divide a los clientes en 4 grupos (1 es el que más gasta, 4 el que menos)
    NTILE(4) OVER(ORDER BY total_gastado DESC) AS cuartil
FROM clientes;


-- ejercicios del tema actual

SELECT
    fecha,
    cantidad,
    SUM(cantidad) OVER(ORDER BY fecha ASC) AS inventario_actual 
FROM movimientos_almacen;

SELECT
    fecha,
    num_visitas
    AVG(num_visitas) OVER(ORDER BY fecha ASC
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS 7_dias_promedio
FROM visitas_diarias;

/*
Se usa ASC (Ascendente) porque un Promedio Móvil necesita viajar en la misma dirección que el flujo del tiempo (del pasado hacia el presente).
Estarías calculando el promedio de ventas usando datos que, en la vida real, ¡aún no habían ocurrido!

*/

SELECT
FROM  ;

SELECT
FROM  ;


































-- futuros temas


pivot usar celdas como columnas, condicional de agregacion
/*
Enter your query here.
*/

WITH DatosNumerados AS (
    SELECT 
        Name,
        Occupation,
        ROW_NUMBER() OVER(PARTITION BY Occupation ORDER BY Name) AS fila
    FROM OCCUPATIONS 
)

SELECT 
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer, 
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor

FROM DatosNumerados
GROUP BY fila;


CTEs (Common Table Expressions): Aprender a usar WITH. Es mucho más limpio y profesional que las subconsultas anidadas.
Manipulación de Tipos de Datos
Funciones de String: CONCAT(), SUBSTR(), COALESCE() (para manejar nulos).

/*

*/
