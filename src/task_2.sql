SELECT 'all' AS is_info_regions, COUNT(*) AS count_country FROM geo_info.countries
UNION
SELECT 'yes', COUNT(DISTINCT country_id) FROM geo_info.regions
UNION
SELECT 'no', COUNT(*) FROM geo_info.countries c
WHERE NOT EXISTS (SELECT 1 FROM geo_info.regions r WHERE r.country_id = c.id);