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
-- El manejo de fechas es el área que más cambia dependiendo del motor de base de datos

/*
EXTRACT(): La Lupa de la Estacionalidad
Saca un dato específica de la fecha y te la devuelve como un número entero.

Sintaxis: EXTRACT(parte FROM columna_fecha)

Básicos de Fecha: YEAR, MONTH, DAY
Básicos de Tiempo: HOUR, MINUTE, SECOND
Avanzados: DOW (Day of Week), DOY (Day of Year), WEEK: El número de la semana del año, QUARTER: El trimestre (1 a 4)
*/
EXTRACT(MONTH FROM '2026-05-16') -- Devuelve 5

-- ¿Cómo se ve EXTRACT en una consulta completa? para crear una "nueva característica" (feature engineering)
SELECT 
    id_venta,
    fecha_transaccion,
    monto,
    EXTRACT(MONTH FROM fecha_transaccion) AS mes_venta,
    EXTRACT(YEAR FROM fecha_transaccion) AS anio_venta
FROM ventas
WHERE EXTRACT(YEAR FROM fecha_transaccion) = 2026;

/*
DATE_TRUNC(): El Redondeo Temporal
DATE_TRUNC "corta" o "redondea hacia abajo" la fecha, pero la mantiene como tipo Fecha. 
Pone todo lo demás en 01 o 00:00:00; e devuelve la fecha completa reseteada al primer día

Sintaxis: DATE_TRUNC('parte', columna_fecha)

'year'	    2026-01-01 00:00:00	Reportes anuales.
'quarter'	2026-04-01 00:00:00	Evaluaciones financieras (Q1, Q2, Q3, Q4).
'month'	    2026-05-01 00:00:00	El rey indiscutible.
'week'	    2026-05-18 00:00:00	Te manda al lunes de esa semana.
'day'	    2026-05-18 00:00:00	Elimina las horas y minutos.
'hour'	    2026-05-18 21:00:00	Deja la hora, elimina los minutos.
*/
DATE_TRUNC('month', '2026-05-16 14:30:00') -- Devuelve 2026-05-01 00:00:00

-- Ejemplo de Consulta Completa
SELECT 
    DATE_TRUNC('month', fecha_registro) AS mes_cohorte,
    COUNT(id_usuario) AS total_nuevos_usuarios
FROM usuarios
WHERE fecha_registro >= '2025-01-01'
GROUP BY DATE_TRUNC('month', fecha_registro)
ORDER BY mes_cohorte ASC;

/*
3. DATEDIFF() / Resta de Fechas: Distancia en el Tiempo
Sirve para saber cuánto tiempo ha pasado entre el Punto A y el Punto B.
Esta función te devuelve un número entero (la cantidad de días, meses o años entre dos fechas)

ALERTA DE PRODUCCIÓN: La Trampa de los Husos Horarios (Timezones)

Nunca asumas que el servidor de la base de datos está en tu mismo país. 
Si el servidor está en UTC (Inglaterra) y tú en México, una venta hecha a las 10:00 PM del martes en México se registrará como las 4:00 AM del miércoles en la base de datos.
En bases de datos globales, siempre debes convertir la zona horaria antes de agrupar (ej. AT TIME ZONE

*/

DATEDIFF(parte, fecha_inicio, fecha_fin) --En SQL Server / MySQL
SELECT DATEDIFF(day, '2026-05-10', '2026-05-15'); -- Devuelve 5 (días)
-- primero la fecha final y luego la inicial

(fecha_fin - fecha_inicio te da el número de días) -- En PostgreSQL / BigQuery,a menudo puedes simplemente restar las fechas  o usar la función AGE().
-- no existe `DATEDIFF` por defecto. En su lugar, usas matemáticas simples.
SELECT '2026-05-15'::DATE - '2026-05-10'::DATE; -- Devuelve 5
SELECT '2026-05-15 12:30:00'::TIMESTAMP - '2026-05-10 02:00:00'::TIMESTAMP;

-- Usando `AGE()` (La joya de PostgreSQL)
-- En lugar de darte todo en días, te devuelve un intervalo en un formato súper legible para humanos: Años, meses y días.
SELECT AGE('2026-05-19', '1990-01-01'); 
-- Resultado: '36 years 4 mons 18 days'

