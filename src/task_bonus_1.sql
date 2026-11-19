-- Бонусное задание 1. Определение дня с пиковым числом заболевших для каждой страны
-- Использование оконной функции ROW_NUMBER() для ранжирования дат по confirmed_by_day

WITH ranked_daily_peaks AS (
    SELECT
        c.name,
        r.observed_date,
        r.confirmed_by_day,
        ROW_NUMBER() OVER (
            PARTITION BY r.country_id
            ORDER BY r.confirmed_by_day DESC, r.observed_date ASC
        ) AS rn
    FROM covid.daily_statistics_recalculated AS r
    JOIN geo_info.countries AS c
        ON r.country_id = c.id
)
SELECT
    name,
    observed_date,
    confirmed_by_day
FROM ranked_daily_peaks
WHERE rn = 1
ORDER BY name;
