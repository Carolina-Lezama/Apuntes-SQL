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

-- Eliminar Duplicados (Deduplicación) 
-- Paso 1: Asignar números (El más reciente será el 1) / ROW_NUMBER()
SELECT 
    id_cliente, 
    nombre, 
    fecha_registro,
    ROW_NUMBER() OVER(PARTITION BY id_cliente ORDER BY fecha_registro DESC) AS rn
FROM clientes;
-- Paso 2: Filtrar usando un CTE
WITH Clientes_Numerados AS (
    SELECT 
        id_cliente, nombre, fecha_registro,
        ROW_NUMBER() OVER(PARTITION BY id_cliente ORDER BY fecha_registro DESC) AS rn
    FROM clientes
)
SELECT id_cliente, nombre, fecha_registro
FROM Clientes_Numerados
WHERE rn = 1; -- ¡Adiós duplicados!

SELECT
    nombre,
    departamento,
    salario,
    DENSE_RANK() OVER(PARTITION BY departamento ORDER BY salario DESC) AS ranking_salarial
FROM empleados;

WITH empresa AS(
SELECT
    nombre,
    departamento,
    salario,
    DENSE_RANK() OVER(PARTITION BY departamento ORDER BY salario DESC) AS ranking_salarial
FROM empleados
)
SELECT * 
FROM empresa
WHERE ranking_salarial <= 3; -- ¡Así garantizas el Top 3 de CADA departamento!

WITH logins AS (
SELECT
    id_usuario, 
    ip,
    fecha_login,
    ROW_NUMBER () OVER(PARTITION BY id_usuario ORDER BY fecha_login ASC) AS primer_login
FROM usuarios
)
SELECT *
from logins
WHERE primer_login = 1;

SELECT *
from logins
WHERE primer_login != 1;

-- Tema 6: Consolidación Maestra: Subconsultas en el WHERE vs. en el FROM
/*
Entender cuándo usar una subconsulta en el WHERE (para filtrar) y cuándo en el FROM (para pre-agregación) es lo que define la eficiencia de un query.

Subconsultas en el WHERE (El Filtro Dinámico)
Se usan cuando necesitas evaluar las filas de tu tabla principal contra un valor o lista de valores que aún no conoces y que debes calcular al vuelo.
- Si usas operadores escalares (=, >, <), la subconsulta debe devolver 1 sola fila y 1 sola columna.
- Si usas operadores de conjunto (IN, NOT IN, ANY, ALL), la subconsulta puede devolver múltiples filas, pero siempre 1 sola columna.

Subconsultas en el FROM (Tablas Derivadas / Inline Views)
Se usan cuando necesitas transformar, limpiar o pre-agregaciones antes de unir los datos con otras tablas.
- Prevención de Explosión: Agrupar en el FROM antes de hacer un JOIN evita que se multipliquen filas accidentalmente
- Alias Obligatorio: Toda subconsulta en el FROM debe tener un alias asignado al final del paréntesis (... ) AS tabla_temporal;
*/

SELECT nombre, salario
FROM empleados
WHERE departamento IN (
    -- Esto es la subconsulta en el WHERE
    SELECT id_departamento FROM departamentos WHERE ubicacion = 'Norte'
);

SELECT 
    t.nombre, 
    t.departamento, 
    t.salario
FROM (
    -- 1. SUBCONSULTA EN EL FROM: Crea la tabla con el ranking de salarios
    SELECT 
        nombre, 
        departamento, 
        salario,
        ROW_NUMBER() OVER(PARTITION BY departamento ORDER BY salario DESC) AS empleado_salario
    FROM empleados
) AS t 

WHERE t.empleado_salario = 1 -- Filtro normal
  AND t.departamento IN (
      
      -- 2. SUBCONSULTA EN EL WHERE: Trae la lista de departamentos ricos
      SELECT id_departamento 
      FROM departamentos 
      WHERE presupuesto > 500000
      
  );

SELECT
    nombre,
    precio
FROM productos
WHERE precio > (
    SELECT precio
    FROM productos
    WHERE TRIM(nombre) = 'Laptop Pro'
);

/*
Te regresará solo 1 fila por usuario (asumiendo que en tu tabla externa cada usuario aparece una sola vez)
Le da exactamente igual si el 1 estaba una vez o un millón de veces en la subconsulta; la respuesta a la pregunta "¿existe?" ya se respondió.
*/
SELECT
    nombre,
    telefono
FROM clientes
WHERE id in (
    SELECT id_cliente
    FROM pedidos
    WHERE metodo_pago = 'Tarjeta'
);

SELECT e.nombre, v.total_vendido,
    CASE 
        WHEN v.total_vendido > 50000 THEN 'Estrella'
        ELSE 'Regular'
    END AS clasificacion
FROM (
    SELECT id_vendedor, SUM(monto) AS total_vendido
    FROM ventas
    GROUP BY id_vendedor
) AS v
INNER JOIN empleados e
ON v.id_vendedor = e.id;

