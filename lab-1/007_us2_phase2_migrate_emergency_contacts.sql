-- 007_us2_phase2_migrate_emergency_contacts.sql


CREATE TABLE IF NOT EXISTS migration_error_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100),
    record_id INT,
    legacy_data VARCHAR(255),
    error_message TEXT,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

-- migration procedure
CREATE PROCEDURE migrate_emergency_contacts()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_driver_id INT;
    DECLARE v_legacy_contact VARCHAR(255);
    DECLARE v_phone VARCHAR(50);
    DECLARE v_relationship VARCHAR(100);
    DECLARE v_name VARCHAR(255);
    DECLARE v_cleaned_string VARCHAR(255);
    
    -- Cursor to iterate over unmigrated rows
    DECLARE cur_contacts CURSOR FOR 
        SELECT driver_id, emergency_contact 
        FROM driver 
        WHERE emergency_contact_migrated = FALSE AND emergency_contact IS NOT NULL;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_contacts;

    migration_loop: LOOP
        FETCH cur_contacts INTO v_driver_id, v_legacy_contact;
        IF done THEN
            LEAVE migration_loop;
        END IF;

        BEGIN
            -- Error handler for parsing failures
            DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            BEGIN
                INSERT INTO migration_error_log (table_name, record_id, legacy_data, error_message)
                VALUES ('driver', v_driver_id, v_legacy_contact, 'Failed to parse structured data');
            END;

            -- Extract the phone number
            SET v_phone = REGEXP_SUBSTR(v_legacy_contact, '\\+[0-9]{10,15}');
            
            -- Remove the phone number from the string to parse name and relationship
            SET v_cleaned_string = TRIM(REPLACE(v_legacy_contact, v_phone, ''));

            -- Handle Format 2: 'Relationship: Name'
            IF v_cleaned_string LIKE '%:%' THEN
                SET v_relationship = TRIM(SUBSTRING_INDEX(v_cleaned_string, ':', 1));
                SET v_name = TRIM(SUBSTRING_INDEX(v_cleaned_string, ':', -1));
            
            -- Handle Format 1: 'Relationship Name'
            ELSE
                SET v_relationship = TRIM(SUBSTRING_INDEX(v_cleaned_string, ' ', 1));
                -- The name is everything after the first space
                SET v_name = TRIM(SUBSTRING(v_cleaned_string, LENGTH(v_relationship) + 2));
            END IF;

            -- Update the driver record if parsing produced a valid phone and name
            IF v_phone IS NOT NULL AND v_name != '' THEN
                UPDATE driver 
                SET emergency_contact_name = v_name,
                    emergency_contact_relationship = v_relationship,
                    emergency_contact_phone = v_phone,
                    emergency_contact_migrated = TRUE
                WHERE driver_id = v_driver_id;
            ELSE
                -- Log to error log if it couldn't be cleanly parsed
                INSERT INTO migration_error_log (table_name, record_id, legacy_data, error_message)
                VALUES ('driver', v_driver_id, v_legacy_contact, 'Missing identifiable phone number or name');
            END IF;
        END;
    END LOOP;

    CLOSE cur_contacts;
END //

DELIMITER ;

-- 3. Execute the procedure
CALL migrate_emergency_contacts();

-- Verification Query

SELECT emergency_contact, emergency_contact_name, emergency_contact_relationship, emergency_contact_phone 
FROM driver 
WHERE emergency_contact_migrated = TRUE;

-- Verify if there are any errors:
SELECT * FROM migration_error_log;


-- 4. Update change_log
INSERT INTO change_log (applied_at, created_by, script_name, script_details) 
VALUES (CURRENT_TIMESTAMP, CURRENT_USER(), '007_us2_phase2_migrate_emergency_contacts.sql', 
    'Created and executed migrate_emergency_contacts procedure. Handled parsing of legacy strings.'
);