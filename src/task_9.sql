-- Представление для первой группы (только страновой уровень)
CREATE VIEW covid.daily_statistics_country_level AS
WITH country_first AS (
    SELECT c.id
    FROM geo_info.countries c
    JOIN covid.daily_statistics ds ON c.id = ds.country_id
    GROUP BY c.id
    HAVING COUNT(ds.region_id) = 0
)
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
        WHERE sub.country_id = d.country_id AND sub.observed_date < d.observed_date
    )
WHERE d.country_id IN (SELECT id FROM country_first)
ORDER BY d.country_id, d.observed_date;

-- Представление для второй группы (только региональный уровень, агрегировано по стране)
CREATE VIEW covid.daily_statistics_region_level AS
WITH country_second AS (
    SELECT c.id
    FROM geo_info.countries c
    JOIN covid.daily_statistics ds ON c.id = ds.country_id
    GROUP BY c.id
    HAVING COUNT(ds.region_id) = COUNT(*) AND COUNT(*) > 0
),
country_agg AS (
    SELECT
        country_id,
        observed_date,
        SUM(confirmed) AS confirmed_sum,
        SUM(deaths) AS deaths_sum
    FROM covid.daily_statistics
    WHERE country_id IN (SELECT id FROM country_second)
    GROUP BY country_id, observed_date
)
SELECT
    country_id,
    observed_date,
    confirmed_sum - LAG(confirmed_sum, 1, 0) OVER (PARTITION BY country_id ORDER BY observed_date) AS confirmed_by_day,
    deaths_sum - LAG(deaths_sum, 1, 0) OVER (PARTITION BY country_id ORDER BY observed_date) AS deaths_by_day
FROM country_agg
ORDER BY country_id, observed_date;

-- Представление для третьей группы (смешанный тип)
CREATE VIEW covid.daily_statistics_mix AS
WITH country_third AS (
    -- Страны, у которых есть и NULL, и NOT NULL в region_id
    SELECT DISTINCT c.id
    FROM geo_info.countries c
    JOIN covid.daily_statistics d1 ON c.id = d1.country_id AND d1.region_id IS NULL
    JOIN covid.daily_statistics d2 ON c.id = d2.country_id AND d2.region_id IS NOT NULL
),
-- Данные на уровне регионов (суммируем по стране и дате)
region_agg AS (
    SELECT
        country_id,
        observed_date,
        SUM(confirmed) AS confirmed_reg,
        SUM(deaths) AS deaths_reg
    FROM covid.daily_statistics
    WHERE country_id IN (SELECT id FROM country_third) AND region_id IS NOT NULL
    GROUP BY country_id, observed_date
),
-- Данные на уровне страны (без регионов)
country_agg_mix AS (
    SELECT
        country_id,
        observed_date,
        confirmed AS confirmed_cnt,
        deaths AS deaths_cnt
    FROM covid.daily_statistics
    WHERE country_id IN (SELECT id FROM country_third) AND region_id IS NULL
),
-- Объединяем, отдавая приоритет региональным данным (если есть)
unified AS (
    SELECT
        COALESCE(r.country_id, c.country_id) AS country_id,
        COALESCE(r.observed_date, c.observed_date) AS observed_date,
        COALESCE(r.confirmed_reg, c.confirmed_cnt) AS confirmed_total,
        COALESCE(r.deaths_reg, c.deaths_cnt) AS deaths_total
    FROM region_agg r
    FULL OUTER JOIN country_agg_mix c
        ON r.country_id = c.country_id AND r.observed_date = c.observed_date
)
-- Вычисляем ежедневные приросты
SELECT
    country_id,
    observed_date,
    confirmed_total - LAG(confirmed_total, 1, 0) OVER (PARTITION BY country_id ORDER BY observed_date) AS confirmed_by_day,
    deaths_total - LAG(deaths_total, 1, 0) OVER (PARTITION BY country_id ORDER BY observed_date) AS deaths_by_day
FROM unified
ORDER BY country_id, observed_date;