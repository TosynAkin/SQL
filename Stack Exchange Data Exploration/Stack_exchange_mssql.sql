SELECT *
FROM Comments

SELECT * 
FROM posts

SELECT *
FROM Users

SELECT *
FROM Votes

--playing around, trying to understand the data


SELECT Id, Title, body
FROM dbo.posts
WHERE Id = 4

/*SELECT body
FROM dbo.posts
WHERE Id = 4*/

--HOW MANY POSTS WERE MADE EACH YEAR?

SELECT YEAR(CreationDate) AS year_of_creation, COUNT(Id) AS no_of_posts
FROM Posts
GROUP BY YEAR(CreationDate)
ORDER BY YEAR(CreationDate)

--HOW MANY VOTES WERE MADE EACH DAY OF THE WEEK?

SELECT DATENAME(WEEKDAY, CreationDate) AS day_of_the_week, COUNT(Id) AS no_of_votes
FROM Votes
GROUP BY DATENAME(WEEKDAY, CreationDate)

--LIST ALL COMMENTS CREATED ON SEPTEMBER 19TH, 2012
SELECT CreationDate, TEXT AS COMMENT
FROM Comments
WHERE YEAR(CreationDate) = 2012 AND DAY(CreationDate) = 19 AND MONTH(CreationDate) =  9

--LIST ALL USERS UNDER THE AGE OF 33 LIVING IN LONDON
SELECT * 
FROM Users
WHERE AGE<33 AND Location like '%London%'

--LIST ALL COMMENT THAT CONTAINS THE WORD 'interesting'
SELECT *
FROM Comments
WHERE TEXT LIKE '%interesting%'

--HOW MANY VOTES DID EACH POST HAVE?
SELECT PostId, COUNT(*) AS no_of_votes
FROM Votes
GROUP BY PostId
ORDER BY COUNT(*) DESC

--POSTS WITH VOTES > 10
SELECT PostId, COUNT(*) AS no_of_votes
FROM Votes
GROUP BY PostId
HAVING COUNT(*) > 10

----------------------------------------------------------------
--Display the number of votes for each post title
SELECT p.Id, p.Title, COUNT(v.Id) AS no_of_votes
FROM Posts AS p
JOIN Votes AS v
ON p.Id = v.PostId
GROUP BY p.Id, p.Title
ORDER BY COUNT(*) DESC

--Display posts with comments created by users living in the same location as the post creator
SELECT p.Id AS post_id,
p.Title AS post_title,
p.OwnerUserId AS created_by,
u_p.Id AS userId,
u_p.DisplayName AS creator_username,
u_p.Location AS creator_location,
c.UserId AS commentor_id,
u_c.DisplayName AS commentor_username,
u_c.Location AS commentor_location
FROM Posts p 
JOIN Users u_p
ON p.OwnerUserId = u_p.Id
JOIN Comments c
ON p.Id = c.PostId
JOIN Users u_c
ON u_c.Id = c.UserId
WHERE u_p.Location = u_c.Location

--How many users have never voted?
SELECT COUNT(distinct u.Id) AS no_users_that_never_voted
FROM Users u
LEFT JOIN Votes v
ON u.Id = v.UserId
WHERE v.UserId IS NULL

--Display all posts having the highest amount of comments
SELECT p.Title, COUNT(*) AS no_of_comments
FROM Posts AS p
JOIN Comments AS c
ON p.Id = c.PostId
GROUP BY p.Title
ORDER BY COUNT(c.Id) DESC
GO

--OR

WITH "HIGHEST AMOUNT OF COMMENTS"
AS
	(
	SELECT p.Title,
		COUNT(*) AS 'no_of_comments',
		DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS 'comment_rank'
	FROM Posts AS p
	JOIN Comments AS c
	ON p.Id = c.PostId
	GROUP BY p.Title
	)
SELECT Title
FROM "HIGHEST AMOUNT OF COMMENTS"
WHERE comment_rank = 1
	
--For each post, how many votes are coming from users living in germany? What’s their percentage of the total number of votes
/*SELECT p.Id AS post_id,
p.Title AS post_title,
COUNT(v_p.Id) AS no_of_vote,
u_v.Location AS location_of_vote
FROM Posts p 
JOIN Votes v_p
ON p.Id = v_p.PostId
JOIN Users u_v
ON u_v.Id = v_p.UserId
WHERE u_v.Location LIKE '%canada%'
GROUP BY u_v.Location, p.Id, p.Title

with "abc" as
	(
	SELECT p.Id AS post_id,
	p.Title AS post_title,
	COUNT(v_p.Id) AS no_of_vote,
	u_v.Location AS location_of_vote
	FROM Posts p 
	JOIN Votes v_p
	ON p.Id = v_p.PostId
	JOIN Users u_v
	ON u_v.Id = v_p.UserId
	WHERE u_v.Location LIKE '%canada%'
	GROUP BY u_v.Location, p.Id, p.Title
	)
select sum(no_of_vote)
from abc*/

