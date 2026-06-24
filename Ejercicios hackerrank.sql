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

-- Query a count of the number of cities in CITY having a Population larger than 100000
SELECT COUNT(*)
FROM CITY
WHERE POPULATION > 100000

-- Query the total population of all cities in CITY where District is California.
SELECT SUM(POPULATION)
FROM CITY
WHERE DISTRICT = "California"

-- Query the average population of all cities in CITY where District is California.
SELECT AVG(POPULATION)
FROM CITY
WHERE DISTRICT = "California"

-- Query the average population for all cities in CITY, rounded down to the nearest integer.
SELECT FLOOR(AVG(POPULATION))
FROM CITY;

-- Query the sum of the populations for all Japanese cities in CITY. The COUNTRYCODE for Japan is JPN.
SELECT SUM(POPULATION)
FROM CITY
WHERE COUNTRYCODE = "JPN";

-- Query the difference between the maximum and minimum populations in CITY.
SELECT MAX(POPULATION) - MIN(POPULATION)
FROM CITY

/*
Samantha was tasked with calculating the average monthly salaries for all employees in the EMPLOYEES table, but did not realize her keyboard's 0 key was broken until after completing the calculation. 
She wants your help finding the difference between her miscalculation (using salaries with any zeros removed), and the actual average salary.
Write a query calculating the amount of error (i.e.: ACTUAL - MISCALCULATED average monthly salaries), and round it up to the next integer.
*/
SELECT CEIL(AVG(Salary) - AVG(CAST(REPLACE(Salary, '0', '') AS DECIMAL)))
FROM EMPLOYEES 

/*
Given the CITY and COUNTRY tables, query the names of all cities where the CONTINENT is 'Africa'.
Note: CITY.CountryCode and COUNTRY.Code are matching key columns.
*/
SELECT ci.NAME
FROM city ci
INNER JOIN country co
ON ci.COUNTRYCODE = co.CODE
WHERE co.CONTINENT = 'Africa'


/*
Given the CITY and COUNTRY tables, query the names of all the continents (COUNTRY.Continent) and their respective average city populations (CITY.Population) rounded down to the nearest integer.
Note: CITY.CountryCode and COUNTRY.Code are matching key columns.
*/
SELECT co.CONTINENT, FLOOR(AVG(ci.POPULATION))
FROM city ci
INNER JOIN country co
ON ci.COUNTRYCODE = co.CODE
GROUP BY co.CONTINENT

/*
Write a query identifying the type of each record in the TRIANGLES table using its three side lengths. Output one of the following statements for each record in the table:
Equilateral: It's a triangle with  sides of equal length.
Isosceles: It's a triangle with  sides of equal length.
Scalene: It's a triangle with  sides of differing lengths.
Not A Triangle: The given values of A, B, and C don't form a triangle.
*/
SELECT
    CASE
        WHEN A + B <= C OR A + C <= B OR B + C <= A
            THEN 'Not A Triangle'
        WHEN A = B AND B = C
            THEN 'Equilateral'
        WHEN A = B OR B = C OR A = C
            THEN 'Isosceles'
        ELSE 'Scalene'
    END AS TriangleType
FROM TRIANGLES;

/*
Write a query to find the maximum total earnings for all employees as well as the total number of employees who have maximum total earnings.
*/
SELECT (salary * months) AS earnings, COUNT(*)
FROM Employee
GROUP BY earnings
ORDER BY earnings DESC 
LIMIT 1;     

/*
Query the following two values from the STATION table:
The sum of all values in LAT_N rounded to a scale of  decimal places.
The sum of all values in LONG_W rounded to a scale of  decimal places.
*/
SELECT ROUND(SUM(LAT_N),2), ROUND(SUM(LONG_W),2)
FROM STATION;

/*
Query the sum of Northern Latitudes (LAT_N) from STATION having values greater than  and less than. 
Truncate your answer to  decimal places.
*/
SELECT TRUNCATE(SUM(LAT_N), 4) -- TRUNCATE(número_a_cortar, cuántos_decimales_dejo)
FROM STATION
WHERE LAT_N > 38.7880 AND LAT_N < 137.2345;

/*
Query the greatest value of the Northern Latitudes (LAT_N) from STATION that is less than.
Truncate your answer to  decimal places.
*/
SELECT TRUNCATE(MAX(LAT_N),4)
FROM STATION
WHERE LAT_N < 137.2345
LIMIT 1;

