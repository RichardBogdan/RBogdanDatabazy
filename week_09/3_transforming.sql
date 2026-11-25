--\set ON_ERROR_STOP ON

CREATE SCHEMA IF NOT EXISTS gold;

--dim users
CREATE TABLE gold.dim_user (
    user_id INT NOT NULL UNIQUE,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M','F')),
    zip_code VARCHAR(10),
    age_group VARCHAR(20) NOT NULL,
    occupation VARCHAR(50) NOT NULL
);
CREATE TABLE gold.dim_movie (
    movie_id INT NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    release_year INT,
    genre_name VARCHAR(200) NOT NULL    --vsetky zanre budu v jednom riadku
);

CREATE TABLE gold.dim_date (
    date_id INT PRIMARY KEY,
    rated_at DATE NOT NULL UNIQUE,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(10) NOT NULL,
    week INT NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    quarter INT NOT NULL
);

CREATE TABLE gold.dim_time (
    time_id INT PRIMARY KEY,
    rated_time TIME NOT NULL UNIQUE,
    hour INT NOT NULL,
    minute INT NOT NULL,
    second INT NOT NULL,
    time_of_day VARCHAR(10) NOT NULL
);

CREATE TABLE gold.fact_rating(
    rating_id INT PRIMARY KEY,
    user_id INT NOT NULL REFERENCES gold.dim_user (user_id),
    movie_id INT NOT NULL REFERENCES gold.dim_movie (movie_id),
    date_id INT NOT NULL REFERENCES gold.dim_date (date_id),
    time_id INT NOT NULL REFERENCES gold.dim_time (time_id),
    rating NUMERIC(2,1) NOT NULL CHECK (rating BETWEEN 1 AND 5),
    rating_count INT NOT NULL,
    rating_percentage INT NOT NULL
);

--INDEY NA CUDZIE KLUCE VO FAKTOVEJ TABULKE, POSTGRE NEVYTVARA AUTOMATICKY

CREATE INDEX ON gold.fact_rating (user_id);
CREATE INDEX ON gold.fact_rating (movie_id);
CREATE INDEX ON gold.fact_rating (date_id);
CREATE INDEX ON gold.fact_rating (time_id);

BEGIN;

TRUNCATE gold.fact_rating,
gold.dim_user,
gold.dim_movie,
gold.dim_date,
gold.dim_time;

INSERT INTO gold.fact_rating (
    rating_id,
    user_id,
    movie_id,
    date_id,
    time_id
)
SELECT
    r.rating_id,
    r.user_id,
    r.movie_id,
    d.date_id,
    t.time_id
FROM silver.stg_ratings r
JOIN gold.dim_date d
    ON d.rated_at = r.rated_at::DATE
JOIN gold.dim_time t
    ON t.rated_time = r.rated_at::TIME;

INSERT INTO gold.dim_user(
    user_id,
    gender,
    zip_code,
    age_group,
    occupation
)
SELECT u.user_id, u.gender, u.zip_code, COALESCE(a.age_group, 'unknown'), COALESCE(o.occupation_name, 'unknown')
FROM silver.stg_users u
    LEFT JOIN silver.stg_age_group a ON a.age_group_id = u.user_id
    LEFT JOIN silver.stg_occupations o ON o.occupation_id = u.occupation_id
ORDER BY u.user_id;

INSERT INTO gold.dim_movie (
    movie_id,
    title,
    release_year,
    genre_name
)
SELECT
    m.movie_id,
    m.title,
    m.release_year,
    COALESCE(g.genre_name, 'unknown')
FROM silver.stg_movies m
LEFT JOIN (
    SELECT
        gm.movie_id,
        STRING_AGG(
            g.genre_name, ', ' ORDER BY g.genre_name
        ) AS genre_name
    FROM silver.stg_genres_movies gm
    JOIN silver.stg_genres g                    --i cant ono to ma v sebe occupation id XDDDDDDDDDDDDDD
        ON g.genre_id = gm.genre_id
    GROUP BY gm.movie_id
) g ON g.movie_id = m.movie_id
ORDER BY m.movie_id;

INSERT INTO gold.dim_date (
    date_id,
    rated_at,
    day,
    month,
    year,
    day_of_week,
    day_name,
    week,
    month_name,
    quarter
)
SELECT
    ROW_NUMBER() OVER (ORDER BY rated_at)::INT,
    rated_at,
    EXTRACT(DAY FROM rated_at)::INT,
    EXTRACT(MONTH FROM rated_at)::INT,
    EXTRACT(YEAR FROM rated_at)::INT,
    EXTRACT(ISODOW FROM rated_at)::INT,
    TO_CHAR(rated_at, 'Day'),
    EXTRACT(WEEK FROM rated_at)::INT,
    TO_CHAR(rated_at, 'Month'),
    EXTRACT(QUARTER FROM rated_at)::INT
FROM (
    SELECT DISTINCT rated_at::DATE AS rated_at
    FROM silver.stg_ratings
) d;

INSERT INTO gold.dim_time (
    time_id,
    rated_time,
    hour,
    minute,
    second,
    time_of_day
)
SELECT
    ROW_NUMBER() OVER (ORDER BY rated_time)::INT,
    rated_time,
    EXTRACT(HOUR FROM rated_time)::INT,
    EXTRACT(MINUTE FROM rated_time)::INT,
    EXTRACT(SECOND FROM rated_time)::INT,
    CASE
        WHEN EXTRACT(HOUR FROM rated_time) BETWEEN 6 AND 11
            THEN 'morning'
        WHEN EXTRACT(HOUR FROM rated_time) BETWEEN 12 AND 17
            THEN 'afternoon'
        WHEN EXTRACT(HOUR FROM rated_time) BETWEEN 18 AND 21
            THEN 'evening'
        ELSE 'night'
    END
FROM (
    SELECT DISTINCT rated_at::TIME AS rated_time
    FROM silver.stg_ratings
) t;

COMMIT;
