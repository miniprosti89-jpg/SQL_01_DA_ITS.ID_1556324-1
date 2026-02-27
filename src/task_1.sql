SELECT
    name,
    population,
    ROUND(density::numeric, 2) AS density
FROM geo_info.countries
WHERE population > 100000000
  AND prop_population_65 > 0.1
ORDER BY density DESC;