/*
Query the Western Longitude (LONG_W) for the largest Northern Latitude (LAT_N) in STATION that is less than . Round your answer to  decimal places.
*/
SELECT ROUND(LONG_W ,4)
FROM STATION
WHERE LAT_N < 137.2345
ORDER BY LAT_N DESC
LIMIT 1;

/*
Query the smallest Northern Latitude (LAT_N) from STATION that is greater than.Round your answer to  decimal places.
*/
SELECT ROUND(LAT_N,4)
FROM STATION
WHERE LAT_N >38.7780
ORDER BY LAT_N ASC
LIMIT 1;

/*
Query the Western Longitude (LONG_W)where the smallest Northern Latitude (LAT_N) in STATION is greater than. Round your answer to  decimal places.
*/
SELECT ROUND(LONG_W,4)
FROM STATION
WHERE LAT_N > 38.7780
ORDER BY LAT_N ASC
LIMIT 1;

/*
Query an alphabetically ordered list of all names in OCCUPATIONS, immediately followed by the first letter of each profession as a parenthetical (i.e.: enclosed in parentheses). For example: AnActorName(A), ADoctorName(D), AProfessorName(P), and ASingerName(S).
Query the number of ocurrences of each occupation in OCCUPATIONS. Sort the occurrences in ascending order, and output them in the following format:
There are a total of [occupation_count] [occupation]s.
where [occupation_count] is the number of occurrences of an occupation in OCCUPATIONS and [occupation] is the lowercase occupation name. If more than one Occupation has the same [occupation_count], they should be ordered alphabetically.
*/

SELECT 
    CONCAT(Name, '(',  LEFT(Occupation, 1) , ')') AS resultado
FROM OCCUPATIONS
ORDER BY Name ASC;

SELECT
    CONCAT('There are a total of ', COUNT(Occupation), ' ', LOWER(Occupation),'s.' ) AS occupation_count
FROM OCCUPATIONS
GROUP BY Occupation
ORDER BY occupation_count ASC, Occupation ASC;

/*
Pivot the Occupation column in OCCUPATIONS so that each Name is sorted alphabetically and displayed underneath its corresponding Occupation. The output should consist of four columns (Doctor, Professor, Singer, and Actor) in that specific order, with their respective names listed alphabetically under each column.
*/
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

/*
Given the CITY and COUNTRY tables, query the sum of the populations of all cities where the CONTINENT is 'Asia'.
Note: CITY.CountryCode and COUNTRY.Code are matching key columns.
*/

SELECT SUM(ci.population)
FROM CITY ci
INNER JOIN COUNTRY co
    ON  ci.CountryCode  = co.Code
WHERE co.continent = 'Asia';

/*
Ketty gives Eve a task to generate a report containing three columns: Name, Grade and Mark. 
Ketty doesn't want the NAMES of those students who received a grade lower than 8. 
The report must be in descending order by grade -- i.e. higher grades are entered first. 
If there is more than one student with the same grade (8-10) assigned to them, order those particular students by their name alphabetically. 
Finally, if the grade is lower than 8, use "NULL" as their name and list them by their grades in descending order. 
If there is more than one student with the same grade (1-7) assigned to them, order those particular students by their marks in ascending order.
*/

SELECT 
    CASE 
        WHEN gr.Grade >= 8 THEN st.Name 
        ELSE 'NULL' 
    END AS Name,
    gr.Grade, 
    st.Marks
FROM Students st
INNER JOIN Grades gr
    ON st.Marks BETWEEN gr.min_mark AND gr.max_mark
ORDER BY gr.Grade DESC, Name ASC, st.Marks ASC; 

/*
Julia just finished conducting a coding contest, and she needs your help assembling the leaderboard! Write a query to print the respective hacker_id and name of hackers who achieved full scores for more than one challenge. 
Order your output in descending order by the total number of challenges in which the hacker earned a full score. 
If more than one hacker received full scores in same number of challenges, then sort them by ascending hacker_id.
*/

SELECT
    s.hacker_id ,
    h.name
FROM Submissions s
INNER JOIN Challenges c
    ON s.challenge_id = c.challenge_id
INNER JOIN Difficulty d
    ON c.difficulty_level = d.difficulty_level
