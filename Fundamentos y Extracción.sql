--  Tema 1: Estructura de la Consulta (DQL)

/* 
DQL (Data Query Language): el orden en que escribes no es el orden en que la base de datos ejecuta.

Estructura:
    - SELECT: Define qué columnas queremos ver.
    - FROM: Define de qué tabla (o tablas) provienen los datos.
    - WHERE: Filtra las filas que cumplen una condición.
    - GROUP BY: Agrupa filas que tienen valores comunes en columnas específicas.
    - HAVING: Filtra los grupos creados por el GROUP BY.
    - ORDER BY: Ordena el resultado final (ascendente o descendente).
    - LIMIT / TOP: Restringe la cantidad de filas devueltas.

Orden de ejecucion:
    - FROM (Busca la tabla).
    - WHERE (Filtra filas individuales).
    - GROUP BY (Agrupa).
    - HAVING (Filtra grupos).
    - SELECT (Recupera las columnas y aplica alias).
    - ORDER BY (Ordena el set final).

No puedes usar un alias creado en el SELECT dentro de un WHERE, cuando el motor llega al WHERE, aún no esta creado el alias
*/

-- Ejemplo:
SELECT 
    plan_type, 
    COUNT(customer_id) AS total_users
FROM 
    telecom_customers
WHERE 
    status = 'Active'
GROUP BY 
    plan_type
HAVING 
    COUNT(customer_id) > 100
ORDER BY 
    total_users DESC;

-- Tema 2 : Selección y Filtrado Básico (SELECT & WHERE)
/* 
El SELECT actúa como un filtro, permite seleccionar ciertas columnas de la tabla

No usar SELECT * en aplicaciones productivas, consume ancho de banda inncesario, especifica siempre tus columnas.
*/

SELECT nombre, apellido from personas.

/* 
WHERE es un filtro, para solo obtener filas que cumplen la condición

Operador    Significado             Ejemplo
=           Igual a                 WHERE pais = 'Mexico'
<> o !=     Diferente de            WHERE estatus != 'Inactivo'
< , >       Menor que, Mayor que    WHERE edad > 18
<= , >=     Menor/Mayor o igual,    WHERE precio <= 100

El uso de Comillas
    Texto (Strings) y Fechas: Siempre van entre comillas simples: 'Hola', '2026-04-10'.
    Números: Van sin comillas: 100, 25.5.

*/

SELECT nombre
FROM empleados
WHERE fecha_ingreso < '2025-01-01';

SELECT nombre,email 
FROM usuarios 
WHERE pais = 'Colombia';

SELECT nombre,stock 
FROM almacen 
WHERE stock != 0;

SELECT producto, stock 
FROM inventario 
WHERE stock < 5 OR stock > 100

-- Tema 3: Operadores Lógicos (AND, OR, NOT) e IN

-- 1. El operador AND (Y), todas las condiciones deben cumplirse.

SELECT nombre, edad
FROM personas 
WHERE pais = 'México' AND edad >= 18;

-- 2. El operador OR (O), con que una de las condiciones se cumpla para que la fila aparezca

SELECT nombre,
FROM personas 
WHERE pais = 'México' OR pais = 'Colombia'

-- 3. El operador NOT (NO), invierte el resultado de una condición. Trae todo lo que no cumpla con lo que sigue.
SELECT usuario
FROM telefonos 
WHERE NOT estatus = 'Inactivo'
    -- (Trae todos los que estén activos o en cualquier otro estado)

SELECT * 
FROM pedidos 
WHERE NOT estado = 'Entregado'

-- 4. El operador IN (Dentro de), elegante y eficiente de hacer varios OR
SELECT nombre,
FROM personas 
WHERE ciudad IN ('Puebla', 'CDMX', 'Monterrey')

/*
Cuando combinas AND y OR en el mismo WHERE, el AND tiene prioridad.
Solución: Usa paréntesis para agrupar tus condiciones y evitar resultados inesperados
*/
SELECT nombre,
FROM productos 
WHERE (categoria = 'Ropa' OR categoria = 'Calzado') AND precio < 10

SELECT * 
FROM vehicuclos
WHERE (color = 'azul' OR color = 'rojo' ) AND marca = 'Toyota'

-- Tema 4: Dudas parte 1.
/* 
1. ¿Comillas sencillas (') o dobles (")?
Sencillas son el estandar, las dobles son para identificadores
    - WHERE nombre = 'Carolina'
    - SELECT "Fecha de Entrega" FROM "Pedidos Totales"

Evita poner espacios en los nombres de tus tablas para nunca tener que usar comillas dobles.
*/

/*
2. ¿Cómo saber los tipos de datos con un query? Funciona para la mayoria
*/

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'nombre_de_tu_tabla';

-- o:

DESCRIBE tabla;

