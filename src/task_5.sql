-- Задание 5. Список стран из первой группы (наблюдения ведутся только на уровне страны, region_id всегда NULL)

SELECT
    c.id,
    c.name
FROM geo_info.countries AS c
JOIN covid.daily_statistics AS ds
    ON c.id = ds.country_id
GROUP BY
    c.id,
    c.name
HAVING COUNT(ds.region_id) = 0
ORDER BY c.name;