INNER JOIN Hackers h
    ON s.hacker_id = h.hacker_id
WHERE s.score = d.score
GROUP BY s.hacker_id, h.name
HAVING COUNT(*) > 1 
ORDER BY COUNT(*) DESC, s.hacker_id ASC;

/*
Harry Potter and his friends are at Ollivander's with Ron, finally replacing Charlie's old broken wand.
Hermione decides the best way to choose is by determining the minimum number of gold galleons needed to buy each non-evil wand of high power and age. 
Write a query to print the id, age, coins_needed, and power of the wands that Ron's interested in, sorted in order of descending power. 
If more than one wand has same power, sort the result in order of descending age.
*/

WITH agrupamiento AS (
    SELECT
    w.id,
    ROW_NUMBER() OVER(PARTITION BY  w.power, wp.age ORDER BY w.coins_needed ASC ) AS minimo,
    wp.age,
    w.coins_needed,
    w.power
FROM Wands w
INNER JOIN Wands_Property wp
    ON w.code = wp.code
WHERE wp.is_evil = 0
)

SELECT
    id,
    age,
    coins_needed,
    power
FROM agrupamiento
WHERE minimo = 1
ORDER BY power DESC, age DESC

/*
Julia asked her students to create some coding challenges. 
Write a query to print the hacker_id, name, and the total number of challenges created by each student. 
Sort your results by the total number of challenges in descending order. 
If more than one student created the same number of challenges, then sort the result by hacker_id. 
If more than one student created the same number of challenges and the count is less than the maximum number of challenges created, then exclude those students from the result.
*/

WITH Conteo_Base AS (
    SELECT 
        h.hacker_id, 
        h.name, 
        COUNT(c.challenge_id) AS total_retos
    FROM Hackers h
    INNER JOIN Challenges c ON h.hacker_id = c.hacker_id
    GROUP BY h.hacker_id, h.name
),

Analisis_Ventanas AS (
    -- FASE 2: Lee del CTE anterior y usa tus ventanas
    SELECT 
        hacker_id,
        name,
        total_retos,
        MAX(total_retos) OVER() AS maximo_historico,
        COUNT(hacker_id) OVER(PARTITION BY total_retos) AS empates
    FROM Conteo_Base
)

SELECT hacker_id, name, total_retos
FROM Analisis_Ventanas
WHERE total_retos = maximo_historico OR empates = 1
ORDER BY total_retos DESC, hacker_id ASC;

/*
You are given a table, BST, containing two columns: N and P, where N represents the value of a node in Binary Tree, and P is the parent of N.
Write a query to find the node type of Binary Tree ordered by the value of the node. Output one of the following for each node:
Root: If node is root node.
Leaf: If node is leaf node.
Inner: If node is neither root nor leaf node.
*/

SELECT
    N,
    CASE
        WHEN P IS NULL
            THEN 'Root'
        WHEN N NOT IN (SELECT P FROM BST WHERE P IS NOT NULL)
            THEN 'Leaf'
        WHEN N IN (SELECT P FROM BST)
            THEN 'Inner'
        ELSE 'unkown'
    END AS type
FROM BST
ORDER BY N

/*
Given the table schemas below, write a query to print the company_code, founder name, total number of lead managers, total number of senior managers, total number of managers, and total number of employees. 
Order your output by ascending company_code.
Note:
The tables may contain duplicate records.
The company_code is string, so the sorting should not be numeric. 
For example, if the company_codes are C_1, C_2, and C_10, then the ascending company_codes will be C_1, C_10, and C_2.
*/

SELECT
    c.company_code,
    c.founder, 
    COUNT(DISTINCT l.lead_manager_code) AS total_lead_m, 
    COUNT(DISTINCT s.senior_manager_code) AS total_senior_m,
    COUNT(DISTINCT m.manager_code) AS total_manager,
    COUNT(DISTINCT e.employee_code ) AS total_employee 
FROM Company c
LEFT JOIN Lead_Manager l
    ON c.company_code = l.company_code
LEFT JOIN Senior_Manager s
    ON c.company_code = s.company_code
LEFT JOIN Manager m
    ON c.company_code = m.company_code
LEFT JOIN Employee e
    ON c.company_code = e.company_code
GROUP BY c.company_code, c.founder
ORDER BY c.company_code ASC

