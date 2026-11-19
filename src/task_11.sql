-- Задание 11. Нарастающий итог подтвержденных случаев с помощью оконной функции
-- Расчет по таблице covid.daily_statistics_recalculated

SELECT
    country_id,
    observed_date,
    SUM(confirmed_by_day) OVER (
        PARTITION BY country_id
        ORDER BY observed_date
    ) AS confirmed_cumulative
FROM covid.daily_statistics_recalculated
ORDER BY
    country_id,
    observed_date;
