
-- Creating a total_votes column combining critic and audience review counts from all platforms
-- NOTE: sources are highly different scales — result dominated by audience, not an even blend

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
    year,
    director,
    cast_memnbers,
    awards,
    production,
    streaming_on
FROM movies
ORDER BY total_votes DESC
LIMIT 20

-- Votes and score are NOT correlated — Titanic tops votes (27.9M) but lowest score (76.0); Parasite scores highest (92.0) on just 6.1M
-- Votes skew newer (opposite of the "older = higher score" trend) — popularity and quality are separate dimensions


/* Question: What are the most underrated movies in the dataset? 
- Filtering for high overall scores despite having a lower volume of total votes (under 200,000) */

SELECT 
    title,
    total_average_score,
    total_votes,
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
    total_votes <= 200000
ORDER BY 
    total_average_score DESC
LIMIT 20

-- Documentaries overrepresented (5/20) — rarely reach blockbuster vote counts regardless of quality
-- High scores (85-89) at 110K-200K votes vs. popular list's 5-28M — reach and acclaim are independent tracks
-- A few recent entries (2021-2025) have no awards data yet — too new for full canonization