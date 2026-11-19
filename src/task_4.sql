-- Задание 4. Список стран из второй группы (наблюдения ведутся исключительно на уровне регионов)
-- Используется группировка данных: общее количество записей совпадает с числом записей с непустым region_id

SELECT
    c.id,
    c.name
FROM geo_info.countries AS c
JOIN covid.daily_statistics AS ds
    ON c.id = ds.country_id
GROUP BY
    c.id,
    c.name
HAVING COUNT(ds.region_id) = COUNT(*)
   AND COUNT(*) > 0
ORDER BY c.name;
