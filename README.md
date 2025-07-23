# -Movie-Review-and-Recommendation-Engine



## 📌 Overview
This project is a SQL-based simulation of a movie review and recommendation system. It manages user interactions, tracks viewing behavior, captures sentiment in reviews, and provides smart recommendations — all within a normalized PostgreSQL database structure. Inspired by real-world platforms like IMDb and Netflix, this system demonstrates how data-driven logic can power personalized recommendations.

---

## 🧱 Database Schema

### 📂 Tables
- **Users**: User profile info
- **Movies**: Movie metadata
- **Genres**: Unique list of genres
- **Movie_Genres**: Many-to-many mapping of movies and genres
- **Ratings**: User ratings for movies
- **Reviews**: Text reviews with sentiment score
- **Watch_History**: Viewing activity log per user

### 🔑 Relationships
- One-to-many: Users → Ratings / Reviews / Watch_History
- Many-to-many: Movies ↔ Genres via `Movie_Genres`

---

## 🧪 Sample Data

Includes data for:
- **8 Genres**
- **6 Users**
- **8 Movies** with multi-genre support
- **14 Ratings**, **7 Reviews**
- **13 Watch_History** entries (partial and complete views)

All inserts simulate realistic platform behavior and demographics.

---

## 🧠 Smart SQL Queries

### 🔝 Top 5 Movies by Average Rating

SELECT m.title, ROUND(AVG(r.rating), 2) AS avg_rating
FROM Movies m
JOIN Ratings r ON m.movie_id = r.movie_id
GROUP BY m.title
ORDER BY avg_rating DESC
LIMIT 5;

🎯 User’s Favorite Genre
SELECT u.name, g.genre_name, COUNT(*) AS total_watched
FROM Users u
JOIN Watch_History wh ON u.user_id = wh.user_id
JOIN Movie_Genres mg ON wh.movie_id = mg.movie_id
JOIN Genres g ON mg.genre_id = g.genre_id
GROUP BY u.name, g.genre_name
ORDER BY total_watched DESC;

📊 Rank Movies by Sentiment + Rating
SELECT 
    m.title,
    ROUND(AVG(r.rating),2) AS avg_rating,
    ROUND(AVG(rv.sentiment_score),2) AS avg_sentiment,
    RANK() OVER (ORDER BY AVG(r.rating) + AVG(rv.sentiment_score) DESC) AS smart_rank
FROM Movies m
JOIN Ratings r ON m.movie_id = r.movie_id
JOIN Reviews rv ON m.movie_id = rv.movie_id
GROUP BY m.title;

🔥 Identify High Engagement Users
SELECT u.name, COUNT(*) AS total_movies, 
       SUM(CASE WHEN wh.completed THEN 1 ELSE 0 END) AS completed_movies
FROM Users u
JOIN Watch_History wh ON u.user_id = wh.user_id
GROUP BY u.name
HAVING SUM(CASE WHEN wh.completed THEN 1 ELSE 0 END) > 1;

👁️ Views
🎥 Recommended Movies
CREATE VIEW recommended_movies AS
SELECT m.title, ROUND(AVG(r.rating),2) AS avg_rating
FROM Movies m
JOIN Ratings r ON m.movie_id = r.movie_id
GROUP BY m.title
HAVING AVG(r.rating) >= 4.0;
This view filters out top-rated movies based on crowd wisdom.