/*
3. ¿Es obligatorio el punto y coma (;)?
Es la mejor práctica absoluta. Sirve para separar instrucciones.
*/

/* 
4. Convenciones de escritura
el estándar es snake_case y el uso de Mayúsculas para palabras reservadas.
    - BIEN: SELECT nombre_cliente FROM ventas_mensuales;
    - MAL: select nombreCliente from VentasMensuales;
*/

-- Tema 5: Crear BD y Tablas

-- 1. Crear la Base de Datos
CREATE DATABASE nombre_de_la_bd;
CREATE DATABASE tienda_tecnologia;

-- 2. Crear una Tabla, definir: Nombre de la columna + Tipo de dato + Restricciones (Constraints).
CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY,         -- Un número único que identifica la fila
    nombre VARCHAR(50) NOT NULL,       -- Texto de hasta 50 caracteres, no puede estar vacío
    email VARCHAR(100) UNIQUE,          -- No se puede repetir el mismo email
    fecha_registro DATE DEFAULT CURRENT_DATE -- Si no pones fecha, pone la de hoy
);

CREATE TABLE categorias(
    id_usuario INT ,        
    nombre VARCHAR(30) 
);

/* 
Tipos de datos comunes:
    INT: Números enteros.
    DECIMAL(10,2): Números con decimales (ej. dinero).
    VARCHAR(N): Texto de longitud variable.
    BOOLEAN: Verdadero o falso.

Cambiar el tipo de dato de una columna puede ser costosa en tiempo y recursos, diseña un modelo antes
Especificar los valores
*/

CREATE TABLE categorias(
    id_usuario INT ,        
    nombre VARCHAR(30)
);

CREATE TABLE productos (
precio DECIMAL(10,2) NOT NULL
);

-- Tema 6: Alias (AS) - El Arte de la Legibilidad

/* 
1. Alias en Columnas
Se usa para renombrar el encabezado de la columna en el resultado final. 
No cambia el nombre real en la tabla, solo cómo se ve en el reporte.
*/

SELECT nombre_empleado AS funcionario, salario * 0.10 AS bono_vacacional
FROM empleados;

SELECT precio + impuesto 
AS precio_total 
FROM productos; 

-- SQL permite realizar aritmética básica (+, -, *, /) directamente en el SELECT

SELECT nombre, salario / 30 
AS Pago_Diario
FROM nomina;

/* 
2. Alias en Tablas
Se usa para "abreviar" el nombre de una tabla.
*/

SELECT e.nombre, e.puesto
FROM empleados_departamento_contabilidad AS e;

SELECT * 
FROM historial_de_ventas_anuales_2025 AS h;

-- Tema 7: Filtrado Avanzado (LIKE, BETWEEN, IS NULL)

/* 
1. El operador LIKE (Patrones de texto)
buscar texto que coincida con un patrón 
    "%" Cualquier cantidad de caracteres 0+:
        WHERE columna LIKE 'A%': Empieza con "A"
        WHERE columna LIKE '%a': Termina con "a"
        WHERE columna LIKE '%data%': Contiene la palabra "data" en cualquier parte.
    "_" Solo un caracter:
        WHERE columna LIKE 'C_rlo'
*/

SELECT nombre FROM productos WHERE nombre LIKE 'Laptop%';
SELECT codigo_empleado FROM empleados WHERE codigo_empleado LIKE '_A%'

/* 
2. El operador BETWEEN (Rangos)
Selecciona valores dentro de un rango inclusivo (incluye los límites). Funciona con números y fechas.

WHERE precio BETWEEN 10 AND 20
WHERE fecha BETWEEN '2026-01-01' AND '2026-03-31'
*/

SELECT * FROM ventas WHERE fecha BETWEEN '2026-01-01' and '2026-04-01';

/* 
3. El operador IS NULL / IS NOT NULL
el NULL no es un valor, es la ausencia de valor, un vacio.
    Correcto: WHERE email IS NULL
    Incorrecto: WHERE email = NULL
el motor excluirá también a los usuarios que NULL en el campo buscado
*/

SELECT * FROM usuarios WHERE pais <> 'Mexico' -- ejemplo con exclusion
SELECT * FROM usuarios WHERE pais <> 'Mexico' OR pais IS NULL -- ejemplo con inclusion

SELECT nombres FROM clientes WHERE numero IS NULL;

-- Siempre asume que sí distinguen MAYUSCULAS y minusculas, para escribir código más robusto, o usa funciones para convertir todo a minúsculas.
-- lo anterior es exclusivo de las cláusulas de filtrado, WHERE, HAVING, JOIN.

-- Tema 8: ORDER BY (El toque final del reporte)
/* 
Se coloca al final del query.
    ASC (Ascendente)
    DESC (Descendente)

Ordernar por una o mas columnas, en caso de varias, la primera es el orden inicial, si hay varios resultasod parecidos, la segunda columna vuelve a ordenar
    Ejemplo: Ordenar por apellido de forma ascendente, y si hay varios "García", ordenarlos por nombre.

usar el número de la columna según el orden en el SELECT
    SELECT nombre, salario FROM empleados ORDER BY 2 DESC; (Ordena por el salario)

los valores NULL suelen aparecer primero o último
*/

