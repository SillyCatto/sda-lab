-- 005_us1_task3_extend_driver_standing.sql

ALTER TABLE driver_standing
ADD COLUMN sprint_points INT DEFAULT 0;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS update_sprint_standing(
    IN p_driver_id INT,
    IN p_season INT
)
BEGIN
    DECLARE total_sprint_points INT;

    SELECT COALESCE(SUM(sr.sprint_points_earned), 0) INTO total_sprint_points
    FROM sprint_result sr
    JOIN race_weekend rw ON sr.race_id = rw.race_id
    WHERE sr.driver_id = p_driver_id AND rw.season = p_season;

    UPDATE driver_standing ds
    SET ds.sprint_points = total_sprint_points
    WHERE ds.driver_id = p_driver_id AND ds.season = p_season;

END //
DELIMITER ;

-- test
UPDATE race_weekend
SET has_sprint = TRUE, sprint_date = '2024-01-01 12:00:00'
WHERE race_id IN (1, 2, 3);

-- insert dummy sprint results for driver id 1
INSERT INTO sprint_result (race_id, driver_id, finish_position, sprint_points_earned, dnf)
VALUES (1, 1, 1, 8, FALSE),
    (2, 1, 3, 6, FALSE),
    (3, 1, 5, 4, FALSE);

CALL update_sprint_standing(1, 2024);

-- verification: ensure existing total_points remain unchanged
SELECT driver_id, season, total_points, sprint_points
FROM driver_standing
LIMIT 5;

-- changelog update
INSERT INTO change_log (applied_at, created_by, script_name, script_details)
VALUES (
    CURRENT_TIMESTAMP,
    CURRENT_USER(),
    '005_us1_task3_driver_standing_sprint.sql',
    'Added sprint_points column and created update_sprint_standing procedure.'
);


