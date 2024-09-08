-- Creating & Using New Database
CREATE DATABASE bike_share;
USE bike_share;

-- Creating table with same fields in our csv files
CREATE TABLE rides (
    ride_id VARCHAR(50),
    rideable_type VARCHAR(50),
    started_at DATETIME,
    ended_at DATETIME,
    start_station_name VARCHAR(255),
    start_station_id VARCHAR(50),
    end_station_name VARCHAR(255),
    end_station_id VARCHAR(50),
    start_lat FLOAT,
    start_lng FLOAT,
    end_lat FLOAT,
    end_lng FLOAT,
    member_casual VARCHAR(50),
    ride_length TIME,
    day_of_week INT
);

-- Importing Data
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\December_2023_file.csv'
INTO TABLE rides
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@ride_id, @rideable_type, @started_at, @ended_at, @start_station_name, @start_station_id, @end_station_name, @end_station_id, @start_lat, @start_lng, @end_lat, @end_lng, @member_casual, @ride_length, @day_of_week)
SET
    ride_id = @ride_id,
    rideable_type = @rideable_type,
    started_at = STR_TO_DATE(@started_at, '%d-%m-%Y %H:%i:%s'),
    ended_at = STR_TO_DATE(@ended_at, '%d-%m-%Y %H:%i:%s'),
    start_station_name = @start_station_name,
    start_station_id = @start_station_id,
    end_station_name = @end_station_name,
    end_station_id = @end_station_id,
    start_lat = NULLIF(@start_lat, ''),
    start_lng = NULLIF(@start_lng, ''),
    end_lat = NULLIF(@end_lat, ''),
    end_lng = NULLIF(@end_lng, ''),
    member_casual = @member_casual,
    ride_length = @ride_length,
    day_of_week = @day_of_week;

-- Checking the data
select * from rides limit 10;

-- Count of total rows in table
SELECT COUNT(*) FROM rides;

-- Finding Duplicate Rows
SELECT *, COUNT(*) AS count 
FROM rides
GROUP BY 
	ride_id, rideable_type, started_at, ended_at, start_station_name, start_station_id, end_station_name, end_station_id, start_lat, start_lng, end_lat, end_lng, member_casual, ride_length, day_of_week
HAVING
	COUNT(*) > 1;

-- Finding Duplicates in the ride_id Column
SELECT ride_id, COUNT(*) AS count
FROM rides
GROUP BY ride_id
HAVING COUNT(*) > 1;

-- deleting duplicate ride_id
-- Adding a Unique Identifier
ALTER TABLE rides ADD COLUMN unique_id INT AUTO_INCREMENT PRIMARY KEY;

-- Creating a Temporary Table
CREATE TABLE temp_rides AS
SELECT MIN(unique_id) AS unique_id
FROM rides
GROUP BY ride_id;

-- Deleting Duplicates from the Original Table
DELETE FROM rides
WHERE unique_id NOT IN (SELECT unique_id FROM temp_rides);

-- Dropping the Temporary Table
DROP TABLE temp_rides;

-- Verifying the Results
SELECT ride_id, COUNT(*)
FROM rides
GROUP BY ride_id
HAVING COUNT(*) > 1;

-- Dropping the Unique Identifier Column
ALTER TABLE rides DROP COLUMN unique_id;

-- Adding Primary key to ride_id
ALTER TABLE rides
ADD CONSTRAINT pk_ride_id PRIMARY KEY (ride_id);

-- Distinct member type
SELECT DISTINCT member_casual FROM rides;

-- Distinct bike type
SELECT DISTINCT rideable_type FROM rides;

-- Most Used Bike
SELECT 
    rideable_type,
    COUNT(*) AS total_count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM rides)) AS percentage_share
FROM rides
GROUP BY rideable_type;

-- Query to Count Rows with Blank Entries
SELECT 
    COUNT(*) AS total_blank_rows,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM rides)) AS percentage_blank_rows
FROM 
    rides
WHERE 
    ride_id IS NULL OR ride_id = '' OR
    rideable_type IS NULL OR rideable_type = '' OR
    started_at IS NULL OR 
    ended_at IS NULL OR 
    start_station_name IS NULL OR start_station_name = '' OR
    start_station_id IS NULL OR start_station_id = '' OR
    end_station_name IS NULL OR end_station_name = '' OR
    end_station_id IS NULL OR end_station_id = '' OR
    start_lat IS NULL OR start_lat = '' OR
    start_lng IS NULL OR start_lng = '' OR
    end_lat IS NULL OR end_lat = '' OR
    end_lng IS NULL OR end_lng = '' OR
    member_casual IS NULL OR member_casual = '' OR
    ride_length IS NULL OR ride_length = '' OR
    day_of_week IS NULL OR day_of_week = '';

-- Updating Day_of_week
UPDATE rides
SET day_of_week = DAYOFWEEK(started_at);

-- Checking for null values in member_casual
SELECT count(*)
FROM rides
WHERE member_casual IS NULL;

-- Creating index For better Performance
CREATE INDEX idx_ride_id ON rides (ride_id);
CREATE INDEX idx_started_at ON rides (started_at);
CREATE INDEX idx_ended_at ON rides (ended_at);
CREATE INDEX idx_start_station_id ON rides (start_station_id);
CREATE INDEX idx_end_station_id ON rides (end_station_id);
CREATE INDEX idx_member_casual ON rides (member_casual);
CREATE INDEX idx_ride_length ON rides (ride_length);

-- Remove rides with negative or zero ride lengths
DELETE FROM rides
WHERE TIME_TO_SEC(ride_length) <= 0;

-- Verify that there are no rows with zero or negative ride lengths
SELECT *
FROM rides
WHERE TIME_TO_SEC(ride_length) <= 0;

ALTER TABLE rides
ADD COLUMN day_name VARCHAR(3);

UPDATE rides
SET day_name = CASE day_of_week
    WHEN 1 THEN 'Sun'
    WHEN 2 THEN 'Mon'
    WHEN 3 THEN 'Tue'
    WHEN 4 THEN 'Wed'
    WHEN 5 THEN 'Thu'
    WHEN 6 THEN 'Fri'
    WHEN 7 THEN 'Sat'
    ELSE NULL
END;
