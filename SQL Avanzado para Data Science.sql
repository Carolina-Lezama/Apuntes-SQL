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
/*
1. COUNT(*): El Censo Total
Cuenta todas las filas físicas de la tabla, sin importar si están llenas de datos o si todas sus columnas son NULL. 
Es el recuento absoluto de registros.
*/
SELECT COUNT(*) FROM clientes;

/*
2. COUNT(1): El Mito del Rendimiento
Hace exactamente lo mismo que COUNT(*).
Transforma COUNT(1) en COUNT(*) internamente. Tienen exactamente el mismo rendimiento.
Se recomienda usar siempre COUNT(*) porque es el estándar
*/
SELECT COUNT(1) FROM clientes;

/*
3. COUNT(columna): El Detector de Presencia
Esto no cuenta filas, cuenta cuántos valores NO NULOS hay en esa columna específica.
Si hay nulos no se contaran en el regreso
*/
SELECT COUNT(email) FROM clientes;

/*
4. COUNT(DISTINCT columna)
Cuenta los valores únicos y no nulos.
*/
SELECT COUNT(DISTINCT id_cliente) FROM clientes;

SELECT COUNT(*) AS total_general, COUNT(id_repartidor) AS asignados FROM pedidos;

SELECT COUNT(DISTINCT direccion_ip) FROM accesos_web;

-- Tema 6: Operadores para Subconsultas de Múltiples Filas (IN, ANY, ALL)
/*
"Subquery returned more than 1 value" ocurre por una violación de cardinalidad.
Los operadores relacionales básicos están diseñados para comparar un valor contra otro valor único.

funcionan para comparar un valor contra lo que podríamos llamar una "lista", un "conjunto" o una "colección" de resultados.
Están diseñados para lidiar con múltiples valores, sí. Sin embargo, no es obligatorio que la lista tenga más de uno.
los usas cuando esperas o existe la posibilidad de que haya más de un valor a comparar.
*/

-- Ejemplo incorrecto: 
WHERE precio = (10, 20, 30)
-- el motor se confunde y aborta la operación porque no sabe contra cuál de los tres números quieres hacer la comparación exacta.

/*
IN: Comprueba si tu valor es idéntico a cualquiera de los elementos de la lista.
ANY o SOME: Compara un valor usando un operador (>, <, =, etc.) contra la lista. Da luz verde si la condición se cumple con al menos un elemento del conjunto.
ALL: usa un operador matemático, pero es mucho más exigente. Solo da luz verde si la condición se cumple para absolutamente todos los elementos de la lista.
*/

-- 1. El operador IN; Reemplaza al signo =
SELECT nombre, email 
FROM clientes 
WHERE id_cliente IN (
    SELECT DISTINCT id_cliente 
    FROM pedidos 
    WHERE fecha >= '2026-04-01'
);

SELECT nombre 
FROM tienda 
WHERE departamento IN ('Ventas', 'Marketing', 'Soporte');


-- 2. El operador ANY (o SOME); La condición debe cumplirse para al menos uno de los valores de la lista
--      = ANY(lista): Es exactamente lo mismo que usar IN.

SELECT nombre, precio 
FROM productos 
WHERE precio > ANY (
    SELECT precio 
    FROM productos 
    WHERE categoria = 'Basicos'
);

SELECT nombre, precio 
FROM productos 
WHERE salario > ANY (SELECT salario FROM practicantes);

-- 3. El operador ALL; La condición debe cumplirse para todos y cada uno de los valores de la lista
SELECT nombre, salario 
FROM empleados 
WHERE salario > ALL (
    SELECT salario 
    FROM empleados 
    WHERE departamento = 'Ventas'
);

SELECT nombre, precio 
FROM productos 
WHERE salario > ALL (SELECT salario FROM practicantes);

/*
Si usas NOT IN y la subconsulta devuelve una lista que contiene al menos un valor NULL, la consulta principal devolverá cero filas, sin importar si hay datos válidos.
*/

-- FORMA CORRECTA Y SEGURA
SELECT nombre FROM empleados 
WHERE id_departamento NOT IN (
    SELECT id_departamento 
    FROM departamentos 
    WHERE id_departamento IS NOT NULL 
);

SELECT s.id_sucursal, COUNT(e.id_empleado) AS cantidad_empleados
FROM sucursales s
LEFT JOIN empleados e ON s.id_sucursal = e.id_sucursal
GROUP BY s.id_sucursal
HAVING COUNT(e.id_empleado) = 0;

SELECT nombre, apellido
    FROM usuarios
    WHERE id_pais IN (
        SELECT id_pais 
        FROM paises 
        WHERE continente = 'Europa'
    );

