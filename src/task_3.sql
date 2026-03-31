SELECT DISTINCT c.id, c.name
FROM geo_info.countries c
JOIN covid.daily_statistics d1 ON c.id = d1.country_id AND d1.region_id IS NULL
JOIN covid.daily_statistics d2 ON c.id = d2.country_id AND d2.region_id IS NOT NULL
ORDER BY c.name;