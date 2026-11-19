-- Задание 2. Подсчет количества стран по наличию информации о регионах
-- Используются операторы JOIN и UNION, порядок вывода строго all -> yes -> no

SELECT
    is_info_regions,
    count_country
FROM (
    -- 1. Все страны в базе данных
    SELECT
        1 AS sort_idx,
        'all' AS is_info_regions,
        COUNT(c.id) AS count_country
    FROM geo_info.countries AS c

    UNION

    -- 2. Страны, по которым есть информация о регионах
    SELECT
        2 AS sort_idx,
        'yes' AS is_info_regions,
        COUNT(DISTINCT r.country_id) AS count_country
    FROM geo_info.regions AS r

    UNION

    -- 3. Страны, по которым регионы отсутствуют (LEFT JOIN с фильтром по NULL)
    SELECT
        3 AS sort_idx,
        'no' AS is_info_regions,
        COUNT(c.id) AS count_country
    FROM geo_info.countries AS c
    LEFT JOIN geo_info.regions AS r
        ON c.id = r.country_id
    WHERE r.id IS NULL
) AS region_coverage
ORDER BY sort_idx;