-- Ejemplo de Consulta Completa
SELECT 
    id_pedido,
    fecha_compra,
    fecha_envio,
    -- 1. Resta simple: Días exactos que tardó la paquetería
    (fecha_envio::DATE - fecha_compra::DATE) AS dias_para_envio,
    -- 2. AGE: Tiempo exacto desde que el usuario creó su cuenta
    AGE(CURRENT_DATE, u.fecha_registro) AS antiguedad_cliente
FROM pedidos p
JOIN usuarios u ON p.id_usuario = u.id_usuario
WHERE fecha_envio IS NOT NULL;

/*
El dolor de cabeza global: Agrupar con AT TIME ZONE
Usar AT TIME ZONE para convertir la fecha del servidor a la hora local antes de truncarla o extraer el día.
Siempre, siempre haz la conversión de zona horaria por dentro, antes de aplicar cualquier EXTRACT o DATE_TRUNC.
*/

SELECT 
    -- 1. Tomamos la fecha del servidor (UTC)
    -- 2. La convertimos a la hora de México
    -- 3. La truncamos para agrupar por día
    DATE_TRUNC('day', fecha_compra AT TIME ZONE 'UTC' AT TIME ZONE 'America/Mexico_City') AS dia_venta_local,
    COUNT(id_pedido) AS total_pedidos,
    SUM(monto) AS ingresos_totales
FROM ventas
GROUP BY DATE_TRUNC('day', fecha_compra AT TIME ZONE 'UTC' AT TIME ZONE 'America/Mexico_City')
ORDER BY dia_venta_local DESC;

/*
Si agrupas una tabla por EXTRACT(MONTH FROM fecha), el resultado unirá las ventas de Mayo 2025 y Mayo 2026 en el mismo bloque (porque ambas son mes 5).

En cambio si agrupas por DATE_TRUNC('month', fecha)
el motor de SQL no saca un número aislado, sino que congela el año y el mes de ese momento específico en el tiempo y simplemente "reinicia" el día al número 1
    Un bloque para 2025-05-01 00:00:00 (donde se sumará todo lo de Mayo 2025).
    Otro bloque para 2026-05-01 00:00:00 (donde se sumará todo lo de Mayo 2026).

Usas DATE_TRUNC cuando quieres ver una línea de tiempo histórica
Usas EXTRACT(MONTH) cuando quieres analizar estacionalidad
*/

SELECT
    id_compra,
    EXTRACT(MONTH FROM fecha_transaccion) AS mes_transaccion,
    EXTRACT(YEAR FROM fecha_transaccion) AS año_transaccion
FROM compras;

SELECT 
    SUM(monto),
    DATE_TRUNC('month', fecha_transaccion) AS mes_ventas
FROM compras
GROUP BY DATE_TRUNC('month', fecha_transaccion);

SELECT
    nombre_usuario,
    fecha_cancelacion - fecha_registro AS dias_activo
FROM suscripciones
WHERE fecha_cancelacion IS NOT NULL;

SELECT
    FLOOR((fecha_dos - fecha_uno) / 31)
FROM tabla;

-- Tema 4: Pequeñas consultas o consulta monstruosa.
/*
sql se suele usar para features engineering, el estándar moderno favorece hacerlo en SQL (siempre que sea posible).
el motor de SQL (que está diseñado específicamente para eso) procese las fechas, extraiga los meses, días y semanas, y le entregue a Python una tabla ya limpia y con las columnas listas.

Si estás preparando la tabla definitiva que alimentará tu modelo o tu dashboard, el estándar es dejar esas columnas creadas en SQL.
Si estás explorando, experimentando o trabajando con archivos planos, lo haces en Python.
*/

/*
Divide y vencerás (usa el enfoque modular). Trata de no meter todo en tu consulta original.
crear consultas nuevas y unirlas al final.
los Científicos de Datos y Data Engineers usan CTEs (WITH). Construyes bloques separados y los unes al final con un JOIN.
*/

-- BLOQUE 1: Tu tabla maestra original (Datos básicos, 1 fila por usuario)
WITH tabla_maestra AS (
    SELECT 
        id_usuario, 
        nombre, 
        fecha_registro,
        pais
    FROM usuarios
),

