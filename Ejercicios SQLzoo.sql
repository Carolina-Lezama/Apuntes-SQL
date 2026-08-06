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

-- 1. Winners from 1950
SELECT yr, subject, winner
  FROM nobel
 WHERE yr = 1950

-- 2. 1962 Literature
SELECT winner
  FROM nobel
 WHERE yr = 1962
   AND subject = 'Literature'

-- 3. Albert Einstein
SELECT yr, subject
FROM nobel
WHERE winner = 'Albert Einstein'

-- 4. Recent Peace Prizes
SELECT winner
FROM nobel
WHERE subject = 'Peace' and yr > 1999

-- 5. Literature in the 1980's
SELECT yr, subject, winner
FROM nobel
WHERE subject = 'Literature ' and yr BETWEEN 1980 and 1989

-- 6. Only Presidents
SELECT * FROM nobel
 WHERE winner IN ('Theodore Roosevelt',
                  'Thomas Woodrow Wilson',
                  'Barack Obama',
                  'Jimmy Carter')

-- 7. John
SELECT winner FROM nobel
 WHERE winner LIKE 'John%'

-- 8. Chemistry and Physics from different years
SELECT yr, subject, winner
FROM nobel
WHERE (subject = 'Physics' and yr = 1980) or (subject = 'Chemistry' and yr = 1984)

-- 9. Exclude Chemists and Medics
SELECT yr, subject, winner
FROM nobel
WHERE yr = 1980 and subject NOT IN ('Chemistry', 'Medicine')

-- 10. Early Medicine, Late Literature
SELECT yr, subject, winner
FROM nobel
WHERE (subject = 'Medicine' and yr < 1910) or (subject = 'Literature' and yr >= 2004)

-- 11. Umlaut
SELECT *
FROM nobel
WHERE winner LIKE 'Peter Gr_nberg'

-- 12. Apostrophe
SELECT *
FROM nobel
WHERE winner LIKE 'Eugene o_neill'

-- 13. Knights of the realm
SELECT winner,	yr, subject
FROM nobel
WHERE winner LIKE 'Sir%'
ORDER BY yr DESC, winner

-- 14. Chemistry and Physics last
SELECT winner, subject
  FROM nobel
 WHERE yr = 1984
 ORDER BY subject, winner

-- 1. Bigger than Russia
SELECT name FROM world
  WHERE population >
     (SELECT population FROM world
      WHERE name='Russia')

-- 2. Richer than UK
SELECT name 
FROM world
WHERE continent='Europe' 
  and (gdp / population) >
    (SELECT gdp / population FROM world
    WHERE name='United Kingdom')

-- 3. Neighbours of Argentina and Australia
SELECT name, continent  
FROM world
WHERE continent IN 
(
SELECT continent
FROM world
WHERE name = 'Argentina' or name = 'Australia'
)
ORDER BY name

-- 4. Between Canada and Poland
SELECT name, population
FROM world
WHERE population >
(
SELECT population
FROM world
WHERE name = 'United Kingdom'
)
and population < (
SELECT population
FROM world
WHERE name = 'Germany' 
)

-- 5. Percentages of Germany
SELECT 
  name, 
  CONCAT(
    CAST( -- Convertir de un tipo de valor a otro
      ROUND(
        100 * population / (SELECT population FROM world WHERE name = 'Germany')
      ,0) 
    as int),
  '%')
FROM world
WHERE continent = 'Europe'

-- 6. Bigger than every country in Europe
SELECT name
FROM world
WHERE gdp > ALL(
    SELECT gdp
    FROM world
    WHERE continent = 'Europe' 
      AND gdp > 0
);