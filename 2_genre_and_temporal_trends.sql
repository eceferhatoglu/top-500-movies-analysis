-- Creating the total_average_score column combining the weighted audience score and critic rating for later analyses

ALTER TABLE movies 
ADD COLUMN total_average_score NUMERIC;

UPDATE movies 
SET total_average_score = (weighted_audience_score + critic_rating_rt) / 2;


/* Question: What are the top-tier movies? (Liked the most by both audience and critics)
-- Filtering for films where both the weighted audience score and the critic rating exceed 85 */

SELECT
    title,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year
FROM 
    movies
WHERE
    weighted_audience_score > 85 AND
    critic_rating_rt > 85
ORDER BY
    total_average_score DESC
LIMIT 30

-- Drama, war, and history movies dominate the top tier, and almost all of them were released before 2000.


-- Genre breakdown: Best horror movies

SELECT
    title,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year
FROM 
    movies
WHERE genre LIKE '%Horror%'
ORDER BY total_average_score DESC
LIMIT 10


-- Genre breakdown: Best drama movies

SELECT
    title,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year
FROM 
    movies
WHERE genre LIKE '%Drama%'
ORDER BY total_average_score DESC
LIMIT 10


-- Genre breakdown: Best family movies

SELECT
    title,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year
FROM 
    movies
WHERE genre LIKE '%Family%'
ORDER BY total_average_score DESC
LIMIT 10


-- Genre breakdown: Best science fiction movies

SELECT
    title,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year
FROM 
    movies
WHERE genre LIKE '%Science Fiction%'
ORDER BY total_average_score DESC
LIMIT 10


/* Question: How have movie scores changed over time? 
- Grouping release years into decade buckets (e.g., 1950s, 1960s) to analyze score evolution across decades. */

SELECT
    (year / 10) * 10 AS decade,
    ROUND(AVG(total_average_score),2) average_score,
    COUNT(*) AS total_movies
FROM 
    movies
GROUP BY decade
ORDER BY AVG(total_average_score) DESC

-- The 1950s is the best-performing decade, while the 2000s are the lowest. 
-- In general, as the decades progress, the average scores tend to drop.
