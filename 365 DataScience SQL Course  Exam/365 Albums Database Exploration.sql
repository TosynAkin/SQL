
-- Question 1: Check for any missing Album Names in the albums table
SELECT 
    *
FROM
    albums
WHERE
    album_name IS NULL;

-- Question 2: Write a Query to confirm the obtained result in Question 1
SELECT 
    SUM(CASE
        WHEN album_name IS NULL THEN 1
        ELSE 0
    END) AS countNulls
FROM
    albums;
    
    
--  Question 3: Obtain a query to verify whether the no of artists under Peninsula Entertainments Records tallies in the record_labels and albums  
SELECT 
    CASE
        WHEN
            (SELECT 
                    total_no_artists
                FROM
                    record_labels
                WHERE
                    record_label_id = 1) = (SELECT 
                    COUNT(record_label_id)
                FROM
                    albums
                WHERE
                    record_label_id = 1)
        THEN
            'equal'
        ELSE 'not equal'
    END AS result;
    
    
-- Write a query to check at once if the no of artists in the record labels table and labums tablee are equal
SELECT 
    rl.record_label_id,
    rl.total_no_artists,
    al.no_artists_albums,
    CASE
        WHEN rl.total_no_artists = al.no_artists_albums THEN 'equal'
        ELSE 'not equal'
    END AS status
FROM
    (SELECT 
        record_label_id, total_no_artists
    FROM
        record_labels) AS rl
        JOIN
    (SELECT 
        record_label_id, COUNT(record_label_id) AS no_artists_albums
    FROM
        albums
    GROUP BY record_label_id) AS al ON rl.record_label_id = al.record_label_id;


-- Question 4: Verify that all release dates from the albums table belong to the corresponding artist contract duration as per the start and end contract dates in the artists table

SELECT 
    art.*,
    CASE
        WHEN al.release_date BETWEEN art.record_label_contract_start_date AND art.record_label_contract_end_date THEN 'valid'
        ELSE 'invalid'
    END AS validity
FROM
    artists art
        JOIN
    albums al ON art.artist_id = al.artist_id
WHERE
    art.record_label_contract_start_date IS NOT NULL
        AND art.record_label_contract_end_date IS NOT NULL;
        
-- Question 5: To speed up the process, write a query to return the no of mismatches found in the database
SELECT COUNT(A.validity) AS count_of_mismatch FROM (SELECT 
    art.*,
    CASE
        WHEN al.release_date BETWEEN art.record_label_contract_start_date AND art.record_label_contract_end_date THEN 'valid'
        ELSE 'invalid'
    END AS validity
FROM
    artists art
        JOIN
    albums al ON art.artist_id = al.artist_id
WHERE
    art.record_label_contract_start_date IS NOT NULL
        AND art.record_label_contract_end_date IS NOT NULL) A
        WHERE validity = 'invalid';
	
-------------------------------------------------------------------------------------------
SELECT 
    SUM(CASE
        WHEN al.release_date BETWEEN art.record_label_contract_start_date AND art.record_label_contract_end_date THEN 0
        ELSE 1
    END) AS count_of_validity
FROM
    artists art
        JOIN
    albums al ON art.artist_id = al.artist_id
WHERE
    art.record_label_contract_start_date IS NOT NULL
        AND art.record_label_contract_end_date IS NOT NULL;
        

-- Question 6: Find the no of albums recorded in each record label;
SELECT 
    record_label_id, COUNT(album_id) AS no_of_albums
FROM
    albums
WHERE
    record_label_id IS NOT NULL
GROUP BY record_label_id
ORDER BY no_of_albums desc;

-- Question 7: Obtain a list of unique artist IDs for all the artists that perform in any of the genre types g03, g07, and g12 and whose album release dates are all in part between the 1st of Jan. 1997 and 31st of dec. 2004
SELECT DISTINCT
    (artist_id)
FROM
    albums
WHERE
    genre_id IN ('g03' , 'g07', 'g12')
        AND release_date BETWEEN 1997 - 01 - 01 AND 2004 - 12 - 31
ORDER BY artist_id;

-- Question 8: Write a query to obtain a result about all artists that have released albums, classified in different genre
SELECT 
    a.artist_id,
    CONCAT(a.artist_first_name,
            ' ',
            a.artist_last_name) AS artist_name,
	COUNT(DISTINCT(al.genre_id)) AS no_of_genre
FROM
    artists a
        JOIN
    albums al ON a.artist_id = al.artist_id
GROUP BY artist_id
HAVING COUNT(DISTINCT(al.genre_id)) > 1;

--------------------------------------------------------------
SELECT 
    a.artist_id,
    CONCAT(a.artist_first_name,
            ' ',
            a.artist_last_name) AS artist_name,
    g.genre_id,
    g.genre_name
FROM
    artists a
        JOIN
    albums al ON a.artist_id = al.artist_id
        JOIN
    genre g ON al.genre_id = g.genre_id
