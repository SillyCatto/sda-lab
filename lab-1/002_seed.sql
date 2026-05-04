-- ============================================================
-- 002_seed.sql
-- ============================================================
CREATE DATABASE IF NOT EXISTS sda_lab1;
USE sda_lab1;


-- Constructors
INSERT INTO constructor (name, nationality, principal) VALUES
    ('Mercedes-AMG Petronas', 'German',  'Toto Wolff'),
    ('Oracle Red Bull Racing', 'Austrian', 'Christian Horner'),
    ('Scuderia Ferrari',       'Italian',  'Frederic Vasseur');

-- Drivers
INSERT INTO driver (name, nationality, date_of_birth, constructor_id, emergency_contact) VALUES
    ('Lewis Hamilton',  'British',    '1985-01-07', 1, 'Wife - Nikola Hamilton - +447700900123'),
    ('George Russell',  'British',    '1998-02-15', 1, 'Father: Steve Russell +447911123456'),
    ('Max Verstappen',  'Dutch',      '1997-09-30', 2, 'Father - Jos Verstappen - +31612345678'),
    ('Sergio Perez',    'Mexican',    '1990-01-26', 2, 'Wife: Carola Martinez +521234567890'),
    ('Charles Leclerc', 'Monegasque', '1997-10-16', 3, 'Brother - Arthur Leclerc - +37798765432'),
    ('Carlos Sainz',    'Spanish',    '1994-09-01', 3, 'Dad: Carlos Sainz Sr +34612345678');

-- Circuits
INSERT INTO circuit (name, city, country, total_laps, length_km) VALUES
    ('Bahrain International Circuit', 'Sakhir',    'Bahrain',      57, 5.412),
    ('Jeddah Corniche Circuit',       'Jeddah',    'Saudi Arabia', 50, 6.174),
    ('Albert Park Circuit',           'Melbourne', 'Australia',    58, 5.278),
    ('Circuit de Monaco',             'Monaco',    'Monaco',       78, 3.337);

-- Race Weekends
INSERT INTO race_weekend (circuit_id, season, race_date, status) VALUES
    (1, 2024, '2024-03-02', 'COMPLETED'),  -- race_id 1: Bahrain
    (2, 2024, '2024-03-09', 'COMPLETED'),  -- race_id 2: Saudi Arabia
    (3, 2024, '2024-03-24', 'COMPLETED'),  -- race_id 3: Australia
    (4, 2024, '2024-05-26', 'COMPLETED');  -- race_id 4: Monaco

-- Race Results (Bahrain)
INSERT INTO race_result (race_id, driver_id, finish_position, points_earned, is_dnf, fastest_lap_time) VALUES
    (1, 3, 1, 25.0, FALSE, '1:32.608'),
    (1, 4, 2, 18.0, FALSE, '1:33.012'),
    (1, 5, 3, 15.0, FALSE, '1:33.217'),
    (1, 6, 4, 12.0, FALSE, '1:33.489'),
    (1, 1, 5, 10.0, FALSE, '1:33.701'),
    (1, 2, 6,  8.0, FALSE, '1:33.845');

-- Race Results (Saudi Arabia)
INSERT INTO race_result (race_id, driver_id, finish_position, points_earned, is_dnf, fastest_lap_time) VALUES
    (2, 3, 1, 25.0, FALSE, '1:30.898'),
    (2, 1, 2, 18.0, FALSE, '1:31.204'),
    (2, 5, 3, 15.0, FALSE, '1:31.456'),
    (2, 2, 4, 12.0, FALSE, '1:31.788'),
    (2, 4, 5, 10.0, FALSE, '1:32.001'),
    (2, 6, 6,  8.0, FALSE, '1:32.345');

