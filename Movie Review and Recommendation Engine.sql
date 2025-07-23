

use college;
-- 1. Database Schema (DDL Scripts)

-- Users table
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    location VARCHAR(100)
);

-- Movies table
CREATE TABLE Movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    release_year INT,
    duration INT,
    language VARCHAR(50)
);

-- Genres table
CREATE TABLE Genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(50) UNIQUE
);

-- Movie_Genres (Many-to-Many)
CREATE TABLE Movie_Genres (
    movie_id INT REFERENCES Movies(movie_id),
    genre_id INT REFERENCES Genres(genre_id),
    PRIMARY KEY (movie_id, genre_id)
);

-- Ratings table
CREATE TABLE Ratings (
    rating_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    movie_id INT REFERENCES Movies(movie_id),
    rating DECIMAL(2,1) CHECK (rating BETWEEN 0 AND 5),
    rated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reviews table
CREATE TABLE Reviews (
    review_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    movie_id INT REFERENCES Movies(movie_id),
    review_text TEXT,
    sentiment_score DECIMAL(3,2) CHECK (sentiment_score BETWEEN -1 AND 1),
    reviewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Watch_History table (user behavior tracking)
CREATE TABLE Watch_History (
    watch_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    movie_id INT REFERENCES Movies(movie_id),
    watch_date DATE,
    watch_duration INT, -- in minutes
    completed BOOLEAN
);

-- 2. Sample Data (Few Inserts)
--  Genres
INSERT INTO Genres (genre_name) VALUES 
('Action'), ('Comedy'), ('Drama'), ('Sci-Fi'), 
('Thriller'), ('Romance'), ('Horror'), ('Adventure');

--  Users
INSERT INTO Users (name, age, gender, location) VALUES 
('Amit Sharma', 25, 'Male', 'Mumbai'),
('Priya Patel', 30, 'Female', 'Delhi'),
('Rahul Verma', 28, 'Male', 'Pune'),
('Sneha Iyer', 22, 'Female', 'Chennai'),
('Rohan Mehta', 35, 'Male', 'Bangalore'),
('Tanvi Desai', 27, 'Female', 'Ahmedabad');

--  Movies
INSERT INTO Movies (title, release_year, duration, language) VALUES 
('Inception', 2010, 148, 'English'),
('3 Idiots', 2009, 170, 'Hindi'),
('Interstellar', 2014, 169, 'English'),
('Dangal', 2016, 161, 'Hindi'),
('The Conjuring', 2013, 112, 'English'),
('Zindagi Na Milegi Dobara', 2011, 155, 'Hindi'),
('Avengers: Endgame', 2019, 181, 'English'),
('Queen', 2014, 146, 'Hindi');

-- Movie_Genres
INSERT INTO Movie_Genres VALUES 
(1, 4), -- Inception - Sci-Fi
(2, 2), (2, 3), -- 3 Idiots - Comedy, Drama
(3, 4), (3, 5), -- Interstellar - Sci-Fi, Thriller
(4, 3), (4, 5), -- Dangal - Drama, Thriller
(5, 7), -- The Conjuring - Horror
(6, 2), (6, 8), -- ZNMD - Comedy, Adventure
(7, 1), (7, 4), -- Endgame - Action, Sci-Fi
(8, 3), (8, 6); -- Queen - Drama, Romance

--  Ratings
INSERT INTO Ratings (user_id, movie_id, rating) VALUES 
(1, 1, 4.5), (1, 2, 4.0), (1, 3, 5.0),
(2, 2, 5.0), (2, 4, 4.5),
(3, 5, 4.2), (3, 1, 4.8), (3, 6, 4.0),
(4, 6, 4.5), (4, 7, 5.0),
(5, 8, 4.6), (5, 4, 4.3),
(6, 2, 4.8), (6, 8, 5.0);

-- Reviews
INSERT INTO Reviews (user_id, movie_id, review_text, sentiment_score) VALUES 
(1, 1, 'Mind-blowing movie!', 0.9),
(1, 3, 'Best sci-fi experience ever.', 0.95),
(2, 2, 'Very emotional and funny', 0.8),
(3, 5, 'Scary and thrilling!', 0.75),
(4, 6, 'Beautiful message and visuals.', 0.88),
(5, 4, 'Inspirational and well-acted.', 0.85),
(6, 8, 'Truly empowering!', 0.92);

--  Watch_History
INSERT INTO Watch_History (user_id, movie_id, watch_date, watch_duration, completed) VALUES 
(1, 1, '2024-07-01', 148, true),
(1, 2, '2024-07-05', 85, false),
(1, 3, '2024-07-10', 169, true),
(2, 2, '2024-07-02', 170, true),
(2, 4, '2024-07-12', 160, true),
(3, 5, '2024-07-08', 90, false),
(3, 6, '2024-07-15', 155, true),
(4, 6, '2024-07-17', 155, true),
(4, 7, '2024-07-18', 181, true),
(5, 8, '2024-07-20', 140, true),
(5, 4, '2024-07-13', 120, false),
(6, 2, '2024-07-03', 160, true),
(6, 8, '2024-07-16', 146, true);


-- 3. Smart SQL Queries
-- a. Top 5 Movies by Average Rating
SELECT m.title, ROUND(AVG(r.rating), 2) AS avg_rating
FROM Movies m
JOIN Ratings r ON m.movie_id = r.movie_id
GROUP BY m.title
ORDER BY avg_rating DESC
LIMIT 5;

-- b. User’s Favorite Genre
SELECT u.name, g.genre_name, COUNT(*) AS total_watched
FROM Users u
JOIN Watch_History wh ON u.user_id = wh.user_id
JOIN Movie_Genres mg ON wh.movie_id = mg.movie_id
JOIN Genres g ON mg.genre_id = g.genre_id
GROUP BY u.name, g.genre_name
ORDER BY total_watched DESC;

-- c. Rank Movies by Sentiment + Rating
SELECT 
    m.title,
    ROUND(AVG(r.rating),2) AS avg_rating,
    ROUND(AVG(rv.sentiment_score),2) AS avg_sentiment,
    RANK() OVER (ORDER BY AVG(r.rating) + AVG(rv.sentiment_score) DESC) AS smart_rank
FROM Movies m
JOIN Ratings r ON m.movie_id = r.movie_id
JOIN Reviews rv ON m.movie_id = rv.movie_id
GROUP BY m.title;

-- d. Identify High Engagement Users
SELECT u.name, COUNT(*) AS total_movies, 
       SUM(CASE WHEN wh.completed THEN 1 ELSE 0 END) AS completed_movies
FROM Users u
JOIN Watch_History wh ON u.user_id = wh.user_id
GROUP BY u.name
HAVING SUM(CASE WHEN wh.completed THEN 1 ELSE 0 END) > 1;

-- d. Identify High Engagement Users
SELECT u.name, COUNT(*) AS total_movies, 
       SUM(CASE WHEN wh.completed THEN 1 ELSE 0 END) AS completed_movies
FROM Users u
JOIN Watch_History wh ON u.user_id = wh.user_id
GROUP BY u.name
HAVING SUM(CASE WHEN wh.completed THEN 1 ELSE 0 END) > 1;

-- 4. Views
CREATE VIEW recommended_movies AS
SELECT m.title, ROUND(AVG(r.rating),2) AS avg_rating
FROM Movies m
JOIN Ratings r ON m.movie_id = r.movie_id
GROUP BY m.title
HAVING AVG(r.rating) >= 4.0;