-- WHERE a.artist_id = 1152
GROUP BY g.genre_id
ORDER BY artist_name;

-- Question 9: Obtain a result with all independent artists 
SELECT 
    a.artist_id,
    a.artist_first_name,
    a.artist_last_name,
    a.start_date_ind_artist
FROM
    (SELECT 
        MAX(start_date_ind_artist) as start_date_ind_artist
    FROM
        artists) aa
        JOIN
    artists a ON a.start_date_ind_artist = aa.start_date_ind_artist
WHERE
    a.dependency = 'independent artist';



SELECT 
    artist_id,
    artist_first_name,
    artist_last_name,
    start_date_ind_artist
FROM
    artists 
WHERE
    dependency = 'independent artist'
ORDER BY start_date_ind_artist desc;

-- Question 10: Create a trigger to prompt user when a newly inserted record contains some information about a child artist i.e one below the age of 18.
-- The trigger should indicate that the artist is not professional yet, they have not spent any weeks in top 100
DROP TRIGGER IF EXISTS trig_artist;
DELIMITER $$
CREATE TRIGGER trig_artist
BEFORE INSERT ON artists
FOR EACH ROW
BEGIN 
		IF (YEAR(DATE(SYSDATE())) - YEAR((NEW.birth_date))) < 18
        THEN SET NEW.dependency ='Not Professional yet'
        AND NEW.no_weeks_top_100 = 0;
        END IF;
END $$
DELIMITER ;

-- Question 11: Create a table called artist_managers which contains artist_id, artist_first_name, artist_last_name, manager_id
-- Assign artist with id 1012 as manager to all artists with id less than 1025 and artist 1022 as manager to all artists with id greater than 1250
CREATE TABLE IF NOT EXISTS artists_managers (
    artist_id INTEGER NOT NULL,
    artist_first_name VARCHAR(30) NOT NULL,
    artist_last_name VARCHAR(30) NOT NULL,
    manager_id INTEGER NOT NULL
);

Insert into artists_managers select C.* from(SELECT 
    art.artist_id,
    artist_first_name,
    artist_last_name,
    (SELECT 
            artist_id
        FROM
            albums
        WHERE
            artist_id = 1012) AS manager_id
FROM
    artists art
        JOIN
    albums al ON art.artist_id = al.artist_id
WHERE
    art.artist_id < 1025
UNION SELECT 
    art.artist_id,
    artist_first_name,
    artist_last_name,
    (SELECT 
            artist_id
        FROM
            albums
        WHERE
            artist_id = 1022) AS manager_id
FROM
    artists art
        JOIN
    albums al ON art.artist_id = al.artist_id
WHERE
    art.artist_id > 1250) AS C;
	

-- Question 12: obtain a result that shows who manages artists 1012 and 1022
  select * from artists;
SELECT 
    am1.*
FROM
    artists_managers AS am1
        JOIN
    artists_managers AS am2 ON am1.artist_id = am2.manager_id
WHERE
    am2.artist_id IN (SELECT 
            artist_id
        FROM
            artists_managers)
GROUP BY artist_id;
        
--  Question 13: Retrieve the numbers of weeks spent in the top 100 for alll artists that have been registered in the 'albums' tabble,
-- sort the output by the  number of  weeks in the descending order
SELECT 
    a.artist_id,
    a.artist_first_name,
    a.artist_last_name,
    a.no_weeks_top_100
FROM
    artists a
        RIGHT JOIN
    albums al ON a.artist_id = al.artist_id
GROUP BY a.artist_id
ORDER BY no_weeks_top_100 DESC;

-- Question 14: Create a function that takes time frame and retun the average no of weeks spent in the top 100 by artists whose year of birth falls within this timeframe.

DROP FUNCTION IF EXISTS f_avg_no_weeks_in100;

DELIMITER $$
CREATE FUNCTION f_avg_no_weeks_in100(P_start_year INTEGER, P_end_year INTEGER) RETURNS DECIMAL(10, 4)
DETERMINISTIC
BEGIN 
		DECLARE v_avg_no_weeks_in100 DECIMAL(10, 4);
        
SELECT 
    AVG(no_weeks_top_100)
INTO v_avg_no_weeks_in100 FROM
    artists
WHERE
    YEAR(birth_date) BETWEEN P_start_year AND P_end_year;
        
        RETURN v_avg_no_weeks_in100;
        
        END $$
        
        DELIMITER ;

-- Question 15: create a view that returns artists that have made albums in more than one genre

CREATE VIEW diff_genre_albums AS
    SELECT 
        a.artist_id, COUNT(DISTINCT (al.genre_id)) AS no_of_genres
    FROM
        artists a
            JOIN
        albums al ON a.artist_id = al.artist_id
    GROUP BY artist_id
    HAVING no_of_genres > 1;
        
        