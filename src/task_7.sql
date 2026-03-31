WITH country_agg AS (
    SELECT country_id, observed_date,
           SUM(confirmed) AS confirmed_sum,
           SUM(deaths) AS deaths_sum
    FROM covid.daily_statistics
    WHERE country_id IN ( -- подзапрос для второй группы
        SELECT c.id FROM geo_info.countries c
        JOIN covid.daily_statistics ds ON c.id = ds.country_id
        GROUP BY c.id
        HAVING COUNT(ds.region_id) = COUNT(*) AND COUNT(*) > 0
    )
    GROUP BY country_id, observed_date
)