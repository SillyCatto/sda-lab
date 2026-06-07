USE sda_lab1;

CREATE TABLE IF NOT EXISTS ratings (
    ratingID            INT             AUTO_INCREMENT PRIMARY KEY,
    driverID            INT             NOT NULL,
    raceID              INT             NOT NULL,
    challenge_rating    INT             NOT NULL,
    enjoyment_rating    INT             NOT NULL,
    strategy_rating     INT             NOT NULL,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ratings_driver
        FOREIGN KEY (driverID) REFERENCES driver(driver_id),
    CONSTRAINT fk_ratings_race
        FOREIGN KEY (raceID) REFERENCES race_weekend(race_id)
);

-- Ratings
INSERT INTO ratings (driverID, raceID, challenge_rating, enjoyment_rating, strategy_rating) VALUES
    (3, 1, 4, 5, 4),
    (4, 1, 3, 4, 4),
    (5, 1, 4, 4, 3),
    (6, 1, 3, 3, 3),
    (1, 1, 4, 3, 3),
    (2, 1, 3, 3, 3),
    
    (3, 2, 5, 5, 5),
    (1, 2, 4, 4, 4),
    (5, 2, 4, 4, 3),
    (2, 2, 3, 3, 3),
    (4, 2, 3, 3, 4),
    (6, 2, 3, 3, 3),
    
    (5, 3, 4, 5, 5),
    (6, 3, 4, 4, 4),
    (2, 3, 4, 4, 4),
    (3, 3, 5, 3, 3),
    (1, 3, 4, 2, 2),
    (4, 3, 4, 2, 2),
    
    (5, 4, 5, 5, 5),
    (3, 4, 4, 4, 4),
    (1, 4, 4, 4, 4),
    (2, 4, 4, 3, 3),
    (4, 4, 3, 3, 3),
    (6, 4, 4, 3, 3);