SELECT p.Title, 
        COUNT(*) AS total_votes, 
        SUM(CASE WHEN u.location LIKE '%germany%' THEN 1 ELSE 0 END) AS 'votes_from_germany',
        CAST(SUM(CASE WHEN u.location LIKE '%germany%' THEN 1 ELSE 0 END) AS FLOAT) /
        CAST(COUNT(*) AS FLOAT) AS 'votes_percentage'
FROM posts AS p JOIN votes AS v
ON   p.Id = v.postID
               JOIN users AS u
ON   v.UserID = u.id
GROUP BY p.Title
ORDER BY COUNT(*) DESC 

--For each post, how many comments are coming from users living in germany? What’s their percentage of the total number of comment
SELECT p.Title, 
        COUNT(*) AS total_comments, 
        SUM(CASE WHEN u.location LIKE '%germany%' THEN 1 ELSE 0 END) AS 'comments_from_germany',
        CAST(SUM(CASE WHEN u.location LIKE '%germany%' THEN 1 ELSE 0 END) AS FLOAT) /
        CAST(COUNT(*) AS FLOAT) AS 'comments_percentage'
FROM posts AS p JOIN Comments AS c
ON   p.Id = c.postID
               JOIN users AS u
ON   c.UserID = u.id
GROUP BY p.Title
ORDER BY COUNT(*) DESC 

--Whats the most common post tag ?
SELECT DISTINCT Tags, COUNT(*)
FROM posts
GROUP BY Tags
ORDER BY COUNT(*) DESC
GO


WITH "CTE-TAGS-SEP" (Tags) AS
(
    SELECT CAST(Tags AS VARCHAR(MAX)) 
    FROM Posts
    UNION ALL
    SELECT STUFF(Tags, 1, CHARINDEX('><' , Tags), '') 
    FROM "CTE-TAGS-SEP"
    WHERE Tags  LIKE '%><%'
), "CTE-TAGS-COUNTER" AS 
(   
    SELECT CASE WHEN Tags LIKE '%><%' THEN LEFT(Tags, CHARINDEX('><' , Tags)) 
                ELSE Tags 
            END AS 'Tags'
    FROM "CTE-TAGS-SEP"
)
SELECT TOP 1 COUNT(*), Tags
FROM "CTE-TAGS-COUNTER"
GROUP BY Tags 
ORDER BY COUNT(*) DESC

/*SELECT REPLACE(REPLACE(REPLACE(Tags, '><', ','), '<',''),'>','') 'TAGS' INTO #TABI2
FROM posts
SELECT VALUE, COUNT(*)
FROM #TABI2
CROSS APPLY string_split(TAGS, ',')
GROUP BY VALUE
ORDER BY COUNT(*) DESC*/

WITH /*"CTE-TAGS-SEP" (Tags) AS
(
    SELECT CAST(Tags AS VARCHAR(MAX)) 
    FROM Posts
    UNION ALL
    SELECT STUFF(Tags, 1, CHARINDEX('><' , Tags), '') 
    FROM "CTE-TAGS-SEP"
    WHERE Tags  LIKE '%><%'
),*/ "CTE-TAGS-COUNTER" AS 
(   
    SELECT CASE WHEN Tags LIKE '%><%' THEN LEFT(Tags, CHARINDEX('><' , Tags)) 
                ELSE Tags 
            END AS 'Tags'
    FROM Posts
)
SELECT TOP 1 COUNT(*), Tags
FROM "CTE-TAGS-COUNTER"
GROUP BY Tags 
ORDER BY COUNT(*) DESC


-- 8. Create a pivot table displaying how many posts were created for each year (Y axis) and each month (X axis)
SELECT *   
FROM (  
    SELECT YEAR(CreationDate) AS 'Year', DATENAME(MONTH,CreationDate) AS 'Month', id
    FROM posts
  ) AS S  
PIVOT   
     (   
    COUNT(id) 
    FOR  [Month] IN ([January], [February], [March], [April], [May], [June], [July], [August], [September], [October], [November], [December]) 
   ) AS PVT
ORDER BY [Year]