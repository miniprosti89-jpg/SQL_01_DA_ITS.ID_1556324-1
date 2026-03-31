-- Вычисляем нарастающий итог заболевших по дням для каждой страны
SELECT
    country_id,
    observed_date,
    SUM(confirmed_by_day) OVER (PARTITION BY country_id ORDER BY observed_date) AS confirmed_cumulative
FROM covid.daily_statistics_recalculated
ORDER BY country_id, observed_date;