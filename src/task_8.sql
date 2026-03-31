CREATE TEMP TABLE mix_countries AS
SELECT DISTINCT c.id, c.name
FROM geo_info.countries c
JOIN covid.daily_statistics d1 ON c.id = d1.country_id AND d1.region_id IS NULL
JOIN covid.daily_statistics d2 ON c.id = d2.country_id AND d2.region_id IS NOT NULL
ORDER BY c.name;

CREATE TEMP TABLE aggregated_mix AS
SELECT
    country_id,
    observed_date,
    SUM(confirmed) AS confirmed_sum,
    SUM(deaths) AS deaths_sum
FROM covid.daily_statistics
WHERE country_id IN (SELECT id FROM mix_countries)
GROUP BY country_id, observed_date;  -- здесь суммируются и регионы, и страновые записи (если страновые - они одни, если регионы - их несколько)

-- Но! Если на одну дату есть и страновые, и региональные, SUM их сложит, что неправильно. Нужно сначала разделить.
-- Более корректно:
CREATE TEMP TABLE region_level_mix AS
SELECT country_id, observed_date, SUM(confirmed) AS confirmed_reg, SUM(deaths) AS deaths_reg
FROM covid.daily_statistics
WHERE country_id IN (SELECT id FROM mix_countries) AND region_id IS NOT NULL
GROUP BY country_id, observed_date;

CREATE TEMP TABLE country_level_mix AS
SELECT country_id, observed_date, confirmed AS confirmed_cnt, deaths AS deaths_cnt
FROM covid.daily_statistics
WHERE country_id IN (SELECT id FROM mix_countries) AND region_id IS NULL;

-- Затем объединить: COALESCE(confirmed_reg, confirmed_cnt) и т.д. Предпочтение регионам.
CREATE TEMP TABLE unified_mix AS
SELECT
    COALESCE(r.country_id, c.country_id) AS country_id,
    COALESCE(r.observed_date, c.observed_date) AS observed_date,
    COALESCE(r.confirmed_reg, c.confirmed_cnt) AS confirmed_total,
    COALESCE(r.deaths_reg, c.deaths_cnt) AS deaths_total
FROM region_level_mix r
FULL OUTER JOIN country_level_mix c ON r.country_id = c.country_id AND r.observed_date = c.observed_date;

-- Затем вычислить приросты (как в задании 6 или через LAG).