-- Race Results (Australia)
INSERT INTO race_result (race_id, driver_id, finish_position, points_earned, is_dnf, fastest_lap_time) VALUES
    (3, 5, 1, 25.0, FALSE, '1:20.235'),
    (3, 6, 2, 18.0, FALSE, '1:20.788'),
    (3, 2, 3, 15.0, FALSE, '1:21.012'),
    (3, 3, 4, 12.0, FALSE, '1:21.345'),
    (3, 1, 0,  0.0, TRUE,  NULL),       -- DNF
    (3, 4, 0,  0.0, TRUE,  NULL);       -- DNF

-- Race Results (Monaco)
INSERT INTO race_result (race_id, driver_id, finish_position, points_earned, is_dnf, fastest_lap_time) VALUES
    (4, 5, 1, 25.0, FALSE, '1:12.456'),
    (4, 3, 2, 18.0, FALSE, '1:12.789'),
    (4, 1, 3, 15.0, FALSE, '1:13.102'),
    (4, 2, 4, 12.0, FALSE, '1:13.378'),
    (4, 4, 5, 10.0, FALSE, '1:13.601'),
    (4, 6, 6,  8.0, FALSE, '1:13.890');

-- Pit Stops (Bahrain — race_id 1)
INSERT INTO pit_stop (race_id, driver_id, stop_number, duration_seconds, lap_number) VALUES
    (1, 3, 1, 2.41, 14), (1, 3, 2, 2.38, 35),
    (1, 4, 1, 2.55, 15), (1, 4, 2, 2.61, 36),
    (1, 5, 1, 2.72, 13), (1, 5, 2, 2.68, 34),
    (1, 6, 1, 2.80, 16), (1, 6, 2, 2.77, 37),
    (1, 1, 1, 2.63, 14), (1, 1, 2, 2.59, 36),
    (1, 2, 1, 2.70, 15), (1, 2, 2, 2.66, 37);

-- Pit Stops (Saudi Arabia — race_id 2)
INSERT INTO pit_stop (race_id, driver_id, stop_number, duration_seconds, lap_number) VALUES
    (2, 3, 1, 2.31, 20), (2, 3, 2, 2.28, 38),
    (2, 1, 1, 2.44, 21), (2, 1, 2, 2.41, 39),
    (2, 5, 1, 2.58, 19), (2, 5, 2, 2.55, 37),
    (2, 2, 1, 2.62, 20), (2, 2, 2, 2.59, 38),
    (2, 4, 1, 2.75, 22), (2, 4, 2, 2.71, 40),
    (2, 6, 1, 2.80, 21), (2, 6, 2, 2.77, 39);

-- Pit Stops (Australia — race_id 3)
INSERT INTO pit_stop (race_id, driver_id, stop_number, duration_seconds, lap_number) VALUES
    (3, 5, 1, 2.55, 18), (3, 5, 2, 2.52, 38),
    (3, 6, 1, 2.61, 19), (3, 6, 2, 2.58, 39),
    (3, 2, 1, 2.70, 17), (3, 2, 2, 2.67, 37),
    (3, 3, 1, 2.44, 20), (3, 3, 2, 2.41, 40);

-- Pit Stops (Monaco — race_id 4)
INSERT INTO pit_stop (race_id, driver_id, stop_number, duration_seconds, lap_number) VALUES
    (4, 5, 1, 2.38, 30),
    (4, 3, 1, 2.42, 31),
    (4, 1, 1, 2.50, 29),
    (4, 2, 1, 2.55, 30),
    (4, 4, 1, 2.61, 32),
    (4, 6, 1, 2.67, 31);

-- Tyre Stints (Bahrain — race_id 1)
INSERT INTO tyre_stint (race_id, driver_id, compound, start_lap, end_lap) VALUES
    (1, 3, 'SOFT',   1, 14), (1, 3, 'MEDIUM', 15, 35), (1, 3, 'HARD',   36, 57),
    (1, 4, 'SOFT',   1, 15), (1, 4, 'MEDIUM', 16, 36), (1, 4, 'HARD',   37, 57),
    (1, 5, 'SOFT',   1, 13), (1, 5, 'MEDIUM', 14, 34), (1, 5, 'HARD',   35, 57),
    (1, 6, 'MEDIUM', 1, 16), (1, 6, 'HARD',   17, 37), (1, 6, 'SOFT',   38, 57),
    (1, 1, 'MEDIUM', 1, 14), (1, 1, 'HARD',   15, 36), (1, 1, 'SOFT',   37, 57),
    (1, 2, 'SOFT',   1, 15), (1, 2, 'MEDIUM', 16, 37), (1, 2, 'HARD',   38, 57);

