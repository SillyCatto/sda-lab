# Expected Query Results

This file lists the expected results for each query in `lab-2/task5.sql` based on the database seed values.

## 1. City-Wise Most Popular Race Weekends Based on Ratings

```sql
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
```

| city | country | circuit_name | race_weekend | avg_challenge_rating | avg_enjoyment_rating | avg_strategy_rating | total_ratings |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Jeddah | Saudi Arabia | Jeddah Corniche Circuit | 2024-03-09 | 3.666667 | 3.666667 | 3.666667 | 6 |
| Melbourne | Australia | Albert Park Circuit | 2024-03-24 | 4.166667 | 3.333333 | 3.333333 | 6 |
| Monaco | Monaco | Circuit de Monaco | 2024-05-26 | 4 | 3.666667 | 3.666667 | 6 |
| Sakhir | Bahrain | Bahrain International Circuit | 2024-03-02 | 3.5 | 3.666667 | 3.333333 | 6 |

## 2. Top 5 Drivers by Total Championship Points per Country

```sql
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
```

| driver_name | constructor_name | nationality | total_championship_points | sprint_points | avg_finishing_position |
| --- | --- | --- | --- | --- | --- |
| George Russell | Mercedes-AMG Petronas | British | 47 | 0 | 4.25 |
| Lewis Hamilton | Mercedes-AMG Petronas | British | 43 | 18 | 2.5 |
| Max Verstappen | Oracle Red Bull Racing | Dutch | 80 | 0 | 2 |
| Sergio Perez | Oracle Red Bull Racing | Mexican | 38 | 0 | 3 |
| Charles Leclerc | Scuderia Ferrari | Monegasque | 80 | 0 | 2 |
| Carlos Sainz | Scuderia Ferrari | Spanish | 46 | 0 | 4.5 |

## 3. Monthly Race Ratings and Reward Trends

```sql
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
```

| month | year | avg_challenge_rating | avg_enjoyment_rating | total_grand_prix_points | total_sprint_points | avg_pit_stop_duration |
| --- | --- | --- | --- | --- | --- | --- |
| 3 | 2024 | 3.777778 | 3.555556 | 246 | 18 | 2.587188 |
| 5 | 2024 | 4 | 3.666667 | 88 | 0 | 2.521667 |

## 4. Driver Performance Summary

```sql
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
```

| driver_name | constructor_name | total_races_completed | total_points_earned | total_sprint_points_earned | avg_finishing_position | total_pit_stops | avg_tyre_stint_length |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Max Verstappen | Oracle Red Bull Racing | 4 | 80 | 0 | 2 | 7 | 22.5 |
| Charles Leclerc | Scuderia Ferrari | 4 | 80 | 0 | 2 | 7 | 22.5 |
| George Russell | Mercedes-AMG Petronas | 4 | 47 | 0 | 4.25 | 7 | 22.5 |
| Carlos Sainz | Scuderia Ferrari | 4 | 46 | 0 | 4.5 | 7 | 22.5 |
| Lewis Hamilton | Mercedes-AMG Petronas | 3 | 43 | 18 | 2.5 | 5 | 23.89 |
| Sergio Perez | Oracle Red Bull Racing | 3 | 38 | 0 | 3 | 5 | 23.89 |

## 5. Monthly City-Based Driver Engagement

```sql
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
```

| city | month | year | number_of_races_hosted | number_of_participating_drivers | avg_race_rating | total_pit_stops |
| --- | --- | --- | --- | --- | --- | --- |
| Jeddah | 3 | 2024 | 1 | 6 | 3.666667 | 12 |
| Melbourne | 3 | 2024 | 1 | 6 | 3.611111 | 8 |
| Sakhir | 3 | 2024 | 1 | 6 | 3.5 | 12 |
| Monaco | 5 | 2024 | 1 | 6 | 3.777778 | 6 |

## 6. Most Frequently Played Circuits with Strong Performance Indicators

```sql
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
```

| circuit_name | city | country | total_races_hosted | avg_points | avg_rating | avg_pit_stop_duration |
| --- | --- | --- | --- | --- | --- | --- |
*(No rows returned for Query 6 due to average points per driver per race constraints in HAVING clause)*
