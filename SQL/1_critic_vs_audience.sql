/* Weighted average is calculated for the audience score using multiple sources. 
- Using the normalized version of IMDb for the weighted average.
- Using COALESCE instead of deleting rows where certain data is null.
- Using CASE WHEN in the denominator to prevent adding vote counts when the corresponding score or vote value is null.
*/

SELECT 
    title, 
    (
        COALESCE(imdb_100 * imdb_votes, 0) +
        COALESCE(letterboxd * letterboxd_votes, 0) +
        COALESCE(audience_rating * audience_reviews, 0)
    ) / NULLIF(
        CASE WHEN imdb_100 IS NULL OR imdb_votes IS NULL THEN 0 ELSE imdb_votes END +
        CASE WHEN letterboxd IS NULL OR letterboxd_votes IS NULL THEN 0 ELSE letterboxd_votes END +
        CASE WHEN audience_rating IS NULL OR audience_reviews IS NULL THEN 0 ELSE audience_reviews END,
    0) AS weighted_audience_score
FROM
    movies;


-- Adding this as a column to the table

ALTER TABLE movies ADD COLUMN weighted_audience_score NUMERIC;

UPDATE movies m
SET weighted_audience_score = sub.weighted_audience_score
FROM (
    SELECT 
        title, 
        (
            COALESCE(imdb_100 * imdb_votes, 0) +
            COALESCE(letterboxd * letterboxd_votes, 0) +
            COALESCE(audience_rating * audience_reviews, 0)
        ) / NULLIF(
            CASE WHEN imdb_100 IS NULL OR imdb_votes IS NULL THEN 0 ELSE imdb_votes END +
            CASE WHEN letterboxd IS NULL OR letterboxd_votes IS NULL THEN 0 ELSE letterboxd_votes END +
            CASE WHEN audience_rating IS NULL OR audience_reviews IS NULL THEN 0 ELSE audience_reviews END,
        0) AS weighted_audience_score
    FROM
        movies
) sub
WHERE m.title = sub.title;


/* Question: What are the top critic and top audience movies?
- Rounding the scores for cleaner presentation */

SELECT 
    title, 
    critic_rating_rt,
    weighted_audience_score,
    genre,
    year,
    director,
    cast_memnbers,
    awards,
    production,
    streaming_on
FROM
    movies
ORDER BY critic_rating_rt DESC
LIMIT 10


SELECT
    title,
    ROUND((weighted_audience_score::NUMERIC),0),
    critic_rating_rt,
    genre,
    year,
    director,
    cast_memnbers,
    awards,
    production,
    streaming_on
FROM
    movies
ORDER BY weighted_audience_score DESC
LIMIT 10

--Only two films (The Godfather and Seven Samurai) appear in both top-10 lists.
--The critics lean more into near-universal critical consensus (Citizen Kane at 98%), while the audience focuses more on adventures and huge cultural hits, such as The Lord of the Rings.
--Older movies produced by with famous directors like Francis Ford Coppola and Akira Kurosawa are on both lists.


-- Update the column with rounded values

UPDATE movies m
SET weighted_audience_score = sub.rounded_score
FROM (
    SELECT 
        title, 
        ROUND(weighted_audience_score::NUMERIC, 0) AS rounded_score
    FROM
        movies
) sub
WHERE m.title = sub.title;


-- Question: Which movies have the biggest discrepancy between critics and audience' scores?

SELECT 
    title,
    weighted_audience_score,
    critic_rating_rt,
    (critic_rating_rt-weighted_audience_score) difference,
    genre,
    year,
    director,
    cast_memnbers,
    awards,
    production,
    streaming_on
FROM
    movies
ORDER BY difference DESC

--Critics tend to give higher scores than audiences for roughly 70% of the films.
--Prestige classics and animations have the widest gaps favoring critics (e.g., Pinocchio at +21, E.T. at +20, Snow White at +19).
--Audiences tend to rate cult classics and thrillers (Fight Club, Interstellar) much higher than critics.
--Older films show the strongest critic favorability, while films from the 1990s and 2000s lean slightly toward higher audience scores.


-- Question: What's the correlation between critic ratings and weighted audience scores?

SELECT 
    ROUND(CORR(critic_rating_rt, weighted_audience_score)::NUMERIC, 2) AS score_correlation
FROM movies;

-- A very low number of 0.12 means there is almost no relationship relationship between how critics and audiences rate these films.
-- CAVEAT: this is a curated top-N dataset (all films already cleared a quality bar), which restricts score range and mechanically weakens correlation
