-- Create the database with UTF8 encoding and template0, due to local computer system encoding settings

CREATE DATABASE top_movies_db 
WITH ENCODING = 'UTF8' 
TEMPLATE = template0;


-- Define the schema for the raw 'movies' table

CREATE TABLE movies (
    "rank" INT,
    "title" VARCHAR(255),
    "year" INT,
    "genre" VARCHAR(255),
    "director" VARCHAR(264),
    "cast_memnbers" VARCHAR(255),
    "language" VARCHAR(255),
    "plot" TEXT,
    "awards" VARCHAR(255),
    "production" VARCHAR(255),
    "flickmetrix_Score" FLOAT,
    "imdb_10" FLOAT,
    "imdb_100" FLOAT,
    "imdb_votes" INT,
    "metacritic" FLOAT,
    "critic_rating_rt" FLOAT,
    "critic_reviews" INT,
    "audience_rating" FLOAT,
    "audience_reviews" FLOAT,
    "letterboxd" INT,
    "letterboxd_votes" FLOAT,
    "google_score" FLOAT,
    "streaming_on" VARCHAR(255),
    "rt_url" VARCHAR(255),
    "imdbid" VARCHAR(255),
    "custom_score" FLOAT
);


-- Then the CSV is imported using pgadmin into the 'movies' table