-- BLOQUE 2: Los nuevos datos que quisiste agregar después (Ej. sus compras)
nuevas_metricas_compras AS (
    SELECT 
        id_usuario, 
        SUM(monto) AS total_gastado,
        COUNT(id_ticket) AS total_compras
    FROM ventas
    GROUP BY id_usuario
),

-- BLOQUE 3: Otro dato que se te ocurrió al final (Ej. última visita)
metrica_visitas AS (
    SELECT 
        id_usuario,
        MAX(fecha_login) AS ultimo_login
    FROM sesiones
    GROUP BY id_usuario
)

-- EL GRAN FINAL: Armas el rompecabezas uniendo todo a tu maestra
SELECT 
    tm.id_usuario,
    tm.nombre,
    tm.pais,
    c.total_gastado,
    v.ultimo_login
FROM tabla_maestra tm
LEFT JOIN nuevas_metricas_compras c ON tm.id_usuario = c.id_usuario
LEFT JOIN metrica_visitas v ON tm.id_usuario = v.id_usuario;

-- Tema 5: Modularización Avanzada (Vistas y Vistas Materializadas)
/*
Las Vistas Clásicas (CREATE VIEW)
Una vista es una consulta guardada en la base de datos que se comporta exactamente como si fuera una tabla física.
¿Qué hace?: Guarda la lógica (el código SQL), no los datos.
*/

CREATE VIEW vw_empleados_limpios AS
SELECT id_empleado, UPPER(nombre) AS nombre_limpio, salario
FROM empleados
WHERE estatus = 'ACTIVO';
SELECT * FROM vw_empleados_limpios;

/*
Vistas Materializadas (CREATE MATERIALIZED VIEW)
¿Qué hace?: Ejecuta la consulta pesada y guarda físicamente el resultado final en el disco duro.

Ventaja: Las consultas a esta vista tardan milisegundos, porque la matemática pesada ya se hizo y se guardó.
Desventaja (El Truco): Los datos son una "foto" de ese momento. Si se insertan ventas nuevas, la vista no las tiene hasta que tú ordenes actualizarla con: 
REFRESH MATERIALIZED VIEW nombre_vista;
*/

CREATE MATERIALIZED VIEW mv_reporte_ventas_mensual AS
SELECT DATE_TRUNC('month', fecha) AS mes, SUM(monto) AS total
FROM ventas_historicas
GROUP BY DATE_TRUNC('month', fecha);

-- Las vistas deben apuntar a tablas base, nunca a otras vistas.

/*
Optimizar el refrescado de vistas
Usar REFRESH MATERIALIZED VIEW mv_top_productos funciona, pero tiene un efecto secundario: bloquea la tabla completa.
Si la vista tarda 15 minutos en actualizarse, cualquier reporte o usuario que intente leerla durante ese tiempo se quedará congelado o marcará error.

Usa la palabra CONCURRENTLY.
el motor actualiza los datos en una copia "invisible" y, cuando termina, reemplace los datos en un milisegundo sin interrumpir a nadie.
Actualiza los datos en segundo plano, pero sigue mostrando los datos viejos a los usuarios hasta que termines, para no interrumpir el servicio
*/

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_top_productos;

/*
La sintaxis del horario (Expresión Cron)
el horario no se escribe en SQL, sino en un formato universal de 5 asteriscos llamado Cron Expression.
"todos los días a las 3:00 AM exactas", la sintaxis es: 0 3 * * *
*/

CREATE VIEW vw_clientes_marketing AS 
SELECT
    id_cliente, 
    nombre,
    email
FROM clientes
WHERE categoria = 'Grupo A';

SELECT COUNT(*)
FROM vw_clientes_marketing;

CREATE MATERIALIZED VIEW mv_top_productos AS
SELECT
    id_producto,
    SUM(ventas) AS ventas_totales
FROM ventas
GROUP BY id_producto
HAVING SUM(ventas) > 100000;

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_top_productos;

