-- Задание 3. Список стран из третьей группы (смешанный уровень наблюдений: есть и страновые, и региональные)
-- Ограничение: использовать только операторы JOIN и WHERE (без GROUP BY, подзапросов в WHERE и т.д.)

SELECT DISTINCT
    c.id,
    c.name
FROM geo_info.countries AS c
JOIN covid.daily_statistics AS ds_country
    ON c.id = ds_country.country_id
JOIN covid.daily_statistics AS ds_region
    ON c.id = ds_region.country_id
WHERE ds_country.region_id IS NULL
  AND ds_region.region_id IS NOT NULL
ORDER BY c.name;