SELECT *
FROM (
    SELECT
        nombre, 
        departamento, 
        salario,
        ROW_NUMBER() OVER(ORDER BY salario DESC) AS empleado_salario
    FROM empleados
) AS extraccion
WHERE extraccion.empleado_salario = 2; 

-- Tema 7: Refactorización y Simplificación (HAVING vs. JOIN vs. Ventanas)
/*
No uses una subconsulta si existe una herramienta nativa diseñada para ese trabajo.

Los motores relacionales están altamente optimizados para cruzar índices con JOIN. 
Cruzar conjuntos completos de golpe es infinitamente más rápido que disparar miles de mini-consultas individuales.
*/

-- Simplificar con HAVING (Filtros de Agregación directos)
-- Evitar subconsultas en el from para luego usar where

-- Antes:
SELECT id_cliente, total_gastado
FROM (
    SELECT id_cliente, SUM(monto) AS total_gastado
    FROM compras
    GROUP BY id_cliente
) AS temporal
WHERE total_gastado > 5000;
-- Despues:
SELECT id_cliente, SUM(monto) AS total_gastado
FROM compras
GROUP BY id_cliente
HAVING SUM(monto) > 5000;

-- Simplificar con JOIN (Evitar Subconsultas en el SELECT)

-- Antes:
SELECT 
    id_pedido,
    monto,
    (SELECT nombre FROM clientes WHERE id = pedidos.id_cliente) AS nombre_cliente
FROM pedidos;
-- Despues:
SELECT p.id_pedido, p.monto, c.nombre AS nombre_cliente
FROM pedidos p
LEFT JOIN clientes c ON p.id_cliente = c.id;

-- Simplificar con Ventanas OVER() (Comparativas sin JOINs)
-- Antes:
SELECT e.nombre, e.salario, depto.promedio
FROM empleados e
INNER JOIN (
    SELECT departamento, AVG(salario) AS promedio
    FROM empleados
    GROUP BY departamento
) AS depto ON e.departamento = depto.departamento;
-- Despues:
SELECT 
    nombre, 
    salario, 
    AVG(salario) OVER(PARTITION BY departamento) AS promedio
FROM empleados;

SELECT
    categoria,
    COUNT(*) AS conteo
FROM productos
GROUP BY categoria
HAVING COUNT(*) > 10;

SELECT
    id_venta,
    monto,
    (monto / SUM(monto) OVER()) * 100 AS porcentaje
FROM ventas

SELECT
    e.nombre,
    e.apellido,
    s.nombre_sucursal AS sucursal
FROM
    empleados e
LEFT JOIN sucursales s
    ON e.sucursal_id = s.id

SELECT
    id_cliente,
    MAX(fecha)
FROM pedidos
GROUP BY id_cliente
HAVING COUNT(*) > 5;

-- Tema 8: SELECT Y GROUP BY 
/*
Según el estándar oficial de SQL, NO se deberían poder usar los alias del SELECT en el GROUP BY, precisamente porque el GROUP BY ocurre un paso antes de que el motor lea el SELECT y cree los alias.

¿por qué a veces funciona?
Los creadores de algunos sistemas decidieron hacer una "excepción a la regla" por pura comodidad para los programadores, para que no tengamos que repetir fórmulas gigantescas.
¿Permite alias en GROUP BY?	Si
*/

-- Antes:
SELECT (salary * months) AS earnings, COUNT(*)
FROM Employee
GROUP BY (salary * months) 
ORDER BY earnings DESC;  
-- Despues:
SELECT (salary * months) AS earnings, COUNT(*)
FROM Employee
GROUP BY earnings
ORDER BY earnings DESC 
LIMIT 1;     

-- Tema 9: Conversión Segura de Tipos (TRY_CAST)
/*
El Peligro de CAST() estándar
La función tradicional CAST(columna AS INT) fuerza al motor a transformar ellta comple tipo de dato. 
Si encuentra una cadena de texto que no puede convertir a número, la consuta aborta

TRY_CAST(columna AS tipo_dato) intenta realizar la conversión. Si la conversión es exitosa, devuelve el dato transformado. 
Si la conversión falla, devuelve NULL de manera silenciosa y segura

Imputación Inmediata con COALESCE
casi nunca se deja el NULL resultante flotando en el dataset final. 
Lo combinamos inmediatamente con COALESCE para asignar un valor por defecto (imputación de datos)
*/

SELECT 
    TRY_CAST('150' AS INT) AS conversion_exitosa,      -- Devuelve: 150 (Entero)
    TRY_CAST('Sin definir' AS INT) AS conversion_fallida -- Devuelve: NULL

SELECT 
    id_registro,
    -- Si falla al convertir a entero, ponle un 0 automáticamente
    COALESCE(TRY_CAST(edad_texto AS INT), 0) AS edad_limpia
FROM usuarios_landing;

WITH sensores_convertidos AS (
    SELECT 
        id_sensor, 
        TRY_CAST(temperatura_raw AS DECIMAL(5,2)) AS temperatura_limpia
    FROM lecturas_sensor
)

