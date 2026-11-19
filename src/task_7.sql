-- Задание 7. Расчет ежедневных приростов для стран 2-й группы (только региональный уровень)
-- Требования: использование WITH для предварительной агрегации показателей по странам и датам

WITH group2_countries AS (
    -- Определение стран 2-й группы (все наблюдения содержат region_id)
    SELECT c.id
    FROM geo_info.countries AS c
    JOIN covid.daily_statistics AS ds ON c.id = ds.country_id
    GROUP BY c.id
    HAVING COUNT(ds.region_id) = COUNT(*)
       AND COUNT(*) > 0
),
daily_country_totals AS (
    -- Суммирование данных всех регионов по каждой стране на каждую дату
    SELECT
        country_id,
        observed_date,
        SUM(confirmed) AS confirmed_total,
        SUM(deaths) AS deaths_total
    FROM covid.daily_statistics
    WHERE country_id IN (SELECT id FROM group2_countries)
    GROUP BY
        country_id,
        observed_date
)
SELECT
    cur.country_id,
    cur.observed_date,
    cur.confirmed_total - COALESCE(prev.confirmed_total, 0) AS confirmed_by_day,
    cur.deaths_total - COALESCE(prev.deaths_total, 0) AS deaths_by_day
FROM daily_country_totals AS cur
LEFT JOIN daily_country_totals AS prev
    ON cur.country_id = prev.country_id
   AND cur.observed_date - 1 = prev.observed_date
ORDER BY
    cur.country_id,
    cur.observed_date;
