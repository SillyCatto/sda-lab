USE pitlane_reporting_db;

DELIMITER //

DROP PROCEDURE IF EXISTS sp_run_etl_pipeline //

CREATE PROCEDURE sp_run_etl_pipeline()
BEGIN
    -- populating dim tables

    -- Load from race_weekend dates
    -- Ignores dates that already exist
    INSERT INTO dim_time (full_date, day, month, quarter, weekday, year, weekend_flag)
    SELECT DISTINCT 
        DATE(race_date),
        DAY(race_date),
        MONTH(race_date),
        QUARTER(race_date),
        DAYOFWEEK(race_date),
        YEAR(race_date),
        IF(DAYOFWEEK(race_date) IN (1, 7), TRUE, FALSE) -- 1=Sunday, 7=Saturday
    FROM sda_lab1.race_weekend
    WHERE race_date IS NOT NULL
      AND DATE(race_date) NOT IN (SELECT full_date FROM dim_time);

    -- Load dim_circuit
    INSERT IGNORE INTO dim_circuit (circuit_id, name, city, country, length_km)
    SELECT circuit_id, name, city, country, length_km
    FROM sda_lab1.circuit;

    -- Load dim_driver
    -- denormalize driver and constructor tables into a single dimension
    INSERT IGNORE INTO dim_driver (driver_id, name, nationality, constructor_name)
    SELECT 
        d.driver_id, 
        d.name, 
        d.nationality, 
        c.name AS constructor_name
    FROM sda_lab1.driver d
    JOIN sda_lab1.constructor c ON d.constructor_id = c.constructor_id;

    -- Load dim_race
    INSERT IGNORE INTO dim_race (race_id, season, has_sprint)
    SELECT race_id, season, has_sprint
    FROM sda_lab1.race_weekend;


    -- populating fact table

    -- clear out old data
    TRUNCATE TABLE fact_race_performance;

    -- Integrates 6 operational tables (race_result, race_weekend, sprint_result, pit_stop, tyre_stint, ratings) 
    -- into a single denormalized grain: one row per driver per race.
    INSERT INTO fact_race_performance (
        time_id, driver_id, circuit_id, race_id, 
        finish_position, grand_prix_points, sprint_points, is_dnf,
        total_pit_stops, avg_pit_stop_duration_sec, avg_tyre_stint_laps,
        challenge_rating, enjoyment_rating, strategy_rating
    )
    SELECT 
        dt.time_id,
        rr.driver_id,
        rw.circuit_id,
        rr.race_id,
        rr.finish_position,
        rr.points_earned AS grand_prix_points,
        COALESCE(sr.sprint_points_earned, 0) AS sprint_points,
        rr.is_dnf,
        
        -- Aggregated Measures from Subqueries
        COALESCE(ps.total_stops, 0) AS total_pit_stops,
        ps.avg_duration AS avg_pit_stop_duration_sec,
        ts.avg_stint_laps AS avg_tyre_stint_laps,
        
        -- Rating Measures
        rt.challenge_rating,
        rt.enjoyment_rating,
        rt.strategy_rating

    FROM sda_lab1.race_result rr
    
    -- Join to get the Date and Circuit for the Foreign Keys
    JOIN sda_lab1.race_weekend rw ON rr.race_id = rw.race_id
    JOIN dim_time dt ON DATE(rw.race_date) = dt.full_date
    
    -- Left Join Sprint Results -- Not every race has a sprint, or a driver might DNF early
    LEFT JOIN sda_lab1.sprint_result sr 
        ON rr.race_id = sr.race_id AND rr.driver_id = sr.driver_id
        
    -- Aggregate Pit Stops per driver per race
    LEFT JOIN (
        SELECT race_id, driver_id, COUNT(*) AS total_stops, ROUND(AVG(duration_seconds), 3) AS avg_duration
        FROM sda_lab1.pit_stop
        GROUP BY race_id, driver_id
    ) ps ON rr.race_id = ps.race_id AND rr.driver_id = ps.driver_id
    
    -- Aggregate Tyre Stints per driver per race
    LEFT JOIN (
        SELECT race_id, driver_id, ROUND(AVG(end_lap - start_lap), 2) AS avg_stint_laps
        FROM sda_lab1.tyre_stint
        GROUP BY race_id, driver_id
    ) ts ON rr.race_id = ts.race_id AND rr.driver_id = ts.driver_id
    
    -- Left Join Ratings
    LEFT JOIN sda_lab1.ratings rt 
        ON rr.race_id = rt.raceID AND rr.driver_id = rt.driverID;

END //

DELIMITER ;


CALL sp_run_etl_pipeline();