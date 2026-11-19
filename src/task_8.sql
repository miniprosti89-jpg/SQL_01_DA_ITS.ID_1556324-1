-- Задание 8. Расчет ежедневных приростов для стран 3-й группы (смешанный уровень наблюдений)
-- Требования: использование временных таблиц (TEMP TABLE) для промежуточных шагов

-- Шаг 1. Временная таблица со списком стран 3-й группы
CREATE TEMP TABLE tmp_group3_countries AS
SELECT DISTINCT
    c.id
FROM geo_info.countries AS c
JOIN covid.daily_statistics AS ds1
    ON c.id = ds1.country_id AND ds1.region_id IS NULL
JOIN covid.daily_statistics AS ds2
    ON c.id = ds2.country_id AND ds2.region_id IS NOT NULL;

-- Шаг 2. Агрегация данных на уровне регионов (сумма по стране и дате)
CREATE TEMP TABLE tmp_group3_regional AS
SELECT
    country_id,
    observed_date,
    SUM(confirmed) AS confirmed_val,
    SUM(deaths) AS deaths_val
FROM covid.daily_statistics
WHERE country_id IN (SELECT id FROM tmp_group3_countries)
  AND region_id IS NOT NULL
GROUP BY
    country_id,
    observed_date;

-- Шаг 3. Данные на уровне страны (где region_id пустой)
CREATE TEMP TABLE tmp_group3_country AS
SELECT
    country_id,
    observed_date,
    confirmed AS confirmed_val,
    deaths AS deaths_val
FROM covid.daily_statistics
WHERE country_id IN (SELECT id FROM tmp_group3_countries)
  AND region_id IS NULL;

-- Шаг 4. Объединение регионального и странового уровней (приоритет региональным данным)
CREATE TEMP TABLE tmp_group3_unified AS
SELECT
    COALESCE(r.country_id, c.country_id) AS country_id,
    COALESCE(r.observed_date, c.observed_date) AS observed_date,
    COALESCE(r.confirmed_val, c.confirmed_val) AS confirmed_total,
    COALESCE(r.deaths_val, c.deaths_val) AS deaths_total
FROM tmp_group3_regional AS r
FULL OUTER JOIN tmp_group3_country AS c
    ON r.country_id = c.country_id
   AND r.observed_date = c.observed_date;

-- Шаг 5. Расчет суточных приростов через самосоединение
SELECT
    cur.country_id,
    cur.observed_date,
    cur.confirmed_total - COALESCE(prev.confirmed_total, 0) AS confirmed_by_day,
    cur.deaths_total - COALESCE(prev.deaths_total, 0) AS deaths_by_day
FROM tmp_group3_unified AS cur
LEFT JOIN tmp_group3_unified AS prev
    ON cur.country_id = prev.country_id
   AND cur.observed_date - 1 = prev.observed_date
ORDER BY
    cur.country_id,
    cur.observed_date;
