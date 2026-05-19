USE pitlane_reporting_db;

-- 1. City-Wise Most Popular Race Weekends Based on Ratings
SELECT 
    c.city,
    c.country,
    c.name AS circuit_name,
    t.full_date AS race_weekend,
    AVG(f.challenge_rating) AS avg_challenge_rating,
    AVG(f.enjoyment_rating) AS avg_enjoyment_rating,
    AVG(f.strategy_rating) AS avg_strategy_rating,
    COUNT(f.performance_id) AS total_ratings
FROM fact_race_performance f
JOIN dim_circuit c ON f.circuit_id = c.circuit_id
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY c.city, c.country, c.name, t.full_date
ORDER BY c.city, total_ratings DESC;

-- 2. Top 5 Drivers by Total Championship Points per Country
WITH DriverPoints AS (
    SELECT 
        d.name AS driver_name,
        d.constructor_name,
        d.nationality,
        SUM(f.grand_prix_points) AS total_championship_points,
        SUM(f.sprint_points) AS sprint_points,
        AVG(f.finish_position) AS avg_finishing_position
    FROM fact_race_performance f
    JOIN dim_driver d ON f.driver_id = d.driver_id
    GROUP BY d.driver_id, d.name, d.constructor_name, d.nationality
),
RankedDrivers AS (
    SELECT 
        driver_name,
        constructor_name,
        nationality,
        total_championship_points,
        sprint_points,
        avg_finishing_position,
        ROW_NUMBER() OVER (PARTITION BY nationality ORDER BY total_championship_points DESC) AS `rank`
    FROM DriverPoints
)
SELECT 
    driver_name,
    constructor_name,
    nationality,
    total_championship_points,
    sprint_points,
    avg_finishing_position
FROM RankedDrivers
WHERE `rank` <= 5;

-- 3. Monthly Race Ratings and Reward Trends
SELECT 
    t.month,
    t.year,
    AVG(f.challenge_rating) AS avg_challenge_rating,
    AVG(f.enjoyment_rating) AS avg_enjoyment_rating,
    SUM(f.grand_prix_points) AS total_grand_prix_points,
    SUM(f.sprint_points) AS total_sprint_points,
    AVG(f.avg_pit_stop_duration_sec) AS avg_pit_stop_duration
FROM fact_race_performance f
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY t.year, t.month
ORDER BY t.year, t.month;

-- 4. Driver Performance Summary
SELECT 
    d.name AS driver_name,
    d.constructor_name,
    SUM(CASE WHEN f.is_dnf = FALSE THEN 1 ELSE 0 END) AS total_races_completed,
    SUM(f.grand_prix_points) AS total_points_earned,
    SUM(f.sprint_points) AS total_sprint_points_earned,
    AVG(f.finish_position) AS avg_finishing_position,
    SUM(f.total_pit_stops) AS total_pit_stops,
    AVG(f.avg_tyre_stint_laps) AS avg_tyre_stint_length
FROM fact_race_performance f
JOIN dim_driver d ON f.driver_id = d.driver_id
GROUP BY d.driver_id, d.name, d.constructor_name
ORDER BY total_points_earned DESC;

-- 5. Monthly City-Based Driver Engagement
SELECT 
    c.city,
    t.month,
    t.year,
    COUNT(DISTINCT f.race_id) AS number_of_races_hosted,
    COUNT(DISTINCT f.driver_id) AS number_of_participating_drivers,
    (AVG(f.challenge_rating) + AVG(f.enjoyment_rating) + AVG(f.strategy_rating)) / 3 AS avg_race_rating,
    SUM(f.total_pit_stops) AS total_pit_stops
FROM fact_race_performance f
JOIN dim_circuit c ON f.circuit_id = c.circuit_id
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY c.city, t.year, t.month
ORDER BY t.year, t.month, c.city;

-- 6. Most Frequently Played Circuits with Strong Performance Indicators
SELECT 
    c.name AS circuit_name,
    c.city,
    c.country,
    COUNT(DISTINCT f.race_id) AS total_races_hosted,
    AVG(f.grand_prix_points) AS avg_points,
    (AVG(f.challenge_rating) + AVG(f.enjoyment_rating) + AVG(f.strategy_rating)) / 3 AS avg_rating,
    AVG(f.avg_pit_stop_duration_sec) AS avg_pit_stop_duration
FROM fact_race_performance f
JOIN dim_circuit c ON f.circuit_id = c.circuit_id
GROUP BY c.circuit_id, c.name, c.city, c.country
HAVING 
    avg_points > 15 
    AND avg_pit_stop_duration < 4 
    AND avg_rating > 4
ORDER BY total_races_hosted DESC;
