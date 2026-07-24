
-- Creating a total_votes column combining critic and audience review counts from all platforms

ALTER TABLE movies 
ADD COLUMN total_votes NUMERIC;

UPDATE movies 
SET total_votes = COALESCE(critic_reviews,0) + COALESCE(audience_reviews,0) + COALESCE(letterboxd_votes,0) + COALESCE(imdb_votes,0)


-- Question: Which movies are the most popular based on total combined engagement?

SELECT
    title,
    total_votes,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year
FROM movies
ORDER BY total_votes DESC


/* Question: What are the most underrated movies in the dataset? 
- Filtering for high overall scores despite having a lower volume of total votes (under 200,000) */

SELECT 
    title,
    total_average_score,
    total_votes
FROM
    movies
WHERE
    total_votes <= 200000
ORDER BY 
    total_average_score DESC
LIMIT 20


