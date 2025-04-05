 --Netflix Project

DROP TABLE IF EXISTS netflix;
Create Table netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	releae_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listen_in VARCHAR(100),
	description VARCHAR(250)
	
);

Select * from netflix
	
Alter table netflix
rename column listen_in to listed_in;

Alter table netflix
rename column releae_year to release_year;


--1. Count the Number of Movies vs TV Shows

SELECT
	type,
    COUNT(*) as total_content
FROM netflix
GROUP BY type

--2. Find the Most Common Rating for Movies and TV Shows

SELECT 
	type,
	rating
FROM
(SELECT 
    type,
    rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1,2
) as t1
WHERE 
    ranking = 1

--3. List All Movies Released in a Specific Year (e.g., 2020)

SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
    releae_year = 2020

--4. Find the Top 5 Countries with the Most Content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--5. Identify the Longest Movie

SELECT * FROM netflix
WHERE 
	type = 'Movie' 
    AND
    duration = (SELECT MAX(duration) FROM netflix)

--6. Find Content Added in the Last 5 Years

SELECT 
	* 
FROM netflix
WHERE
    TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT
	*
FROM netflix
WHERE
     director ILIKE '%Rajiv Chilaka%'
    
--8. List All TV Shows with More Than 5 Seasons

SELECT
	* 
FROM netflix
WHERE
	type = 'TV Show'
	AND
    SPLIT_PART(duration, ' ', 1)::numeric > 5

--9. Count the Number of Content Items in Each Genre

SELECT
     UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	 COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

--10.Find each year and the average numbers of content release in India on netflix.

SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*),
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric *100 , 2)as avg_content_per_year
FROM netflix
WHERE
    country ILIKE '%India%'
GROUP BY 1


--11. List All Movies that are Documentaries

SELECT 
	* 
FROM netflix
WHERE
listed_in ILIKE '%documentaries%'

--12. Find All Content Without a Director

SELECT 
	*
FROM netflix
WHERE
    director IS NULL

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT 
	*
FROM netflix
WHERE
    casts ILIKE '%Salman Khan%'
    AND
    release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
	UNNEST(STRING_TO_ARRAY(casts , ',')) as actor,
	COUNT(*) as total_content
FROM netflix
WHERE
	country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

WITH new_table
AS
(
SELECT 
	*,
	CASE 
	WHEN 
		description ILIKE '%Kill%' OR
		description ILIKE '%Violence%' THEN 'BAD Content'
		ELSE 'Good Content'
	END category
FROM netflix
)
SELECT 
	category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1

--16. Find the Oldest Movie or TV Show on Netflix

SELECT * 
FROM netflix
ORDER BY release_year ASC
LIMIT 1;

--17. Find the Top 10 Directors with the Most Content on Netflix

SELECT 
    UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name,
    COUNT(*) AS total_content
FROM netflix
WHERE director IS NOT NULL
GROUP BY director_name
ORDER BY total_content

--18. Count Content Type (Movies vs TV Shows) Over the Years

SELECT 
    release_year,
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY release_year, type
ORDER BY release_year;

--19. Content with No Cast Information

SELECT * 
FROM netflix
WHERE casts IS NULL OR TRIM(casts) = '';

--20. Top 5 Most Common Genres

SELECT 
    TRIM(genre) AS genre,
    COUNT(*) AS total_count
FROM (
    SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
    FROM netflix
) AS t
GROUP BY genre
ORDER BY total_count DESC
LIMIT 5;