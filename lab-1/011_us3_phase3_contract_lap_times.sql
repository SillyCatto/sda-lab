-- Script Name: 011_us3_phase3_contract_lap_times.sql

-- there are some null value at the table and we need to make them 0 to 
-- add not null constraints
UPDATE race_result 
SET lap_seconds = 0, lap_milliseconds = 0 
WHERE lap_seconds IS NULL OR lap_milliseconds IS NULL;

ALTER TABLE race_result 
MODIFY COLUMN lap_seconds INT NOT NULL,
MODIFY COLUMN lap_milliseconds INT NOT NULL;


ALTER TABLE race_result 
DROP COLUMN fastest_lap_time;

-- Create view
CREATE OR REPLACE VIEW v_race_result_display AS
SELECT result_id, race_id, driver_id, finish_position, points_earned, 
    is_dnf,lap_minutes,lap_seconds,lap_milliseconds,
    CASE 
        WHEN lap_minutes IS NOT NULL 
            THEN CONCAT(lap_minutes, ':', LPAD(lap_seconds, 2, '0'), '.', LPAD(lap_milliseconds, 3, '0'))
        ELSE 
            CONCAT(lap_seconds, '.', LPAD(lap_milliseconds, 3, '0'))
    END AS fastest_lap_time
FROM race_result;

INSERT INTO change_log (applied_at, created_by, script_name, script_details) 
VALUES ( CURRENT_TIMESTAMP, CURRENT_USER(), '011_us3_phase3_contract_lap_times.sql', 
    'Applied NOT NULL to lap seconds/ms, dropped fastest_lap_time column, created v_race_result_display view.'
);