-- Tema 6: El Jefe Final de las Subconsultas: EXISTS y Subconsultas UPDATE/DELETE
/*
Las subconsultas SQL pueden colocarse en casi cualquier lugar donde se permita una expresión, principalmente en:
    SELECT, FROM, WHERE y HAVING
ya sea para filtrar resultados, calcular totales o crear tablas virtuales.

1. Cláusula WHERE
filtrar el resultado de la consulta principal basándose en los datos que devuelve la subconsulta.

2. Cláusula FROM (Tablas Derivadas)
la subconsulta actúa como una tabla temporal o "vista en línea". 
La consulta principal selecciona datos directamente de los resultados que arroja la subconsulta.

3. Cláusula SELECT
Insertar una subconsulta para que actúe como una columna calculada independiente para cada fila de la consulta principal.

4. Cláusula HAVING
Se utiliza exactamente igual que en la cláusula WHERE, pero se aplica específicamente después de haber agrupado los datos con GROUP BY.

5. Otras cláusulas (INSERT, UPDATE, DELETE)
Las subconsultas no son exclusivas de SELECT. También se pueden usar para modificar datos en bloque
*/

/*
1. El Rey del Rendimiento: EXISTS (vs. IN)
Cuando quieres saber si un cliente tiene pedidos, normalmente usas WHERE id_cliente IN (SELECT id_cliente FROM pedidos).
IN primero construye toda la lista temporal de la subconsulta en memoria y luego compara.
*/

-- ALTERNATIVA EXISTS:
SELECT nombre 
FROM clientes c
WHERE EXISTS (
    SELECT 1 
    FROM pedidos p 
    WHERE c.id_cliente = p.id_cliente
);

/*
En el momento en que encuentra un solo pedido para ese cliente, detiene la búsqueda y devuelve TRUE. No le importa si el cliente tiene 1 pedido o 10,000.
Como a EXISTS solo le importa si la fila existe o no, no necesitamos traer ninguna columna real, poner 1 es el estándar de la industria.
*/

/*
2. NOT EXISTS: El Auditor de Datos
Es la forma más segura y rápida de encontrar registros "huérfanos", evitando la trampa de los NULLs que tiene NOT IN
*/ 

-- "Dame los clientes que NO han comprado nada"
SELECT nombre 
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos p WHERE c.id_cliente = p.id_cliente
);

/*
3. Subconsultas destructivas: UPDATE y DELETE
actualizar una tabla usando reglas que viven en otra tabla. 
Aquí, la subconsulta correlacionada es tu única opción estándar.
*/

UPDATE clientes
SET estatus = 'VIP'
WHERE id_cliente IN (
    SELECT id_cliente 
    FROM ventas 
    GROUP BY id_cliente 
    HAVING SUM(monto) > 10000
);

-- El secreto para cambiar de IN a EXISTS es que necesitas crear un "puente" (una subconsulta correlacionada) que conecte la tabla de afuera (clientes) con la tabla de adentro (ventas).
UPDATE clientes
SET estatus = 'VIP'
WHERE EXISTS (
    SELECT 1 
    FROM ventas 
    WHERE ventas.id_cliente = clientes.id_cliente -- ¡Este es el puente!
    GROUP BY ventas.id_cliente 
    HAVING SUM(ventas.monto) > 10000
);

/*
ALERTA DE PRODUCCIÓN: El DELETE sin piedad
Al usar subconsultas en un DELETE, un error lógico borra millones de registros

Si la tabla pedidos está temporalmente vacía o la subconsulta devuelve un NULL, puedes vaciar tu tabla de clientes entera.
Siempre prueba tu subconsulta con un SELECT antes de cambiar la palabra por DELETE.
*/

-- Ejemplo con NOT IN 
DELETE FROM clientes WHERE id_cliente NOT IN (SELECT id_cliente FROM pedidos);

-- Ejemplo con IN
SELECT nombre_producto 
FROM productos 
WHERE id_producto IN 
    (SELECT id_producto FROM inventario WHERE cantidad > 0);

/*
Orden de colocacion de las tablas.
El orden influye, pudiendo cambiar por completo el resultado final de tu consulta.
la tabla que pones "afuera" (la consulta principal) y la que pones "adentro" (la subconsulta) tienen roles completamente diferentes.

    La tabla de AFUERA dicta QUÉ es lo que vas a devolver, actualizar o borrar.
    La tabla de ADENTRO es solo el FILTRO (la condición que debe cumplirse).

1. En un UPDATE o DELETE
Si quieres actualizar el estatus de algun campo en cierta tabla, la tabla tiene que estar afuera obligatoriamente.

2. En un SELECT (El impacto en los resultados)
Si solo estás consultando datos, el orden cambia drásticamente lo que ves en la pantalla.
*/