SELECT titulo
FROM libros
WHERE id_autor IN (
    SELECT id_autor
    FROM autores
    WHERE nacionalidad = 'Argentina'
);

SELECT marca, precio 
FROM vehiculos 
WHERE precio < ALL (
    SELECT precio 
    FROM vehiculos
    WHERE marca = 'Ferrari'
);

SELECT id_sucursal, nombre_sucursal
FROM sucursales
WHERE id_sucursal NOT IN (
    SELECT id_sucursal 
    FROM empleados
    WHERE id_sucursal IS NOT NULL -- si hay nulos devolverá cero filas, no olvidar esta parte
);

SELECT id_factura,
    CASE 
        WHEN total > 
        (
            SELECT AVG(total)
            FROM  facturas
        ) 
        THEN 'Alta'
        ELSE 'Normal'
    END AS clasificacion
FROM facturas

-- Tema 7: UNION ALL (y UNION) - Apilando Datos
/*
con los JOINs, hemos unido tablas horizontalmente (agregando columnas a nuestras filas

JOIN: Pegas la Tabla B al lado de la Tabla A.
UNION: Pones la Tabla B debajo de la Tabla A.

Para apilar dos queries, deben cumplir dos reglas estrictas:
-- Misma cantidad de columnas
-- Mismos tipos de datos en orden

UNION ALL: Apila todo. Si hay filas duplicadas entre el query A y el query B, mantiene los duplicados.
UNION: Apila todo y luego hace un escaneo completo para eliminar duplicados.
*/

-- texto fijo en el SELECT para identificar el origen de cada fila
SELECT id_cliente, monto, 'Venta Física' AS origen_venta
FROM ventas_tiendas
UNION ALL
SELECT id_cliente, monto, 'Venta Web' AS origen_venta
FROM ventas_ecommerce;

/*
Usa siempre UNION ALL por defecto.
Solo usa UNION si explícitamente la regla de negocio te exige limpiar duplicados exactos entre ambas tablas.

si quieres limpiar los nulos de ambas tablas antes de apilarlas, debes poner el WHERE en cada SELECT
Si quieres quitar los duplicados de tu lista final
*/

SELECT nombre, origen
FROM (
    -- Aquí adentro está tu bloque combinado
    SELECT nombre, 'Norte' AS origen 
    FROM proveedores_norte
    UNION ALL
    SELECT nombre, 'Sur' AS origen 
    FROM proveedores_sur
) AS todos_los_proveedores  -- ¡El alias es obligatorio!
WHERE nombre LIKE 'A%';       -- Ahora puedes filtrar la tabla combinada

-- primero "empaquetas" tu UNION ALL y le pones un nombre arriba, y luego lo usas abajo.
-- 1. Empaquetamos la unión
WITH todos_los_proveedores AS (
    SELECT nombre, 'Norte' AS origen 
    FROM proveedores_norte
    UNION ALL
    SELECT nombre, 'Sur' AS origen 
    FROM proveedores_sur
)
-- 2. Usamos el paquete como una tabla normal
SELECT nombre, origen
FROM todos_los_proveedores
WHERE nombre LIKE 'A%';

SELECT id, nombre, 'Norte' AS origen 
FROM proveedores_norte
WHERE nombre IS NOT NULL
UNION ALL
SELECT id, nombre, 'Sur' AS origen 
FROM proveedores_sur
WHERE nombre IS NOT NULL;

SELECT nombre, email, 'Activo' AS estatus_laboral 
FROM empleados_activos
UNION ALL
SELECT nombre, email , 'Inactivo' AS estatus_laboral 
FROM empleados_inactivos

WITH personas AS (
    SELECT nombre
    FROM usuarios
    UNION ALL
    SELECT nombre
    FROM empleados
)
SELECT nombre, COUNT(nombre) AS cantidad_personas
FROM personas
GROUP BY nombre
ORDER BY cantidad_personas DESC; 

-- Tema 8: Los JOINs Especiales (FULL OUTER y CROSS)
/*
FULL OUTER JOIN
Es la combinación de un LEFT JOIN y un RIGHT JOIN. Trae todas las filas de ambas tablas.
    Si hay coincidencia, las une.
    Si hay una fila en la izquierda sin pareja, rellena la derecha con NULL.
    Si hay una fila en la derecha sin pareja, rellena la izquierda con NULL.
*/

-- no disppnible en mysql
SELECT rh.nombre, n.monto_pago
FROM empleados_rh rh
FULL OUTER JOIN pagos_nomina n 
    ON rh.id_empleado = n.id_empleado;

