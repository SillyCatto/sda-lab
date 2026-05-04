-- 004_us1_task2_sprint_result.sql

CREATE TABLE IF NOT EXISTS sprint_result (
    sprint_result_id INT AUTO_INCREMENT PRIMARY KEY,
    race_id INT NOT NULL,
    driver_id INT NOT NULL,
    finish_position INT NOT NULL,
    sprint_points_earned INT DEFAULT 0,
    dnf BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_sprint_race FOREIGN KEY (race_id) REFERENCES race_weekend(race_id),
    CONSTRAINT fk_sprint_driver FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    CONSTRAINT uq_sprint_driver_race UNIQUE (race_id, driver_id)
);

-- before insert trigger to check if race_weekend.has_sprint is TRUE
DELIMITER //

CREATE TRIGGER trg_before_insert_sprint_result
BEFORE INSERT ON sprint_result
FOR EACH ROW
BEGIN
    DECLARE sprint_status BOOLEAN;

    SELECT has_sprint INTO sprint_status
    FROM race_weekend
    WHERE race_id = NEW.race_id;

    IF sprint_status = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insert not allowed. Race weekend doesnt have a sprint scheduled';
    end if;
end; //

DELIMITER ;

-- verification
-- attempt to insert a record for a race has_sprint = FALSE. Should fail
INSERT INTO sprint_result (race_id, driver_id, finish_position, sprint_points_earned)
VALUES (1, 1, 1, 8);

-- changelog update
INSERT INTO change_log (applied_at, created_by, script_name, script_details)
VALUES (
    CURRENT_TIMESTAMP,
    CURRENT_USER(),
    '004_us1_task2_sprint_result.sql',
    'Created sprint_result table with unique constraints and before insert check trigger for has_sprint validation'
);
