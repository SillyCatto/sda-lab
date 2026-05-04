-- 006_us2_phase1_expand_emergency_contacts.sql


ALTER TABLE driver 
ADD COLUMN emergency_contact_name VARCHAR(255) NULL,
ADD COLUMN emergency_contact_relationship VARCHAR(100) NULL,
ADD COLUMN emergency_contact_phone VARCHAR(50) NULL;

-- boolean column to track migration status
ALTER TABLE driver 
ADD COLUMN emergency_contact_migrated BOOLEAN DEFAULT FALSE;


-- Verification Query
SELECT driver_id, emergency_contact, emergency_contact_name, emergency_contact_migrated 
FROM driver LIMIT 3;


-- Changelog
INSERT INTO change_log (applied_at, created_by, script_name, script_details) 
VALUES ( CURRENT_TIMESTAMP, CURRENT_USER(), '006_us2_phase1_expand_emergency_contacts.sql', 
    'Added emergency_contact_name, relationship, phone, and migrated flags to driver table.'
);