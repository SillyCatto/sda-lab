-- Script Name: 009_us3_phase1_expand_lap_times.sql

-- nullable integer columns
ALTER TABLE race_result 
ADD COLUMN lap_minutes INT NULL,
ADD COLUMN lap_seconds INT NULL,
ADD COLUMN lap_milliseconds INT NULL;

-- check constraints
ALTER TABLE race_result
ADD CONSTRAINT chk_lap_minutes CHECK (lap_minutes >= 0),
ADD CONSTRAINT chk_lap_seconds CHECK (lap_seconds BETWEEN 0 AND 59),
ADD CONSTRAINT chk_lap_milliseconds CHECK (lap_milliseconds BETWEEN 0 AND 999);

-- Verification

SELECT result_id, fastest_lap_time, lap_minutes, lap_seconds, lap_milliseconds 
FROM race_result LIMIT 3;


INSERT INTO change_log (applied_at, created_by, script_name, script_details) 
VALUES ( CURRENT_TIMESTAMP, CURRENT_USER(), '009_us3_phase1_expand_lap_times.sql', 
    'Added lap_minutes, lap_seconds, and lap_milliseconds columns with CHECK constraints to race_result.'
);