-- forma correcta en sql
-- PASO 1: LEFT JOIN
SELECT e.nombre AS empleado, d.nombre_departamento AS departamento
FROM empleados e
LEFT JOIN departamentos d ON e.id_departamento = d.id_departamento
UNION --bune y elimina duplicados
-- PASO 2: RIGHT JOIN
SELECT e.nombre AS empleado, d.nombre_departamento AS departamento
FROM empleados e
RIGHT JOIN departamentos d ON e.id_departamento = d.id_departamento;

/*
CROSS JOIN
Este es el único JOIN que no lleva la cláusula ON. 
Lo que hace es tomar cada fila de la Tabla A y combinarla con todas y cada una de las filas de la Tabla B.

Solo usa CROSS JOIN con tablas de catálogos muy pequeñas (dimensiones) o cuando estés filtrando fuertemente en el WHERE

Tienes una tabla colores (Rojo, Azul, Verde) y una tabla tallas (S, M, L). 
Quieres generar el catálogo base para insertar todas las variaciones posibles
*/

SELECT c.color, t.talla
FROM colores c
CROSS JOIN tallas t;
-- Devuelve: Rojo-S, Rojo-M, Rojo-L, Azul-S... etc.

-- Usando un CTE para poder usar el alias
WITH calculo_productos AS (
    SELECT 
        id_producto, 
        ((precio * 1.16) - costo + tarifa_envio) AS margen_ganancia -- Un cálculo largo
    FROM productos
)
SELECT *
FROM calculo_productos
WHERE margen_ganancia > 500; -- ¡Aquí el alias SÍ funciona!

SELECT m.mes, s.ubicacion
FROM meses m
CROSS JOIN sucursales s;

SELECT e.nombre, c.codigo_credencial
FROM estudiantes e
FULL OUTER JOIN credenciales_biblioteca c
    ON e.id_estudiante = c.id_estudiante;

-- ESTRUCTURA 
SELECT
FROM
LEFT JOIN
    ON
UNION -- O UNION ALL
SELECT
FROM
LEFT JOIN -- O RIGHT JOIN, DEPENDE SI LO ACEPTA O SOLO SE INVIERTE EL ORDEN DE LAS TABLAS
    ON

SELECT p.nombre, d.nivel_descuento, p.precio * (1 - d.nivel_descuento) AS precio_con_descuento
FROM productos p
CROSS JOIN descuentos d -- quiero pensar que son decimales .10, .20...
WHERE p.precio * (1 - d.nivel_descuento) > 500
ORDER BY  precio_con_descuento DESC;

-- Tema 9: Usar HAVING sin GROUP BY
/*
Cuando usas un HAVING sin escribir un GROUP BY, el motor de SQL asume que toda tu tabla (o el resultado de tu consulta) es un solo y gigantesco grupo.
usarlo sin GROUP BY solo tiene sentido si vas a evaluar una función de agregación (SUM, COUNT, AVG, etc.) que aplique a absolutamente todos los registros.
comprime toda tu tabla para tratarla como un único y gigantesco grupo.

Devuelve 1 fila: Si la condición de tu HAVING es verdadera
Devuelve 0 filas: Si la condición es falsa
*/

SELECT SUM(salario) AS nomina_total
FROM empleados
HAVING SUM(salario) > 1000000;

-- Tema 11: INNER JOIN (La intersección pura)
/*
Si las tablas fueran conjuntos, el INNER JOIN es la parte donde ambos círculos se enciman. Solo devuelve las filas donde hay una coincidencia exacta en ambas tablas.

Necesitas tres cosas:
    Tabla A (Izquierda).
    Tabla B (Derecha).
    La Condición (ON)

¿Qué pasa si no hay coincidencia?
esas filas desaparecen del resultado. El INNER JOIN es estricto: "O están los dos, o no está nadie".
*/

SELECT e.nombre, d.nombre_depto
FROM empleados AS e
INNER JOIN departamentos AS d ON e.id_depto = d.id_depto;

-- ejemplo completo de todo en uno.
SELECT
    t1.columna,
    COUNT(*),
    SUM(t2.valor)
FROM tabla1 t1
INNER JOIN tabla2 t2
    ON t1.id = t2.id
WHERE condicion
GROUP BY t1.columna
HAVING SUM(t2.valor) > 100
ORDER BY SUM(t2.valor) DESC;

-- Si declaraste el alias en el FROM o en el JOIN, debes usar el alias en el WHERE.
/*
Una vez que le asignas un alias a una tabla en una consulta el motor de la base de datos "olvida" el nombre original por el resto de la ejecución de ese query.
*/