SELECT id_sensor, temperatura_limpia
FROM sensores_convertidos
WHERE temperatura_limpia IS NOT NULL;   

SELECT 
    id_sensor, 
    TRY_CAST(temperatura_raw AS DECIMAL(5,2)) AS temperatura_limpia
FROM lecturas_sensor
WHERE TRY_CAST(temperatura_raw AS DECIMAL(5,2)) IS NOT NULL;
/*
DECIMAL(precisión, escala).
(La Precisión): Es el número total de dígitos que puede almacenar el número en total (contando los que están a la izquierda y a la derecha del punto decimal).
(La Escala): Es el número máximo de dígitos que obligatoriamente van a estar a la derecha del punto decimal.
*/

-- No puedes declarar un alias dentro de los paréntesis de una función de agregación.
SELECT SUM(TRY_CAST(ingreso_mensual AS INT)) AS total_ingresos 
FROM finanzas_import;

CASE 
    WHEN TRY_CAST(codigo_postal AS INT) IS NULL THEN 'Extranjero / Invalido'
    ELSE 'Nacional'
END AS region_valida

WITH productos_numerados AS (
    SELECT 
        COALESCE(TRY_CAST(id_producto AS INT), 0) AS id_producto_int,
        ROW_NUMBER() OVER(
            PARTITION BY id_producto 
            ORDER BY COALESCE(TRY_CAST(id_producto AS INT), 0) ASC
        ) AS rn
    FROM catálogo_crudo
)
SELECT id_producto_int
FROM productos_numerados
WHERE rn = 1
ORDER BY id_producto_int ASC; 
/*
Para deduplicar de forma segura, particionamos por el ID, pero ordenamos por un criterio de desempate (como una fecha de registro o un número de fila secundario).
*/

-- Tema 10: La forma "Pro": CTE (Cláusula WITH)
/*
un CTE es como declarar variables limpias al inicio de tu script de Python antes de usarlas en la lógica principal.

Es un conjunto de resultados temporal y con nombre que solo existe durante la ejecución de esa consulta específica. 
No se guarda en el disco duro, vive en la memoria RAM y se destruye en cuanto el query termina.
*/
WITH Ventas_Limpias AS (
    SELECT 
        id_vendedor, 
        TRY_CAST(monto AS DECIMAL(10,2)) AS monto_limpio
    FROM ventas_raw
    WHERE TRY_CAST(monto AS DECIMAL(10,2)) IS NOT NULL
)
SELECT id_vendedor, SUM(monto_limpio) AS total
FROM Ventas_Limpias
GROUP BY id_vendedor;

/*
Puedes declarar varios CTEs separándolos únicamente por una coma
un CTE secundario puede consultar a un CTE primario

Puedes invocar el mismo CTE múltiples veces en tus JOINs principales sin tener que reescribir la subconsulta entera.
*/

WITH Clientes_Activos AS (
    SELECT id_cliente, nombre FROM clientes WHERE estatus = 'ACTIVO'
),
Pedidos_Recientes AS (
    SELECT id_cliente, SUM(total) AS gasto 
    FROM pedidos 
    WHERE fecha >= '2026-01-01'
    GROUP BY id_cliente
)
-- Unimos nuestros dos bloques limpios
SELECT c.nombre, p.gasto
FROM Clientes_Activos c
INNER JOIN Pedidos_Recientes p ON c.id_cliente = p.id_cliente;

WITH emp_nuevos AS (
    SELECT nombre, departamento, salario 
    FROM empleados 
    WHERE fecha_contratacion >= '2020-01-01'
)
SELECT departamento, AVG(salario) AS salario_promedio
FROM emp_nuevos
GROUP BY departamento;

WITH Data_Casteada AS (
    SELECT id_usuario,
        TRY_CAST(puntuacion_cruda AS INT) AS puntuacion_cruda_int
    FROM evaluaciones
),
    Usuarios_Validos AS (
        SELECT *
        FROM Data_Casteada
        WHERE puntuacion_cruda_int > 50 AND puntuacion_cruda_int IS NOT NULL
    )
SELECT *
FROM Usuarios_Validos

WITH Transacciones_Numeradas AS (
    SELECT 
    id_transaccion,
    fecha_procesamiento,
    ROW_NUMBER() OVER(PARTITION BY id_transaccion ORDER BY fecha_procesamiento DESC) AS deduplicacion
    FROM transacciones_web
)
SELECT *
FROM Transacciones_Numeradas
WHERE deduplicacion = 1

WITH Total_Ventas AS(
    SELECT id_tienda, SUM(ingresos) AS total_ingresos
    FROM ventas
    GROUP BY id_tienda
),
    Top_Tiendas AS (
        SELECT *
        FROM tiendas
        WHERE ubicacion = 'Norte'
)
SELECT *
FROM Top_Tiendas t
INNER JOIN Total_Ventas v
ON t.id_tienda = v.id_tienda
/*
Evitar el SELECT * en uniones finales
Al usar el asterisco en un JOIN, la base de datos te devolverá ambas columnas de enlace enviando datos duplicados a través de la red

*/