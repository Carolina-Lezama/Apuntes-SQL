SELECT * From CITY WHERE POPULATION >100000 AND COUNTRYCODE = 'USA';

SELECT * From CITY;

SELECT * From CITY WHERE ID = 1661;

CREATE TABLE libros(
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(30) NOT NULL,
    ano_publicacion INT CHECK (ano_publicacion>0)
);

INSERT INTO libros (titulo, ano_publicacion)
VALUES 
('Harry potter', 1920),
('Caperucita roja', 2025),
('Los 3 cerditos', 2052),
('El principito', 2040),
('Los 3 mosqueteros', 1100);

SELECT * 
FROM libros 
WHERE ano_publicacion > 2020 
ORDER BY ano_publicacion DESC 
LIMIT 3;

SELECT * FROM CITY WHERE COUNTRYCODE = 'JPN';

SELECT NAME FROM CITY WHERE COUNTRYCODE = 'JPN';

SELECT CITY, STATE FROM STATION;

SELECT DISTINCT CITY
FROM STATION
WHERE MOD(ID, 2) = 0; --numeros pares

SELECT NAME 
FROM CITY 
WHERE POPULATION > 120000 AND COUNTRYCODE = 'USA';

-- ¿Cuántos valores repetidos hay?
SELECT COUNT(CITY) - COUNT(DISTINCT CITY) AS diferencia 
FROM STATION;
/*
the difference between the total number of CITY entries in the table and the number of distinct CITY entries in the table.
*/

-- list of CITY names starting with vowels (a, e, i, o, or u) from STATION. Your result cannot contain duplicates
SELECT DISTINCT CITY FROM STATION WHERE CITY LIKE 'A%'
   OR CITY LIKE 'E%'
   OR CITY LIKE 'I%'
   OR CITY LIKE 'O%'
   OR CITY LIKE 'U%';

-- Query the two cities in STATION with the shortest and longest CITY names, as well as their respective lengths (i.e.: number of characters in the name).
SELECT *
FROM
(
    SELECT CITY, LENGTH(CITY) AS LEN
    FROM STATION
    ORDER BY LENGTH(CITY), CITY
    FETCH FIRST 1 ROW ONLY -- = LIMIT 1; sirven para lo mismo
) A --son alias de subconsulta (nombres temporales para tablas derivadas).

UNION ALL

SELECT *
FROM
(
    SELECT CITY, LENGTH(CITY) AS LEN
    FROM STATION
    ORDER BY LENGTH(CITY) DESC, CITY
    FETCH FIRST 1 ROW ONLY
) B; --son alias de subconsulta (nombres temporales para tablas derivadas).

/*
Cuando una subconsulta aparece en FROM, SQL la trata como si fuera una tabla temporal.
Y toda “tabla” en FROM normalmente necesita nombre.
*/

SELECT id_usuario, COUNT(*) AS inicio_sesion
FROM accesos
WHERE id_usuario > 100 -- descarta esos usuarios antes de agrupar
GROUP BY id_usuario
HAVING COUNT(*) > 20 
ORDER BY inicio_sesion DESC;

SELECT *
FROM productos
WHERE nombre LIKE '%Pro%' AND precio BETWEEN 500 AND 1500
ORDER BY precio 
LIMIT 5;

-- Query the list of CITY names from STATION which have vowels (i.e., a, e, i, o, and u) as both their first and last characters. Your result cannot contain duplicates.
SELECT DISTINCT CITY 
FROM STATION 
WHERE UPPER(SUBSTR(CITY, 1, 1)) IN ('A','E','I','O','U')
    AND UPPER(SUBSTR(CITY, LENGTH(CITY)), 1) IN ('A','E','I','O','U');
    --LENGTH(CITY)) = -1 , no todos los motores de base de datos lo permiten

-- Query the list of CITY names from STATION that do not start with vowels. Your result cannot contain duplicates.
SELECT DISTINCT CITY 
FROM STATION 
WHERE UPPER(SUBSTR(CITY, 1, 1)) NOT IN ('A','E','I','O','U');

-- Query the list of CITY names from STATION that do not end with vowels. Your result cannot contain duplicates.
SELECT DISTINCT CITY
FROM STATION
WHERE UPPER(SUBSTR(CITY, LENGTH(CITY), 1)) NOT IN ('A','E','I','O','U');

-- Query the list of CITY names from STATION that either do not start with vowels or do not end with vowels. Your result cannot contain duplicates.
SELECT DISTINCT CITY
FROM STATION
WHERE UPPER(SUBSTR(CITY, 1, 1)) NOT IN ('A','E','I','O','U')
    AND UPPER(SUBSTR(CITY, -1, 1)) NOT IN ('A','E','I','O','U');

/*
Query the Name of any student in STUDENTS who scored higher than 75 Marks. 
Order your output by the last three characters of each name.
If two or more students both have names ending in the same last three characters (i.e.: Bobby, Robby, etc.), secondary sort them by ascending ID.
*/
SELECT Name
FROM STUDENTS 
WHERE Marks > 75
ORDER BY SUBSTR(Name, -3), ID ASC;

-- Write a query that prints a list of employee names (i.e.: the name attribute) from the Employee table in alphabetical order.
SELECT name
FROM Employee 
ORDER BY name;

/*
Write a query that prints a list of employee names (i.e.: the name attribute) for employees in Employee having a salary greater than 2000 per month who have been employees for less than 10 months. 
Sort your result by ascending employee_id.
*/
SELECT name
FROM Employee 
WHERE salary > 2000
GROUP BY employee_id, name, months
HAVING months < 10
ORDER BY employee_id ASC;