-- Escenario A: clientes afuera, ventas adentro (clientes que han comprado al menos una vez)
SELECT nombre_cliente 
FROM clientes 
WHERE EXISTS (
    SELECT 1 FROM ventas WHERE ventas.id_cliente = clientes.id_cliente
);

-- Escenario B: ventas afuera, clientes adentro (odas las ventas que pertenezcan a un cliente)
SELECT id_ticket, monto 
FROM ventas 
WHERE EXISTS (
    SELECT 1 FROM clientes WHERE clientes.id_cliente = ventas.id_cliente
);


SELECT p.nombre_producto 
FROM productos p
WHERE EXISTS (
    SELECT 1 
    FROM inventario i
    WHERE i.id_producto = p.id_producto 
    AND i.cantidad > 0
);

SELECT e.nombre
FROM empleados e
WHERE NOT EXISTS 
(
    SELECT 1
    FROM asignaciones_proyecto a
    WHERE e.id_empleado = a.id_empleado
);

UPDATE productos p --tabla a actualizar
SET precio = precio * 1.20 -- precio arriba un 20%
WHERE EXISTS (
    SELECT 1 
    FROM categorias c
    WHERE p.id_categoria = c.id_categoria AND c.nombre_categoria = 'Electrónica'
);

/*
El Misterio Lógico: ¿Qué pasa cuando el WHERE recibe un NULL o una tabla vacía?
En SQL existe algo llamado Lógica de Tres Valores (3VL).
    Verdadera (TRUE) 
    Falsa (FALSE)
    Desconocida (UNKNOWN) -- ocurre cuando involucras un NULL.

La cláusula WHERE deja pasar una fila ÚNICAMENTE si la condición se evalúa como estrictamente TRUE. 
Si la condición da FALSE o UNKNOWN, la fila se rechaza.

Escenario A: La subconsulta devuelve una tabla totalmente vacía.
    El motor se pregunta: "¿El usuario 1 está en esta lista vacía?"
    La respuesta lógica es: "No, no está". Por lo tanto, NOT IN (vacio) es estrictamente TRUE.
    El Desastre: Como es TRUE para todos, el DELETE borra a todos los usuarios de tu base de datos.

Escenario B: La subconsulta devuelve una lista con números, pero incluye un NULL (ej. 1, 2, NULL).
    El motor traduce el NOT IN a múltiples AND: id != 1 AND id != 2 AND id != NULL.
    Cuando evalúa id != NULL, el resultado es UNKNOWN (porque no puedes comparar nada contra lo desconocido).
    En lógica, TRUE AND TRUE AND UNKNOWN da como resultado final UNKNOWN.
    La Salvación Inesperada: Como el WHERE exige un TRUE estricto y recibió un UNKNOWN, rechaza la fila. No se borra absolutamente nada.
*/

DELETE FROM usuarios 
    WHERE id_usuario NOT IN (SELECT id_usuario FROM historial_compras);

-- Tema 7: Índices Únicos (UNIQUE INDEX)
/*
1. ¿Qué es un Índice en SQL?
Imagina un libro de texto de 1,000 páginas. Si te pido que busques la palabra "Algoritmo", tendrías que leer el libro entero página por página (en SQL, esto se llama Full Table Scan, y es lento).
Pero si el libro tiene un Índice al final, vas directamente a la "A", buscas la palabra, y el índice te dice exactamente: "Página 450".

En SQL, un Índice es una estructura de datos oculta (generalmente un Árbol-B) que guarda referencias rápidas a las filas físicas.
*/

/*
2. Cómo crear un índice normal (No Único)
Un índice normal (no único) sirve para decirle a la base de datos: "Voy a buscar información por esta columna muy seguido, por favor organízala como el índice de un libro para que la encuentres más rápido".

¿A qué columnas se les pone un índice normal?
    A las que usas mucho después del WHERE (ej. fechas, estatus, país).
    A las que usas para conectar tablas en los JOIN (las llaves foráneas).
    A las que usas frecuentemente en el ORDER BY.
*/

CREATE INDEX idx_estatus_cliente 
ON clientes (estatus); -- En qué tabla y a qué columna se lo vas a aplicar.