/*
Posible error en consultas si existen columnas de mismo nombre en ambas tablas.

usuarios
| id | nombre |

compras
| id | usuario_id | fecha |

¿Cuál id quieres?
Eso genera error tipo: Column 'id' is ambiguous
*/

-- error
SELECT nombre, fecha, id
FROM usuarios
INNER JOIN compras ON usuarios.id = compras.usuario_id;

-- solucion
SELECT nombre, fecha, usuarios.id --o compras.id
FROM usuarios
INNER JOIN compras
ON usuarios.id = compras.usuario_id;

SELECT p.nombre, c.categoria_nombre
FROM productos AS p
INNER JOIN categorias AS c ON p.id_categoria = c.id_categoria
WHERE p.precio > 100; -- Aquí usamos 'p'

SELECT C.nombre, p.monto
FROM clientes AS C
INNER JOIN pedidos AS p
ON ON C.id = p.id_cliente;
-- Error: C.id = p.id, casi siempre suele ser llave primaria

SELECT e.nombre, s.ciudad
FROM empleados AS e
INNER JOIN sedes AS s
ON e.id_sede = s.id_sede;
WHERE e.nombre LIKE 'A%'
-- El orden estricto es FROM -> JOIN -> WHERE

SELECT 
    c.nombres, 
    COUNT(*)
FROM productos AS p
INNER JOIN categorias AS c
    ON p.id_categoria = c.id_categoria
GROUP BY c.nombres;

SELECT l.titulo, UPPER(a.nombre) 
FROM autores AS a
INNER JOIN libros AS l
ON a.id_autor = l.id_autor
WHERE LENGTH(l.titulo) > 15;

/*
¿Se pueden unir más de dos tablas?
Sí. Un INNER JOIN puede unir 3, 4 o más tablas siempre que exista relación entre ellas.
El resultado de la unión de la Tabla A y B se convierte en una "tabla virtual" a la que luego le pegas la Tabla C

Nunca unas tablas por columnas que no tengan el mismo tipo de dato. 
Si id_cliente en una tabla es INT y en la otra es VARCHAR, el motor tendrá que hacer una conversión implícita en cada fila.
*/

SELECT 
    u.nombre,
    c.id_compra,
    p.producto,
    p.precio,
    pa.metodo
FROM usuarios u
INNER JOIN compras c
    ON u.id_usuario = c.id_usuario
INNER JOIN productos p
    ON c.id_producto = p.id_producto
INNER JOIN pagos pa
    ON c.id_compra = pa.id_compra;
-- No todas las tablas deben tener la misma columna ni el mismo nombre de llave.

SELECT 
    u.nombre,
    COUNT(c.id_compra) AS total_compras,
    SUM(p.precio) AS gasto_total
FROM usuarios u
INNER JOIN compras c
    ON u.id_usuario = c.id_usuario
INNER JOIN productos p
    ON c.id_producto = p.id_producto
GROUP BY u.nombre;

SELECT e.nombre, c.nombre
FROM estudiantes AS e
INNER JOIN inscripciones AS i
    ON e.id_estudiante = i.id_estudiante
INNER JOIN cursos AS c
    ON ON i.id_curso = c.id_curso

SELECT c.nombre, SUM(v.precio_venta)
FROM ventas v
INNER JOIN productos p
    ON v.id_producto = p.id_producto
INNER JOIN categorias c
    ON p.id_categoria = c.id_categoria
GROUP BY c.nombre
HAVING SUM(v.precio_venta) > 10000
/*
Imagina que después de los INNER JOIN, el motor de SQL crea una "Gran Tabla Temporal"
las funciones de agregación funcionan exactamente igual que si fuera una sola tabla.
*/

SELECT e.nombre, o.ciudad, p.nombre
FROM empleados e 
INNER JOIN oficinas o
    ON e.id_empleado = o.id_empleado
INNER JOIN paises p
    ON o.id_pais = p.id_pais -- o.id_oficina = p.id_oficina, significaría que cada oficina es un país
WHERE p.nombre != "USA"

SELECT l.titulo, a.nombre
FROM libro l
INNER JOIN autores a
    ON l.id_autor = a.id_autor
WHERE LENGTH(a.nombre) = 5

/*
El problema de usar funciones de agregacion en where es que mata el rendimiento porque el motor tiene que transformar cada fila antes de comparar, ignorando cualquier índice.
WHERE UPPER(clientes.estado) = 'ACTIVO'

Soluciones:
1. Normalización en el INSERT, al insertar el string debe ya estar normalizado en el texto requerido
2. Case-Insensitive Collation: Configurar la base de datos para que no distinga entre mayusculas ni minusculas
*/