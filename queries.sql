
--weighted ortalama alındı audienceın as birkaç kaynak var iyi hesaplanması için, oy sayı verisi olanlar kullanıldı sadece.
--using normalized version of imdb to weighted average
--bazı verilerde null olduğu için silmek yerine coalesce
--payda için de case when çünkü ...

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




--bunu column olarak koyalım

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


-- top kritik ve top audience filmleri nelerdir
--roundlamak

SELECT 
    title, critic_rating_rt critic_score
FROM
    movies
ORDER BY critic_rating_rt DESC
LIMIT 10


SELECT
    title,
    ROUND((weighted_audience_score::NUMERIC),0)
FROM
    movies
ORDER BY weighted_audience_score DESC
LIMIT 10


--columnu roundla güncelle

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


--en büyük kritik vs audience farklı filmler hangileri

SELECT 
    title,
    weighted_audience_score,
    critic_rating_rt,
    (critic_rating_rt-weighted_audience_score) difference
FROM
    movies
ORDER BY difference DESC


--audienceın fazla olduğu hangileri
 
SELECT 
    title,
    weighted_audience_score,
    critic_rating_rt,
    (critic_rating_rt-weighted_audience_score) difference
FROM
    movies
ORDER BY difference ASC


--correlation bw them

SELECT 
    ROUND(CORR(critic_rating_rt, weighted_audience_score)::NUMERIC, 2) AS score_correlation
FROM movies;

--0.12 gibi çok düşük bir sayı, iki veri arasında neredeyse hiçbir ilişki yok demektir.


--top of the top movies
--first weighted + critic puanı column yap total_average_score olarak also for later analyses

ALTER TABLE movies 
ADD COLUMN total_average_score NUMERIC;

UPDATE movies 
SET total_average_score = (weighted_audience_score + critic_rating_rt) / 2;



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

--drama, war, history movies top and almost all before 2000



--genre breakdown best movies

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

SELECT
    title,
    weighted_audience_score,
    critic_rating_rt,
    total_average_score,
    genre,
    year
FROM 
    movies
WHERE genre LIKE '%Fantasy%'
ORDER BY total_average_score DESC
LIMIT 10


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


--Zamanla Puanlar Nasıl Değişmiş
--grouping the years bucketing 

SELECT
    (year / 10) * 10 AS decade,
    ROUND(AVG(total_average_score),2) average_score,
    COUNT(*) AS total_movies
FROM 
    movies
GROUP BY decade
ORDER BY AVG(total_average_score) DESC

--en iyi sene 1950; en kötü 2000. genel olarak decade arttıkça puanlar düşmüş


--most popular movies 
--first, total_votes columnu yap. 

ALTER TABLE movies 
ADD COLUMN total_votes NUMERIC;

UPDATE movies 
SET total_votes = COALESCE(critic_reviews,0) + COALESCE(audience_reviews,0) + COALESCE(letterboxd_votes,0) + COALESCE(imdb_votes,0)




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



--underrated: puanı yüksek oyu düşük

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