/*
3. ¿Qué es un Índice ÚNICO (UNIQUE INDEX)?
cumple dos funciones al mismo tiempo:
    - Acelera las búsquedas drásticamente.
    - Impone una regla de integridad (Constraint): Le prohíbe a la base de datos aceptar dos filas que tengan el mismo valor en esa columna.

Cuando creas una PRIMARY KEY, el motor de la base de datos crea un UNIQUE INDEX en esa columna automáticamente.
*/

-- Crear un índice único en una sola columna (Ej. Emails que no pueden repetirse)
CREATE UNIQUE INDEX nombre_del_indice 
ON nombre_tabla (nombre_columna);

-- Crear un índice único compuesto (Ej. Un usuario solo puede votar una vez por cada encuesta)
CREATE UNIQUE INDEX idx_votos_unicos 
ON votos (id_usuario, id_encuesta);

/*
Por qué CONCURRENTLY lo necesita (Requiere un índice ÚNICO)
Cuando le dices a la Vista Materializada que se actualice "en caliente" (sin bloquear a los usuarios)
el motor necesita comparar la "foto vieja" de los datos con la "foto nueva" para saber exactamente qué filas actualizar, cuáles borrar y cuáles insertar.

Para hacer ese emparejamiento fila por fila de forma perfecta y sin equivocarse, necesita un Índice Único que le garantice que está actualizando exactamente la fila correcta.

¿Cómo saber a qué columna ponerle el índice único en tu vista?
Depende totalmente de cómo construiste tu vista (mv_top_productos). Tienes que buscar la columna (o combinación de columnas) que jamás se repita en esa vista.
*/

CREATE UNIQUE INDEX idx_unico_mv_producto 
ON mv_top_productos (id_producto); -- Si tu vista tiene una fila por cada producto, la columna única es el ID del producto.

CREATE UNIQUE INDEX idx_unico_mv_tienda_mes 
ON mv_top_productos (id_tienda, mes);
-- Si tu vista está agrupada por tienda y por mes, ni la tienda ni el mes son únicos por sí solos
-- Aquí necesitas un índice compuesto por las columnas que usaste en tu GROUP BY.

-- El flujo de trabajo completo en la vida real:

-- 1. Creas la vista:
CREATE MATERIALIZED VIEW mv_top_productos AS 
SELECT id_producto, SUM(ventas) FROM compras GROUP BY id_producto;

-- 2. Le aplicas el índice ÚNICO (solo se hace una vez):
CREATE UNIQUE INDEX idx_mv_id_producto ON mv_top_productos (id_producto);

-- 3. Actualizado:
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_top_productos;

CREATE UNIQUE INDEX idx_empleados_curp
ON empleados (curp);

CREATE UNIQUE INDEX idx_cursos_alumnos
ON inscripciones_cursos (id_curso, id_estudiante);

CREATE UNIQUE INDEX  idx_mv_resumen_mes
ON mv_resumen_mensual (mes_venta);
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_resumen_mensual;

-- Tema 8: JOINs Avanzados (El Siguiente Nivel)
/*
1. Self Join (La Tabla que se une a sí misma)
A veces, los datos relacionales viven en la misma tabla.

El ejemplo clásico es la jerarquía corporativa: tienes una tabla empleados que tiene una columna id_empleado y otra columna id_jefe. 
(El jefe también es un empleado que vive en esa misma tabla).
Para que el motor no se confunda, es obligatorio usar alias diferentes para tratar a la tabla como si fueran dos distintas.
*/

SELECT 
    trabajador.nombre AS empleado,
    jefe.nombre AS manager
FROM empleados trabajador
-- Unimos la tabla consigo misma
LEFT JOIN empleados jefe 
    ON trabajador.id_jefe = jefe.id_empleado;
-- (Usamos LEFT JOIN porque el Director General (CEO) no tiene jefe, su id_jefe será NULL, y no queremos que desaparezca del reporte).

/*
2. Non-Equi Join (Uniones sin igualdad)
Casi siempre usamos el signo igual (=) en la cláusula ON. 
Pero el álgebra relacional permite usar operadores lógicos (<, >, BETWEEN).
Cruzar tabla sin un id en comun.

Tienes una tabla de ventas (con id_venta y fecha_venta) y una tabla de promociones (con nombre_promo, fecha_inicio, fecha_fin). 
Quieres cruzar las ventas con la promoción que estaba activa en ese momento.
*/

SELECT 
    v.id_venta, 
    v.fecha_venta, 
    p.nombre_promo
