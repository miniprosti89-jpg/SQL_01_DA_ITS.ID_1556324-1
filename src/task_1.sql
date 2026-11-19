-- Задание 1. Выборка стран с населением > 100 млн и долей пожилых людей > 10%
-- Сортировка по убыванию плотности населения, округленной до двух знаков

SELECT
    name,
    population,
    ROUND(CAST(density AS numeric), 2) AS density
FROM geo_info.countries
WHERE population > 100000000
  AND prop_population_65 > 0.1
ORDER BY density DESC;
