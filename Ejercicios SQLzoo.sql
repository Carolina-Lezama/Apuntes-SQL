-- 1. Introducing the world table of countries
SELECT population FROM world 
  WHERE name = 'Germany'

-- 2. Scandinavia
SELECT name, population FROM world
  WHERE name IN ('Sweden', 'Norway', 'Denmark');

-- 3. Just the right size
SELECT name, area FROM world
  WHERE area BETWEEN 200000 AND 250000 

-- 1. Introduction
SELECT name, continent, population FROM world

-- 2. Large Countries
SELECT name FROM world
WHERE population > 200000000

-- 3. Per capita GDP
SELECT name, (gdp / population) as result FROM world
WHERE population > 200000000

-- 4. South America In millions
SELECT name, population / 1000000 FROM world
WHERE continent = 'South America'

-- 5. France, Germany, Italy
SELECT name, population  FROM world
WHERE name IN ('France', 'Germany', 'Italy')

-- 6. United
SELECT name FROM world
WHERE name LIKE '%United%'

-- 7. Two ways to be big
SELECT name, population, area FROM world
WHERE area > 3000000 or population > 250000000

-- 8. One or the other (but not both)
SELECT name, population, area FROM world
WHERE (area > 3000000 OR population > 250000000) 
  AND NOT (area > 3000000 AND population > 250000000)

-- 9. Rounding
SELECT name, ROUND(population/1000000.0,2), ROUND(gdp/1000000000.0,2) FROM world
WHERE continent = 'South America'

-- 10. Trillion dollar economies
SELECT name, ROUND(gdp/population,-3) FROM world
WHERE gdp > 1000000000000
LIMIT 1000

/*
ROUND(x, 0): Redondea a las unidades 
ROUND(x, -1): Redondea a las decenas 
ROUND(x, -2): Redondea a las centenas 
ROUND(x, -3): Redondea a los millares 
*/

-- 12. Matching name and capital

SELECT name, capital
FROM world
WHERE LEFT(name,1) = LEFT(capital,1) AND name <> capital

/*
<> as the NOT EQUALS operator.
*/

-- 11. Name and capital have the same length
SELECT name, capital
  FROM world
 WHERE LENGTH(name) = LENGTH(capital)

-- 13. All the vowels
SELECT name
FROM world
WHERE name LIKE '%a%' 
  AND name LIKE '%e%' 
  AND name LIKE '%i%' 
  AND name LIKE '%o%' 
  AND name LIKE '%u%'
  AND name NOT LIKE '% %';