SELECT c.id, c.name
FROM geo_info.countries c
JOIN covid.daily_statistics d ON c.id = d.country_id
GROUP BY c.id, c.name
HAVING COUNT(d.region_id) = 0
ORDER BY c.name;