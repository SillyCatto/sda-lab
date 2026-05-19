-- separate reporting database
CREATE DATABASE IF NOT EXISTS pitlane_reporting_db;
USE pitlane_reporting_db;

-- dimension tables

CREATE TABLE dim_time (
    time_id INT PRIMARY KEY AUTO_INCREMENT,
    full_date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    quarter INT NOT NULL,
    weekday INT NOT NULL,
    year INT NOT NULL,
    weekend_flag BOOLEAN NOT NULL
);

CREATE TABLE dim_driver (
    driver_id INT PRIMARY KEY, -- keeping operational ID for ETL mapping
    name VARCHAR(255) NOT NULL,
    nationality VARCHAR(100),
    constructor_name VARCHAR(255) -- denormalized from operational constructor table
);

CREATE TABLE dim_circuit (
    circuit_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100),
    length_km DECIMAL(5,3)
);

CREATE TABLE dim_race (
    race_id INT PRIMARY KEY,
    season INT NOT NULL,
    has_sprint BOOLEAN DEFAULT FALSE
);

-- fact table

CREATE TABLE fact_race_performance (
    performance_id INT PRIMARY KEY AUTO_INCREMENT,
    
    -- foreign keys to dimensions
    time_id INT NOT NULL,
    driver_id INT NOT NULL,
    circuit_id INT NOT NULL,
    race_id INT NOT NULL,
    
    -- race & sprint results
    finish_position INT,
    grand_prix_points INT DEFAULT 0,
    sprint_points INT DEFAULT 0,
    is_dnf BOOLEAN DEFAULT FALSE,
    
    -- aggregated pit stop & tyre data
    total_pit_stops INT DEFAULT 0,
    avg_pit_stop_duration_sec DECIMAL(8,3),
    avg_tyre_stint_laps DECIMAL(8,2),
    
    -- ratings
    challenge_rating DECIMAL(3,2),
    enjoyment_rating DECIMAL(3,2),
    strategy_rating DECIMAL(3,2),

    -- constraints
    CONSTRAINT fk_fact_time FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    CONSTRAINT fk_fact_driver FOREIGN KEY (driver_id) REFERENCES dim_driver(driver_id),
    CONSTRAINT fk_fact_circuit FOREIGN KEY (circuit_id) REFERENCES dim_circuit(circuit_id),
    CONSTRAINT fk_fact_race FOREIGN KEY (race_id) REFERENCES dim_race(race_id)
);

-- index

-- indexes on FK
CREATE INDEX idx_fact_time ON fact_race_performance(time_id);
CREATE INDEX idx_fact_driver ON fact_race_performance(driver_id);
CREATE INDEX idx_fact_circuit ON fact_race_performance(circuit_id);
CREATE INDEX idx_fact_race ON fact_race_performance(race_id);

-- indexes for the tasks
CREATE INDEX idx_dim_circuit_city ON dim_circuit(city);
CREATE INDEX idx_dim_driver_country ON dim_driver(nationality);
CREATE INDEX idx_dim_time_month_year ON dim_time(month, year);

-- sample

INSERT INTO dim_time (full_date, day, month, quarter, weekday, year, weekend_flag) 
VALUES 
('2026-03-28', 28, 3, 1, 7, 2026, TRUE), 
('2026-04-18', 18, 4, 2, 7, 2026, TRUE),  
('2026-05-02', 2, 5, 2, 7, 2026, TRUE),   
('2026-05-23', 23, 5, 2, 7, 2026, TRUE),  
('2026-12-12', 12, 12, 4, 7, 2026, TRUE); 