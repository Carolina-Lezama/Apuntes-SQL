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

SELECT
    fecha,
    cantidad,
    SUM(cantidad) OVER(ORDER BY fecha ASC) AS inventario_actual 
FROM movimientos_almacen;

SELECT
    fecha,
    num_visitas,
    AVG(num_visitas) OVER(ORDER BY fecha ASC
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS promedio_7_dias
FROM visitas_diarias;

/*
Se usa ASC (Ascendente) porque un Promedio Móvil necesita viajar en la misma dirección que el flujo del tiempo (del pasado hacia el presente).
Si usaras DESC estarías calculando el promedio de ventas usando datos que, en la vida real, ¡aún no habían ocurrido!
*/

SELECT
id_jugador,
score_total,
NTILE (10) OVER(ORDER BY score_total DESC) AS niveles
FROM jugadores;

SELECT
id_vendedor,
mes,
ingresos,
    MAX(ingresos) OVER(PARTITION BY id_vendedor ORDER BY mes ASC
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS max_3_meses
FROM ventas;

-- En el estándar SQL, ningún nombre de columna o alias puede empezar con un número.

-- Tema 2: PIVOT y Agregación Condicional (De Filas a Columnas)

-- Convertir filas en columnas se conoce como Pivoteo (Pivoting).
/*
El Método Universal: Agregación Condicional
Consiste en combinar GROUP BY con funciones de agregación (SUM, COUNT, MAX) y la sentencia CASE WHEN en su interior.

El GROUP BY colapsa todos los registros de un mismo mes en una sola fila.
SQL solo suma el monto si la categoría coincide con la columna que estamos construyendo; de lo contrario, suma 0 (lo que no afecta el total).
*/

SELECT 
    mes,
    -- Creamos la columna para Electrónica
    SUM(CASE WHEN categoria = 'Electrónica' THEN monto ELSE 0 END) AS total_electronica,
    -- Creamos la columna para Ropa
    SUM(CASE WHEN categoria = 'Ropa' THEN monto ELSE 0 END) AS total_ropa,
    -- Creamos la columna para Alimentos
    SUM(CASE WHEN categoria = 'Alimentos' THEN monto ELSE 0 END) AS total_alimentos
FROM ventas
GROUP BY mes;

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

/*
La Cláusula Nativa PIVOT (Específica de algunos motores)
requiere que primero aísles exactamente las columnas que vas a usar (usualmente mediante un CTE o subconsulta).
*/

-- Sintaxis en SQL Server / Snowflake
SELECT mes, [Electrónica], [Ropa], [Alimentos]
FROM (
    -- 1. Los datos crudos que vamos a usar
    SELECT mes, categoria, monto 
    FROM ventas
) AS datos_origen
PIVOT (
    -- 2. La función de agregación y las columnas que queremos crear
    SUM(monto) FOR categoria IN ([Electrónica], [Ropa], [Alimentos])
) AS tabla_pivote;

/*
Tanto en la Agregación Condicional como en el operador PIVOT, tienes que codificar las columnas a mano (Hardcoding).}
En SQL puro no se puede hacer un pivot dinámico (que cree las columnas automáticamente según los datos) sin usar SQL Dinámico (escribir un script que concatena strings de texto y los ejecuta como código)

SQL Dinámico es lento y peligroso por posibles inyecciones SQL.

¿Qué pasa si solo usas algunas filas y dejas otras fuera? ¿Marca error?
La respuesta es un rotundo NO
las filas que no incluiste en tus CASE WHEN simplemente serán ignoradas y desaparecerán de tu resultado final.
*/

-- La funcion de agregacion es obligatoria en un pivot
-- Si usas un GROUP BY, cualquier columna en tu SELECT que no esté en el GROUP BY tiene que estar envuelta en una función matemática

-- case when puede estar sin ella si solo es una condicional

SELECT 
    nombre_cliente,
    edad,
    -- Evalúa fila por fila, sin agrupar nada
    CASE 
        WHEN edad < 18 THEN 'Menor de edad'
        WHEN edad BETWEEN 18 AND 65 THEN 'Adulto'
        ELSE 'Tercera edad' 
    END AS categoria_edad
FROM clientes;

SELECT 
id_vendedor,
SUM(CASE WHEN estatus_pedido = 'Entregado' THEN 1 ELSE 0 END) AS total_e,
SUM(CASE WHEN estatus_pedido = 'Cancelado' THEN 1 ELSE 0 END) AS total_c,
SUM(CASE WHEN estatus_pedido = 'Pendiente' THEN 1 ELSE 0 END) AS total_p
FROM pedidos
GROUP BY id_vendedor;

SELECT
departamento,
AVG(CASE WHEN genero = 'F' THEN salario ELSE NULL END) AS promedio_F,
AVG(CASE WHEN genero = 'M' THEN salario ELSE NULL END) AS promedio_M
FROM empleados
GROUP BY departamento;
-- no debes usar 0, debes usar NULL para no arruinar el promedio matemático

SELECT 
id_cliente,
SUM(CASE WHEN trimestre = 'Q1' THEN total_facturado ELSE 0 END) AS trimestre_1,
SUM(CASE WHEN trimestre = 'Q2' THEN total_facturado ELSE 0 END) AS trimestre_2,
SUM(CASE WHEN trimestre = 'Q3' THEN total_facturado ELSE 0 END) AS trimestre_3,
SUM(CASE WHEN trimestre = 'Q4' THEN total_facturado ELSE 0 END) AS trimestre_4
FROM facturacion
GROUP BY id_cliente;

-- Tema 3: CTEs Recursivos (WITH RECURSIVE)
/*
Un CTE Recursivo es un bucle (loop) dentro de SQL que genera datos de la nada o recorre jerarquías profundas llamándose a sí mismo repetidamente hasta que se cumple una condición de salida.

Anatomía de la Recursividad
1. El punto de partida. La fila número 1.
2. El query que hace referencia al propio nombre del CTE para generar la siguiente fila basándose en la anterior.
3. Un filtro WHERE en el miembro recursivo para evitar que el bucle sea infinito.

Todas unidas obligatoriamente por un UNION ALL.
*/

-- Generar Series (Dimensión de Tiempo)
-- Generar los números del 1 al 5
WITH RECURSIVE Numeros AS (
    SELECT 1 AS contador -- Empezamos con el número 1
    UNION ALL
    SELECT contador + 1  -- Le sumamos 1 al número anterior
    FROM Numeros 
    WHERE contador < 5 -- condicional para terminar el ciclo
)
SELECT * FROM Numeros;

/*
Cuando usas UNION o UNION ALL para pegar dos resultados uno debajo del otro, ambas consultas deben tener exactamente la misma cantidad de columnas.
Si olvidas escribir correctamente la condición del WHERE en el miembro recursivo, consumira RAM hasta tumbar todo
*/

-- Navegar Jerarquías (Árboles Organizacionales)
WITH RECURSIVE Jerarquia AS (
    -- Encontrar al CEO (el que no tiene jefe)
    SELECT id_empleado, nombre, 1 AS nivel, 'Sin Jefe' AS nombre_jefe -- Estás inventando una columna nueva y otorgando un valor
    FROM empleados
    WHERE id_jefe IS NULL
    UNION ALL
    -- Unir a los subordinados con sus jefes
    SELECT e.id_empleado, e.nombre, j.nivel + 1, j.nombre AS nombre_jefe
    FROM empleados e
    INNER JOIN Jerarquia j ON e.id_jefe = j.id_empleado
)
SELECT * FROM Jerarquia ORDER BY nivel;

WITH RECURSIVE CuentaAtras AS (
    SELECT 10 AS numero
    UNION ALL
    SELECT numero - 1
    FROM CuentaAtras
    WHERE numero > 0
)
SELECT * FROM CuentaAtras;

WITH RECURSIVE Inversion AS (
    SELECT
    1 AS mes,
    1000 AS capital
    UNION ALL
    SELECT 
    mes + 1,
    capital * 1.05
    FROM Inversion
    WHERE mes < 7 -- para que muestre el mes 6
)

WITH RECURSIVE Calendario AS (
    SELECT '2026-06-01'::DATE AS fecha_dia
    UNION ALL
    SELECT fecha_dia + INTERVAL '1 day'
    FROM Calendario
    WHERE fecha_dia < '2026-07-01'::DATE
)
SELECT * FROM Calendario;

/*
En SQL, el WHERE de un CTE recursivo no significa "detente cuando esto pase" (Until). 
Significa "continúa MIENTRAS esto sea verdad" (While).
*/

-- Tema 4: Funciones de String y Manejo de Nulos

/*
CONCAT(): Uniendo cadenas de texto
    Sintaxis: CONCAT(columna1, ' ', columna2)

El Estándar ANSI (||): En motores como PostgreSQL, el operador oficial es la doble barra vertical.
*/

SELECT nombre || ' ' || apellido AS nombre_completo FROM usuarios;
SELECT CONCAT(nombre, ' ', apellido) AS nombre_completo FROM usuarios;

/*
SUBSTR() o SUBSTRING(): Extrayendo fragmentos
    Sintaxis: SUBSTR(columna, posicion_inicio, cantidad_caracteres)
En SQL, los índices de texto empiezan en 1
*/

-- Extrae los primeros 3 caracteres del teléfono (ej. '555-1234' -> '555')
SELECT SUBSTR(telefono, 1, 3) AS codigo_area FROM contactos;

/*
Evalúa una lista de valores y devuelve el PRIMERO que no sea NULL.
Es el estándar absoluto para la imputación de datos.
    Sintaxis: COALESCE(opcion1, opcion2, opcion3, ...)
*/
-- Si el cliente no tiene celular, muestra el teléfono fijo. Si tampoco tiene, muestra 'Sin contacto'.
SELECT COALESCE(celular, telefono_fijo, 'Sin contacto') AS medio_contacto 
FROM clientes;

/*
CONCAT y el Veneno del NULL
En SQL, si intentas concatenar un texto con un NULL usando ||, el resultado entero se convierte en NULL.
    ('Hola ' || NULL)
Perderás toda la informacion
Para evitarlo, siempre envolver las columnas sospechosas con COALESCE antes de concatenar
    calle || ', ' || COALESCE(numero_interior, 'S/N')

La función CONCAT() en algunos motores ignora los nulos automáticamente
*/

-- ejercicios del tema actual

SELECT
    empresa || ' - ' || puesto AS titulo_tarjeta,
    COALESCE(notas_reclutador, 'Sin comentarios recientes') AS notas_limpias
FROM postulaciones;

SELECT
    SUBSTR(codigo_producto, 5, 4) AS numero_serie
FROM inventario;

SELECT
    UPPER(SUBSTR(nombre,1,1)) || SUBSTR(nombre, 2)
FROM candidatos;

-- Tema 5: El Plan de Ejecución (EXPLAIN y EXPLAIN ANALYZE)
/*
Se utiliza para analizar y optimizar el rendimiento de las consultas.
Se coloca antes de una sentencia (como SELECT, UPDATE o DELETE) para revelar el plan de ejecución, mostrando exactamente cómo el motor de la base de datos procesará la consulta antes de ejecutarla.

Al ejecutar esto, la consulta no trae los datos.
En su lugar, te devolverá una tabla(bloque de texto) con una serie de pasos que explican la ruta que utilizará para encontrar la información.
*/

EXPLAIN SELECT * FROM clientes WHERE ciudad = 'Puebla';

EXPLAIN 
SELECT 
    nombre, 
    salario 
FROM empleados 
WHERE departamento = 'Ventas';

/*
EXPLAIN vs EXPLAIN ANALYZE

EXPLAIN a secas: Es una estimación teórica.
EXPLAIN ANALYZE: Ejecuta la consulta de verdad y te muestra el plan teórico comparado con el tiempo real.

Si usas EXPLAIN ANALYZE con un DELETE o un UPDATE, ¡la base de datos sí modificará los datos reales

Los planes de ejecución se leen como un árbol, normalmente de adentro hacia afuera (o de abajo hacia arriba).

En el output verás algo como (cost=0.00..15.35 rows=100).
El "costo" no son milisegundos. 
Es un número matemático abstracto que inventó la base de datos midiendo el esfuerzo de CPU y las lecturas de disco.

El motor siempre elegirá el plan que tenga el costo total más bajo.
*/

/*
Cómo leer un Plan

Seq Scan (Sequential Scan / Table Scan)
    Significa que el motor tuvo que leer el disco duro fila por fila, buscando coincidencias.
    Si ves esto en una tabla gigante para buscar a un solo usuario, te falta un índice.

Index Scan
    El motor usó el árbol del índice (UNIQUE INDEX o PRIMARY KEY). 
    Fue directo a la página exacta del disco donde estaba el dato. Es instantáneo.

Hash Join 
    Toma la tabla más pequeña, crea un "diccionario" temporal en la memoria RAM, y luego pasa la tabla grande comparándola contra ese diccionario.
    Eficiente para datos masivos.

El motor toma la tabla más pequeña (clientes con 10,000 filas) para construir el "diccionario Hash" porque cabe perfectamente en la memoria RAM.
Una vez construido, pasa la tabla masiva (historial_clicks de 50 millones) como un flujo rápido de datos contra ese diccionario.
Si el motor intentara hacerlo al revés, colapsaría la memoria del servidor (un error catastrófico conocido como Out Of Memory o OOM).

Nested Loop
    Hace un bucle for anidado. Toma la primera fila de la Tabla A, y la busca en toda la Tabla B. 
    Eficiente solo para tablas pequeñas.
*/

-- Tema 6: El Nivel Final de Tipos de Datos: JSON y Arrays

-- futuros temas







Fase 4:  MLOps (Nivel Experto)
Pensando en tu interés por despliegue y eficiencia.
¿te gustaría que nuestro siguiente paso sea adentrarnos en la optimización pura (creación y tipos de Índices) o prefieres aprender sobre programación procedural en SQL (Variables, Ciclos y Procedimientos Almacenados)?
Rendimiento y Plan de Ejecución

Entender qué es un Índice y cómo acelera las consultas.


Estructuras de Persistencia

CREATE TABLE AS (CTAS) para guardar resultados intermedios.

Diferencia entre Tablas Temporales y Vistas.