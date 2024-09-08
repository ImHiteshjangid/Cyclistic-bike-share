-- Total Number of Rides by member Type
SELECT 
    member_casual AS member_type,
    COUNT(*) AS total_rides,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM rides) * 100), 2) AS percentage_of_total_rides
FROM rides
GROUP BY member_casual;

-- Average Ride Duration by member Type
SELECT 
    member_casual AS user_type,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_ride_duration_minutes
FROM rides
GROUP BY member_casual;

-- Calculating the Average and Maximum Ride Lengths
SELECT 
    member_casual AS user_type,
    AVG(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS avg_ride_length_minutes,
    MAX(TIMESTAMPDIFF(MINUTE, started_at, ended_at)) AS max_ride_length_minutes
FROM rides
GROUP BY member_casual;

-- Trips Taken by the Day of the Week
SELECT 
    member_casual AS user_type,
    day_of_week,
    COUNT(*) AS total_rides
FROM rides
GROUP BY member_casual, day_of_week
ORDER BY member_casual, day_of_week;

-- Calculating Trips Taken by Month
SELECT 
    member_casual AS member_type,
    MONTHNAME(started_at) AS month,
    MONTH(started_at) AS month_number,
    COUNT(*) AS total_rides
FROM 
    rides
GROUP BY member_casual, MONTHNAME(started_at), MONTH(started_at)
ORDER BY member_casual, month_number;

-- Most Popular Start Stations:
SELECT 
    member_casual AS user_type,
    start_station_name,
    COUNT(*) AS ride_count
FROM rides
GROUP BY member_casual, start_station_name
ORDER BY ride_count DESC
LIMIT 10;

--  Ride Patterns by Time of Day
SELECT 
    member_casual AS user_type,
    CASE
        WHEN HOUR(started_at) BETWEEN 0 AND 5 THEN 'Late Night'
        WHEN HOUR(started_at) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(started_at) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(started_at) BETWEEN 18 AND 23 THEN 'Evening'
    END AS time_of_day,
    COUNT(*) AS total_rides
FROM rides
GROUP BY member_casual, time_of_day
ORDER BY member_casual, time_of_day;

-- Monthly rides by member
SELECT 
    member_casual AS member_type,
    MONTH(started_at) AS month,
    COUNT(*) AS total_rides
FROM rides
GROUP BY member_casual, month
ORDER BY member_casual, month;

show create table rides;