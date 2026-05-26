-- Tema 1: Funciones de Ventana Avanzadas (Framing y NTILE)
/*
1. El Marco de la Ventana (La Cláusula ROWS BETWEEN)
OVER(PARTITION BY...), opera sobre toda la partición al mismo tiempo.
Pero en el análisis de series de tiempo, a veces no quieres mirar toda la historia, sino solo una "ventana móvil" (un marco que avanza fila por fila).
*/

/*
A) El Acumulado Histórico (Running Total)
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
La Suma Normal (La que colapsa filas)
SELECT SUM(ventas_del_dia) FROM tabla; (sin el OVER), SQL actúa como una aplanadora.
Agarra todas las ventas, las suma, colapsa toda la tabla y efectivamente te devuelve 1 sola fila con el gran total.


La Función de Ventana (OVER)
No aplanes mi tabla. Mantén todas mis filas intactas, pero pégales una columna extra al lado con este cálculo
*/

-- ejercicios del tema actual






































-- futuros temas



CTEs (Common Table Expressions): Aprender a usar WITH. Es mucho más limpio y profesional que las subconsultas anidadas.
Manipulación de Tipos de Datos
Funciones de String: CONCAT(), SUBSTR(), COALESCE() (para manejar nulos).

/*

*/
