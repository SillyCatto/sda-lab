-- 003_us1_task1_extend_race_weekend.sql

-- MySQL does not support "IF NOT EXISTS" for ADD COLUMN in ALTER TABLE statements.
-- will throw a "Duplicate column name" error if re-run

ALTER TABLE race_weekend 
ADD COLUMN has_sprint BOOLEAN DEFAULT FALSE;

ALTER TABLE race_weekend 
ADD COLUMN sprint_date TIMESTAMP NULL;

-- verification
SELECT * FROM race_weekend;

SELECT circuit_id, has_sprint, sprint_date
FROM race_weekend
LIMIT 5;

-- Changelog

INSERT INTO change_log (applied_at, created_by, script_name, script_details) 
VALUES ( CURRENT_TIMESTAMP, CURRENT_USER(), '003_us1_task1_extend_race_weekend.sql', 
    'Added has_sprint and sprint_date to race_weekend for User Story 1 Task 1'
);