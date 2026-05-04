-- ============================================================
-- 001_init_schema.sql
-- ============================================================
CREATE DATABASE IF NOT EXISTS sda_lab1;
USE sda_lab1;


CREATE TABLE IF NOT EXISTS constructor (
    constructor_id  INT             AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL,
    nationality     VARCHAR(50)     NOT NULL,
    principal       VARCHAR(100)    NOT NULL
);

CREATE TABLE IF NOT EXISTS driver (
    driver_id           INT             AUTO_INCREMENT PRIMARY KEY,
    name                VARCHAR(100)    NOT NULL,
    nationality         VARCHAR(50)     NOT NULL,
    date_of_birth       DATE            NOT NULL,
    constructor_id      INT             NOT NULL,
    emergency_contact   VARCHAR(255),
    CONSTRAINT fk_driver_constructor
        FOREIGN KEY (constructor_id) REFERENCES constructor(constructor_id)
);

CREATE TABLE IF NOT EXISTS circuit (
    circuit_id      INT             AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL,
    city            VARCHAR(100)    NOT NULL,
    country         VARCHAR(100)    NOT NULL,
    total_laps      INT             NOT NULL,
    length_km       DECIMAL(5, 3)   NOT NULL
);

CREATE TABLE IF NOT EXISTS race_weekend (
    race_id         INT             AUTO_INCREMENT PRIMARY KEY,
    circuit_id      INT             NOT NULL,
    season          YEAR            NOT NULL,
    race_date       DATE            NOT NULL,
    status          ENUM('SCHEDULED', 'COMPLETED', 'CANCELLED')
                                    NOT NULL DEFAULT 'SCHEDULED',
    CONSTRAINT fk_raceweekend_circuit
        FOREIGN KEY (circuit_id) REFERENCES circuit(circuit_id)
);

CREATE TABLE IF NOT EXISTS race_result (
    result_id           INT         AUTO_INCREMENT PRIMARY KEY,
    race_id             INT         NOT NULL,
    driver_id           INT         NOT NULL,
    finish_position     INT,
    points_earned       DECIMAL(4,1) NOT NULL DEFAULT 0,
    is_dnf              BOOLEAN     NOT NULL DEFAULT FALSE,
    fastest_lap_time    VARCHAR(10),
    CONSTRAINT fk_result_race
        FOREIGN KEY (race_id)    REFERENCES race_weekend(race_id),
    CONSTRAINT fk_result_driver
        FOREIGN KEY (driver_id)  REFERENCES driver(driver_id),
    CONSTRAINT uq_result
        UNIQUE (race_id, driver_id)
);

CREATE TABLE IF NOT EXISTS pit_stop (
    stop_id             INT         AUTO_INCREMENT PRIMARY KEY,
    race_id             INT         NOT NULL,
    driver_id           INT         NOT NULL,
    stop_number         INT         NOT NULL,
    duration_seconds    DECIMAL(5,2) NOT NULL,
    lap_number          INT         NOT NULL,
    CONSTRAINT fk_pitstop_race
        FOREIGN KEY (race_id)   REFERENCES race_weekend(race_id),
    CONSTRAINT fk_pitstop_driver
        FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    CONSTRAINT uq_pitstop
        UNIQUE (race_id, driver_id, stop_number)
);

CREATE TABLE IF NOT EXISTS tyre_stint (
    stint_id        INT             AUTO_INCREMENT PRIMARY KEY,
    race_id         INT             NOT NULL,
    driver_id       INT             NOT NULL,
    compound        VARCHAR(20)     NOT NULL,
    start_lap       INT             NOT NULL,
    end_lap         INT             NOT NULL,
    CONSTRAINT fk_stint_race
        FOREIGN KEY (race_id)   REFERENCES race_weekend(race_id),
    CONSTRAINT fk_stint_driver
        FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    CONSTRAINT chk_stint_laps
        CHECK (end_lap > start_lap)
);

CREATE TABLE IF NOT EXISTS driver_standing (
    standing_id     INT             AUTO_INCREMENT PRIMARY KEY,
    driver_id       INT             NOT NULL,
    season          YEAR            NOT NULL,
    total_points    DECIMAL(6,1)    NOT NULL DEFAULT 0,
    position        INT             NOT NULL,
    CONSTRAINT fk_standing_driver
        FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    CONSTRAINT uq_standing
        UNIQUE (driver_id, season)
);

INSERT INTO change_log (created_by, script_name, script_details)
VALUES ('admin', '001_init_schema.sql', 'Created all core operational tables');