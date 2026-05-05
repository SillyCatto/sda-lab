-- Script Name: 010_us3_phase2_migrate_lap_times.sql

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS parse_lap_times()
BEGIN
    -- formats with minutes
    UPDATE race_result
    SET 
        lap_minutes = CAST(SUBSTRING_INDEX(fastest_lap_time, ':', 1) AS UNSIGNED),
        -- seconds between ':' and '.'
        lap_seconds = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(fastest_lap_time, ':', -1), '.', 1) AS UNSIGNED),
        lap_milliseconds = CAST(SUBSTRING_INDEX(fastest_lap_time, '.', -1) AS UNSIGNED)
    WHERE fastest_lap_time LIKE '%:%';

    -- without minutes
    UPDATE race_result
    SET 
        lap_minutes = NULL,
        -- everything before the period is seconds
        lap_seconds = CAST(SUBSTRING_INDEX(fastest_lap_time, '.', 1) AS UNSIGNED),
        lap_milliseconds = CAST(SUBSTRING_INDEX(fastest_lap_time, '.', -1) AS UNSIGNED)
    WHERE fastest_lap_time NOT LIKE '%:%' AND fastest_lap_time IS NOT NULL;
END //


CREATE PROCEDURE IF NOT EXISTS get_lap_time_as_seconds(IN p_result_id INT)
BEGIN
    SELECT 
        CAST(
            (IFNULL(lap_minutes, 0) * 60) + 
            lap_seconds + 
            (lap_milliseconds / 1000.0) 
        AS DECIMAL(10,3)) AS total_seconds
    FROM race_result
    WHERE result_id = p_result_id;
END //

DELIMITER ;

CALL parse_lap_times();

-- Validation 
-- Expected output: 0 rows
SELECT 
    result_id, 
    fastest_lap_time AS original_string, 
    CASE 
        WHEN lap_minutes IS NOT NULL 
            THEN CONCAT(lap_minutes, ':', LPAD(lap_seconds, 2, '0'), '.', LPAD(lap_milliseconds, 3, '0'))
        ELSE 
            CONCAT(lap_seconds, '.', LPAD(lap_milliseconds, 3, '0'))
    END AS reconstructed_string
FROM race_result
WHERE fastest_lap_time IS NOT NULL 
  AND fastest_lap_time != CASE 
        WHEN lap_minutes IS NOT NULL 
            THEN CONCAT(lap_minutes, ':', LPAD(lap_seconds, 2, '0'), '.', LPAD(lap_milliseconds, 3, '0'))
        ELSE 
            CONCAT(lap_seconds, '.', LPAD(lap_milliseconds, 3, '0'))
    END;


INSERT INTO change_log (applied_at, created_by, script_name, script_details) 
VALUES ( CURRENT_TIMESTAMP, CURRENT_USER(), '010_us3_phase2_migrate_lap_times.sql', 
    'Executed two-pass parse_lap_times() procedure for with and without minutes.'
);