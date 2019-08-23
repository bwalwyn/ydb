-- -----------------------------------------------------
-- Schema dimension
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS Dimensions;
USE Dimensions ;

-- -----------------------------------------------------
-- CREATE THE DIMENSION TABLES
-- -----------------------------------------------------

-- Small-numbers table
DROP TABLE IF EXISTS numbers_small;
CREATE TABLE numbers_small (number INT);
INSERT INTO numbers_small VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

-- Main-numbers table
DROP TABLE IF EXISTS numbers;
CREATE TABLE numbers (number BIGINT);
INSERT INTO numbers
SELECT thousands.number * 1000 + hundreds.number * 100 + tens.number * 10 + ones.number
FROM numbers_small thousands, numbers_small hundreds, numbers_small tens, numbers_small ones
LIMIT 1000000;

-- Create Date Dimension table
DROP TABLE IF EXISTS date_d;
CREATE TABLE date_d (
date_id          BIGINT PRIMARY KEY,
date_d           DATE NOT NULL,
year             INT,
month            CHAR(10),
month_of_year    CHAR(2),
day_of_month     INT,
day              CHAR(10),
day_of_week      INT,
weekend          CHAR(10) NOT NULL DEFAULT "Weekday",
day_of_year      INT,
week_of_year     CHAR(2),
quarter  INT,
previous_day     date NOT NULL default '0000-00-00',
next_day         date NOT NULL default '0000-00-00',
UNIQUE KEY `date_d` (`date_d`));

-- First populate with ids and Date
-- Change year start and end to match your needs. The above sql creates records for year 2010.
INSERT INTO date_d (date_id, date_d)
SELECT number, DATE_ADD( '2014-01-01', INTERVAL number DAY )
FROM numbers
WHERE DATE_ADD( '2014-01-01', INTERVAL number DAY ) BETWEEN '2014-01-01' AND '2024-12-31'
ORDER BY number;

-- Update other columns based on the date.
UPDATE date_d SET
year            = DATE_FORMAT( date_d, "%Y" ),
month           = DATE_FORMAT( date_d, "%M"),
month_of_year   = DATE_FORMAT( date_d, "%m"),
day_of_month    = DATE_FORMAT( date_d, "%d" ),
day             = DATE_FORMAT( date_d, "%W" ),
day_of_week     = DAYOFWEEK(date_d),
weekend         = IF( DATE_FORMAT( date_d, "%W" ) IN ('Saturday','Sunday'), 'Weekend', 'Weekday'),
day_of_year     = DATE_FORMAT( date_d, "%j" ),
week_of_year    = DATE_FORMAT( date_d, "%V" ),
quarter         = QUARTER(date_d),
previous_day    = DATE_ADD(date_d, INTERVAL -1 DAY),
next_day        = DATE_ADD(date_d, INTERVAL 1 DAY);