FROM ventas v
-- La condición no es un ID, es un rango de tiempo
LEFT JOIN promociones p 
    ON v.fecha_venta BETWEEN p.fecha_inicio AND p.fecha_fin;

/*
3. Anti Join (El filtro de exclusión por estructura)
Consiste en unir todo, pero luego filtrar explícitamente los nulos de la tabla derecha.
(Aunque NOT EXISTS suele ser más rápido en bases de datos modernas, el Anti-Join es un patrón clásico que debes saber leer si lo encuentras en código heredado).
*/

-- Queremos clientes que NUNCA han comprado
SELECT c.nombre
FROM clientes c
LEFT JOIN pedidos p ON c.id_cliente = p.id_cliente
WHERE p.id_pedido IS NULL; -- "Solo quédate con los que no encontraron pareja en la derecha"

/*
Hacer un JOIN usando BETWEEN o < / > es muy pesado para el procesador. 
Como el motor no puede buscar un "hash" o valor exacto, muchas veces recurre a comparar enormes bloques de filas secuencialmente.
*/

SELECT
    usuario.nombre AS usuario_nuevo,
    embajador.nombre AS embajador
FROM usuarios usuario
LEFT JOIN usuarios embajador
    ON usuario.id_quien_lo_invito = embajador.id_usuario;

SELECT 
    a.nombre,
    a.calificacion,
    c.letra
FROM alumnos a
INNER JOIN catalogo_notas c
    ON a.calificacion BETWEEN c.rango_min AND c.rango_max;

SELECT
    p.id_producto,
    p.nombre
FROM productos p
LEFT JOIN ventas v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

/*
id_entrevista_previa (que está en NULL si es la primera llamada de RH, pero tiene el ID de una entrevista anterior si pasaste a la ronda técnica)
*/
SELECT
    e1.empresa, 
    e1.fecha_entrevista AS fecha_actual,
    e2.fecha_entrevista AS fecha_previa
FROM entrevistas e1
INNER JOIN entrevistas e2
    ON e1.id_entrevista_previa = e2.id_entrevista;

/*
Es súper lógico pensar: "Si es la misma tabla, y es la misma columna, me tiene que dar la misma fecha, ¿no?"
La respuesta es no, y el secreto está en que el JOIN obliga a las tablas a "desfasarse" o mezclarse entre diferentes filas.

El truco de magia ocurre por tu condición: ON e1.id_entrevista_previa = e2.id_entrevista.
SQL toma la copia e1, revisa fila por fila y busca a su pareja en la copia e2.
*/

SELECT
    v.id_producto,
    v.cantidad_vendida,
    r.etiqueta
FROM ventas v
JOIN reglas_demanda r
    ON v.cantidad_vendida BETWEEN r.limite_inferior AND r.limite_superior

-- segun el rango se le asignara alguna etiqueta

SELECT
    e.nombre
FROM empresas_guardadas e
LEFT JOIN aplicaciones_enviadas a
    ON e.id_empresa = a.id_empresa
WHERE a.id_aplicacion IS NULL;

SELECT
c.id_compra, 
c.fecha_compra, 
c.monto_total,
m.objetivo_monetario,
CASE 
    WHEN c.monto_total > m.objetivo_monetario THEN 'Venta Atípica'
    ELSE 'Venta Normal'
END AS venta
FROM compras c
JOIN metas_mensuales m
    ON c.fecha_compra BETWEEN m.mes_inicio AND m.mes_fin;

-- Tema 9: ¿Qué es el "Código Heredado" (Legacy Code)?
/*
Suele ser código antiguo, muchas veces sin documentar, que "funciona por milagro" y que a todos les da miedo modificar porque si se rompe, se cae el sistema
tu trabajo inicial será leer este código heredado, entenderlo y modernizarlo (refactorizarlo).
*/

-- Tema 10: ¿Qué significa "columnas indexadas" para rangos?
/*
Un índice en una base de datos es como el índice alfabético al final de un libro.
Si haces un JOIN usando un signo igual (=), el motor va al índice, busca el número exacto y termina en un milisegundo.

Pero si haces un JOIN usando BETWEEN (un Non-Equi Join), el motor tiene que buscar el límite inferior, el límite superior, y extraer todo lo que hay en medio.
*/