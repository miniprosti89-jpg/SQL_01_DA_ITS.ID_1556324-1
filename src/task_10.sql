-- Задание 10. Создание физической таблицы covid.daily_statistics_recalculated
-- Объединение трех представлений и замена отрицательных значений на 0 (NULL не изменяются)

DROP TABLE IF EXISTS covid.daily_statistics_recalculated;

CREATE TABLE covid.daily_statistics_recalculated AS
SELECT
    country_id,
    observed_date,
    CASE
        WHEN confirmed_by_day < 0 THEN 0
        ELSE confirmed_by_day
    END AS confirmed_by_day,
    CASE
        WHEN deaths_by_day < 0 THEN 0
        ELSE deaths_by_day
    END AS deaths_by_day
FROM (
    SELECT country_id, observed_date, confirmed_by_day, deaths_by_day
    FROM covid.daily_statistics_country_level

    UNION ALL

    SELECT country_id, observed_date, confirmed_by_day, deaths_by_day
    FROM covid.daily_statistics_region_level

    UNION ALL

    SELECT country_id, observed_date, confirmed_by_day, deaths_by_day
    FROM covid.daily_statistics_mix
) AS all_recalculated;
