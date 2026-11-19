-- Задание 6. Расчет ежедневных приростов заболевших и умерших для стран 1-й группы
-- Требования: подзапрос с IN для фильтрации стран 1-й группы, самосоединение (LEFT JOIN)

SELECT
    cur.country_id,
    cur.observed_date,
    cur.confirmed - COALESCE(prev.confirmed, 0) AS confirmed_by_day,
    cur.deaths - COALESCE(prev.deaths, 0) AS deaths_by_day
FROM covid.daily_statistics AS cur
LEFT JOIN covid.daily_statistics AS prev
    ON cur.country_id = prev.country_id
   AND cur.observed_date - 1 = prev.observed_date
WHERE cur.country_id IN (
    -- Подзапрос: определение стран 1-й группы
    SELECT c.id
    FROM geo_info.countries AS c
    JOIN covid.daily_statistics AS ds ON c.id = ds.country_id
    GROUP BY c.id
    HAVING COUNT(ds.region_id) = 0
)
ORDER BY
    cur.country_id,
    cur.observed_date;
