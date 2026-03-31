SELECT
    d.country_id,
    d.observed_date,
    d.confirmed - COALESCE(prev.confirmed, 0) AS confirmed_by_day,
    d.deaths - COALESCE(prev.deaths, 0) AS deaths_by_day
FROM covid.daily_statistics d
LEFT JOIN covid.daily_statistics prev ON
    d.country_id = prev.country_id
    AND prev.observed_date = (
        SELECT MAX(observed_date)
        FROM covid.daily_statistics sub
        WHERE sub.country_id = d.country_id
          AND sub.observed_date < d.observed_date
    )
WHERE d.country_id IN (
    -- подзапрос, возвращающий id стран первой группы (аналогично заданию 5)
    SELECT c.id
    FROM geo_info.countries c
    JOIN covid.daily_statistics ds ON c.id = ds.country_id
    GROUP BY c.id
    HAVING COUNT(ds.region_id) = 0
)
ORDER BY d.country_id, d.observed_date;