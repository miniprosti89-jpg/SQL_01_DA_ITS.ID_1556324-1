-- Задание 9. Создание трех представлений (VIEW) для каждой группы наблюдений

-- 1. Представление для первой группы (только страновой уровень)
CREATE OR REPLACE VIEW covid.daily_statistics_country_level AS
WITH group1_countries AS (
    SELECT c.id
    FROM geo_info.countries AS c
    JOIN covid.daily_statistics AS ds ON c.id = ds.country_id
    GROUP BY c.id
    HAVING COUNT(ds.region_id) = 0
)
SELECT
    cur.country_id,
    cur.observed_date,
    cur.confirmed - COALESCE(prev.confirmed, 0) AS confirmed_by_day,
    cur.deaths - COALESCE(prev.deaths, 0) AS deaths_by_day
FROM covid.daily_statistics AS cur
LEFT JOIN covid.daily_statistics AS prev
    ON cur.country_id = prev.country_id
   AND cur.observed_date - 1 = prev.observed_date
WHERE cur.country_id IN (SELECT id FROM group1_countries)
ORDER BY
    cur.country_id,
    cur.observed_date;


-- 2. Представление для второй группы (только региональный уровень)
CREATE OR REPLACE VIEW covid.daily_statistics_region_level AS
WITH group2_countries AS (
    SELECT c.id
    FROM geo_info.countries AS c
    JOIN covid.daily_statistics AS ds ON c.id = ds.country_id
    GROUP BY c.id
    HAVING COUNT(ds.region_id) = COUNT(*)
       AND COUNT(*) > 0
),
daily_country_totals AS (
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


-- 3. Представление для третьей группы (смешанный уровень)
CREATE OR REPLACE VIEW covid.daily_statistics_mix AS
WITH group3_countries AS (
    SELECT DISTINCT c.id
    FROM geo_info.countries AS c
    JOIN covid.daily_statistics AS ds1
        ON c.id = ds1.country_id AND ds1.region_id IS NULL
    JOIN covid.daily_statistics AS ds2
        ON c.id = ds2.country_id AND ds2.region_id IS NOT NULL
),
regional_summary AS (
    SELECT
        country_id,
        observed_date,
        SUM(confirmed) AS confirmed_val,
        SUM(deaths) AS deaths_val
    FROM covid.daily_statistics
    WHERE country_id IN (SELECT id FROM group3_countries)
      AND region_id IS NOT NULL
    GROUP BY
        country_id,
        observed_date
),
country_summary AS (
    SELECT
        country_id,
        observed_date,
        confirmed AS confirmed_val,
        deaths AS deaths_val
    FROM covid.daily_statistics
    WHERE country_id IN (SELECT id FROM group3_countries)
      AND region_id IS NULL
),
unified_totals AS (
    SELECT
        COALESCE(r.country_id, c.country_id) AS country_id,
        COALESCE(r.observed_date, c.observed_date) AS observed_date,
        COALESCE(r.confirmed_val, c.confirmed_val) AS confirmed_total,
        COALESCE(r.deaths_val, c.deaths_val) AS deaths_total
    FROM regional_summary AS r
    FULL OUTER JOIN country_summary AS c
        ON r.country_id = c.country_id
       AND r.observed_date = c.observed_date
)
SELECT
    cur.country_id,
    cur.observed_date,
    cur.confirmed_total - COALESCE(prev.confirmed_total, 0) AS confirmed_by_day,
    cur.deaths_total - COALESCE(prev.deaths_total, 0) AS deaths_by_day
FROM unified_totals AS cur
LEFT JOIN unified_totals AS prev
    ON cur.country_id = prev.country_id
   AND cur.observed_date - 1 = prev.observed_date
ORDER BY
    cur.country_id,
    cur.observed_date;