SELECT columna1, columna2, columna3, columna4
FROM tabla
ORDER BY columna1 ASC, columna2 DESC, columna3 ASC;

SELECT * FROM empleados WHERE departamento = 'Finanzas' ORDER BY fecha_ingreso DESC;

SELECT nombre, fecha 
FROM eventos 
WHERE tipo = 'Concierto'
ORDER BY fecha DESC;

SELECT grado, grupo, nombre FROM alumnos ORDER BY grado ASC, nombre ASC;

-- Tema 9: LIMIT / TOP (Control de volumen)
-- MySQL, PostgreSQL, SQLite: Usan LIMIT al final.
SELECT * FROM ventas ORDER BY fecha DESC LIMIT 10;

-- SQL Server (T-SQL): Usa TOP al inicio.
SELECT TOP 10 * FROM ventas ORDER BY fecha DESC;

-- OFFSET (Saltar filas) no quieres los primeros 10, sino los siguientes 10 (del 11 al 20).
SELECT * FROM productos LIMIT 10 OFFSET 10;

/* 
Usar limit siempre con order by
la cláusula ORDER BY en SQL requiere obligatoriamente especificar al menos una columna, expresión o número de columna de la lista SELECT para definir el criterio de ordenación.
*/

SELECT * FROM configuracion_sistema ORDER BY 1 ASC LIMIT 5
SELECT nombre, precio FROM inmuebles ORDER BY precio DESC LIMIT 1
SELECT nombre, stock FROM productos WHERE stock > 0 ORDER BY precio ASC LIMIT 10
SELECT * FROM catalogo ORDER BY id ASC LIMIT 10 OFFSET 10

/* 
¿Cuántos tipos de datos existen?
    Numéricos: INT (enteros), DECIMAL/NUMERIC (dinero/precisión), FLOAT (científicos).
    Texto: CHAR (longitud fija), VARCHAR (longitud variable), TEXT (párrafos largos).
    Fecha/Hora: DATE (YYYY-MM-DD), DATETIME o TIMESTAMP (fecha y hora exacta).
    Binarios/Otros: BOOLEAN (true/false), BLOB (imágenes/archivos), JSON (estructuras de datos modernas).
Varian segun el MOTOR
*/

/* 
Primary Key (Llave Primaria): Es el identificador unico, no se puede repetir y no puede ser nulo. Identifica de forma única a un registro en su propia tabla.
Foreign Key (Llave Foránea): Es una columna que crea un vínculo entre dos tablas. Es una "copia" de la Primary Key de otra tabla.
                             En la tabla PEDIDOS, tienes un id_cliente. Ese id_cliente es una Foreign Key que apunta a la Primary Key de la tabla CLIENTES.
*/

-- Operaciones Matemáticas en select o where

SELECT precio * 1.16 AS precio_con_iva -- Multiplicación.
SELECT stock - unidades_vendidas --Resta.
SELECT (puntuacion1 + puntuacion2) / 2  --Promedio manual

-- Tema 10: Constraints (Restricciones de Integridad)

/* 
NOT NULL: Asegura que una columna no pueda quedar vacía.
UNIQUE: Asegura que todos los valores en una columna sean diferentes
PRIMARY KEY: Es la combinación de NOT NULL y UNIQUE. Solo puede haber una por tabla.
FOREIGN KEY: Asegura la "Integridad Referencial"
CHECK: Valida que el valor cumpla una condición específica.
       Ejemplo: CHECK (edad >= 18).
DEFAULT: Si no se proporciona un valor, la base de datos asigna uno automáticamente.
         Ejemplo: pais VARCHAR(20) DEFAULT 'México'.

priorizar el "Borrado Lógico" (cambiar un estatus a 'Inactivo') en lugar de borrar físicamente un registro, evitando eliminar miles de registros históricos
*/

CREATE TABLE suscripciones(
activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE cuentas_usuario(
id_usuario INT PRIMARY KEY,
username VARCHAR(50) UNIQUE
);

CREATE TABLE examenes(
nota INT CHECK (nota>= 0)
);

CREATE TABLE tiendas(
id_tienda INT primary key,
nombre VARCHAR(50) NOT NULL,
telefono INT UNIQUE,
pais VARCHAR(50) default 'Mexico'
);

CREATE TABLE autores(
id_autor INT PRIMARY KEY,
nombre VARCHAR(50) NOT NULL
);

CREATE TABLE libros(
id_libros INT PRIMARY KEY,
titulo VARCHAR(50) NOT NULL,
id_autor INT
FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
);
