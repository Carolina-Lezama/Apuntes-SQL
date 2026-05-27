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

*/

-- ejercicios del tema actual






































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