-- Tyre Stints (Saudi Arabia — race_id 2)
INSERT INTO tyre_stint (race_id, driver_id, compound, start_lap, end_lap) VALUES
    (2, 3, 'SOFT',   1, 20), (2, 3, 'MEDIUM', 21, 38), (2, 3, 'HARD',   39, 50),
    (2, 1, 'SOFT',   1, 21), (2, 1, 'MEDIUM', 22, 39), (2, 1, 'HARD',   40, 50),
    (2, 5, 'MEDIUM', 1, 19), (2, 5, 'HARD',   20, 37), (2, 5, 'SOFT',   38, 50),
    (2, 2, 'SOFT',   1, 20), (2, 2, 'HARD',   21, 38), (2, 2, 'MEDIUM', 39, 50),
    (2, 4, 'MEDIUM', 1, 22), (2, 4, 'SOFT',   23, 40), (2, 4, 'HARD',   41, 50),
    (2, 6, 'HARD',   1, 21), (2, 6, 'SOFT',   22, 39), (2, 6, 'MEDIUM', 40, 50);

-- Tyre Stints (Australia — race_id 3)
INSERT INTO tyre_stint (race_id, driver_id, compound, start_lap, end_lap) VALUES
    (3, 5, 'SOFT',   1, 18), (3, 5, 'MEDIUM', 19, 38), (3, 5, 'HARD',   39, 58),
    (3, 6, 'SOFT',   1, 19), (3, 6, 'HARD',   20, 39), (3, 6, 'MEDIUM', 40, 58),
    (3, 2, 'MEDIUM', 1, 17), (3, 2, 'SOFT',   18, 37), (3, 2, 'HARD',   38, 58),
    (3, 3, 'HARD',   1, 20), (3, 3, 'MEDIUM', 21, 40), (3, 3, 'SOFT',   41, 58);

-- Tyre Stints (Monaco — race_id 4)
INSERT INTO tyre_stint (race_id, driver_id, compound, start_lap, end_lap) VALUES
    (4, 5, 'SOFT',   1, 30), (4, 5, 'MEDIUM', 31, 78),
    (4, 3, 'MEDIUM', 1, 31), (4, 3, 'SOFT',   32, 78),
    (4, 1, 'SOFT',   1, 29), (4, 1, 'HARD',   30, 78),
    (4, 2, 'MEDIUM', 1, 30), (4, 2, 'HARD',   31, 78),
    (4, 4, 'SOFT',   1, 32), (4, 4, 'MEDIUM', 33, 78),
    (4, 6, 'HARD',   1, 31), (4, 6, 'SOFT',   32, 78);

-- Driver Standings (after 4 races)
INSERT INTO driver_standing (driver_id, season, total_points, position) VALUES
    (3, 2024, 80.0, 1),   -- Verstappen:  25+25+12+18
    (5, 2024, 65.0, 2),   -- Leclerc:     15+15+25+25
    (1, 2024, 43.0, 3),   -- Hamilton:    10+18+ 0+15
    (6, 2024, 38.0, 4),   -- Sainz:       12+ 8+18+ 8
    (2, 2024, 47.0, 5),   -- Russell:      8+12+15+12  -- note: intentionally out of order for student to fix
    (4, 2024, 38.0, 6);   -- Perez:       18+10+ 0+10

INSERT INTO change_log (created_by, script_name, script_details)
VALUES ('admin', '002_seed.sql', 'Inserted seed data: 3 constructors, 6 drivers, 4 circuits, 4 race weekends, 24 results, 44 pit stops, 60 tyre stints, 6 standings');