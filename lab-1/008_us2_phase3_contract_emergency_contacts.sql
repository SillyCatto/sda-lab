--  008_us2_phase3_contract_emergency_contacts.sql



ALTER TABLE driver 
MODIFY COLUMN emergency_contact_name VARCHAR(255) NOT NULL,
MODIFY COLUMN emergency_contact_phone VARCHAR(50) NOT NULL;


ALTER TABLE driver 
DROP COLUMN emergency_contact,
DROP COLUMN emergency_contact_migrated;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS get_driver_emergency_contact(IN p_driver_id INT)
BEGIN
    SELECT 
        emergency_contact_name AS name,
        emergency_contact_relationship AS relationship,
        emergency_contact_phone AS phone
    FROM driver
    WHERE driver_id = p_driver_id;
END //

DELIMITER ;

-- cahngelog
INSERT INTO change_log (applied_at, created_by, script_name, script_details) 
VALUES ( CURRENT_TIMESTAMP, CURRENT_USER(), '008_us2_phase3_contract_emergency_contacts.sql', 
    'Dropped legacy emergency_contact column, applied NOT NULL constraints, and created retrieval procedure.'
);