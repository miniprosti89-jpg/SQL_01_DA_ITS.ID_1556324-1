-- Создаём таблицу, объединяя три представления и заменяя отрицательные значения на 0
CREATE TABLE covid.daily_statistics_recalculated AS
SELECT
    country_id,
    observed_date,
    CASE WHEN confirmed_by_day < 0 THEN 0 ELSE confirmed_by_day END AS confirmed_by_day,
    CASE WHEN deaths_by_day < 0 THEN 0 ELSE deaths_by_day END AS deaths_by_day
FROM covid.daily_statistics_country_level
UNION ALL
SELECT
    country_id,
    observed_date,
    CASE WHEN confirmed_by_day < 0 THEN 0 ELSE confirmed_by_day END,
    CASE WHEN deaths_by_day < 0 THEN 0 ELSE deaths_by_day END
FROM covid.daily_statistics_region_level
UNION ALL
SELECT
    country_id,
    observed_date,
    CASE WHEN confirmed_by_day < 0 THEN 0 ELSE confirmed_by_day END,
    CASE WHEN deaths_by_day < 0 THEN 0 ELSE deaths_by_day END
FROM covid.daily_statistics_mix;

-- Опционально: добавим первичный ключ или индекс для производительности
-- ALTER TABLE covid.daily_statistics_recalculated ADD PRIMARY KEY (country_id, observed_date);