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
    year,
    director,
    cast_memnbers,
    awards,
    production,
    streaming_on
FROM 
    movies
WHERE
    weighted_audience_score > 85 AND
    critic_rating_rt > 85
ORDER BY
    total_average_score DESC
LIMIT 30

-- Classic-era heavy: Half the films are from before 1966. Median year 1965, only 3 films after 2000 (Spirited Away, Parasite, Portrait of a Lady on Fire)
-- Coppola leads directors (3 films), Paramount leads studios (6 films)

-- Filtering top-tier list by genre: e.g. Drama

WITH top_movies AS (

SELECT
    title,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year,
    director,
    cast_memnbers,
    awards,
    production,
    streaming_on
FROM 
    movies
WHERE
    weighted_audience_score > 85 AND
    critic_rating_rt > 85
ORDER BY
    total_average_score DESC
LIMIT 30
)

SELECT * FROM top_movies
WHERE genre LIKE '%Drama%'

-- Drama dominates: 20/30 titles. Crime and Thriller tied for distant second (6 each)

-- Genre breakdown: Top 10 horror movies

SELECT
    title,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year,
    director,
    cast_memnbers,
    awards,
    production,
    streaming_on
FROM 
    movies
WHERE genre LIKE '%Horror%'
ORDER BY total_average_score DESC
LIMIT 10


-- Genre breakdown: Top 10 drama movies

SELECT
    title,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year,
    director,
    cast_memnbers,
    awards,
    production,
    streaming_on
FROM 
    movies
WHERE genre LIKE '%Drama%'
ORDER BY total_average_score DESC
LIMIT 10


-- Genre breakdown: Top 10 family movies

SELECT
    title,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year,
    director,
    cast_memnbers,
    awards,
    production,
    streaming_on
FROM 
    movies
WHERE genre LIKE '%Family%'
ORDER BY total_average_score DESC
LIMIT 10


-- Genre breakdown: Top 10 science fiction movies

SELECT
    title,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year,
    director,
    cast_memnbers,
    awards,
    production,
    streaming_on
FROM 
    movies
WHERE genre LIKE '%Science Fiction%'
ORDER BY total_average_score DESC
LIMIT 10

-- Drama scores highest (92.2 avg). Horror/Sci-Fi/Family cluster lower (86.6-87.8) — likely era, not genre quality (see below)
-- Drama & Horror skew old (avg 1964/1961); Sci-Fi & Family skew newer (1985/1990)

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

-- 1950s highest, 2000s lowest - scores decline as decades progress
-- Likely canonization lag (older films had more time to build consensus for a top-400 list), not real quality decline


/* Question: Is it possible that Drama scores higher because of the genre itself, 
   or is it just that Drama-tagged films skew older (and older films score higher overall)? 
   Comparing Drama vs Non-Drama within the same decade isolates the genre effect from the era effect. */

SELECT
    (year / 10) * 10 AS decade,
    CASE WHEN genre LIKE '%Drama%' THEN 'Drama' ELSE 'Non-Drama' END AS is_drama,
    ROUND(AVG(total_average_score), 2) AS avg_score,
    COUNT(*) AS n
FROM movies
GROUP BY decade, is_drama
ORDER BY decade, is_drama


-- Drama leads pre-1960s (+1.25 to +2.4 pts), gap disappears post-1980s (likely small-sample noise pre-1960s, n=2-19)
-- Confirmed: both groups decline together over time - era effect, not genre
