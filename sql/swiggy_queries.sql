CREATE TABLE swiggy_clean (
    id BIGINT,
    name TEXT,
    city TEXT,
    rating NUMERIC,
    rating_count TEXT,
    rating_count_num NUMERIC,
    cost NUMERIC,
    cost_band TEXT,
    cuisine TEXT
);


CREATE TABLE swiggy_cuisine (
    id BIGINT,
    name TEXT,
    city TEXT,
    rating NUMERIC,
    rating_count TEXT,
    rating_count_num NUMERIC,
    cost NUMERIC,
    cost_band TEXT,
    cuisine TEXT
);

select count(*) from swiggy_clean;
select * from swiggy_clean limit 5;

select count(*) from swiggy_cuisine;
select * from swiggy_cuisine limit 5;


-- ==========================================================
-- Q1: Which cities have the most restaurants, and how do
--     their average ratings compare?
-- ==========================================================
SELECT city,
       COUNT(*) AS restaurants,
       ROUND(AVG(rating), 2) AS avg_rating
FROM swiggy_clean
GROUP BY city
ORDER BY restaurants DESC
LIMIT 15;


-- Finding: Bikaner has the most restaurants (1,666) with a solid average rating of 4.04.
-- Kukatpally, Hyderabad has the lowest average rating in the top 15 (3.58) despite decent volume,
-- while Indiranagar, Bangalore has a higher rating (4.14) with fewer restaurants



-- ==========================================================
-- Q2: Which cuisines are strongest / underserved in each city?
-- ==========================================================

-- Top 3 cuisines within EACH city (not overall) using a  window function,
-- since a simple GROUP BY can't rank "within a group" on its own.
WITH ranked AS (
    SELECT city,
           cuisine,
           COUNT(*) AS restaurant_count,
           RANK() OVER (
               PARTITION BY city
               ORDER BY COUNT(*) DESC
           ) AS rank
    FROM swiggy_cuisine
    GROUP BY city, cuisine
)
SELECT city, cuisine, restaurant_count
FROM ranked
WHERE rank <= 3
ORDER BY city, rank;


-- Finding: Cuisine preferences vary meaningfully across cities.North Indian, Chinese, 
-- and Indian cuisines appear among the top 3 in many cities,but local patterns still differ
-- for example,Adajan, Surat has Snacks and Chinese at the top, while Adityapur shows a
-- particularly high concentration of Chinese restaurants (139), followed by Indian (103) 
-- and North Indian (53).This shows that while a few cuisines are broadly popular, the most
-- common cuisine in any given city can vary considerably.






-- Possibly underserved cuisines: decent rating, but few
-- restaurants offering it (10-50), per city.
SELECT city,
       cuisine,
       COUNT(*) AS restaurant_count,
       COUNT(rating) as rated_count,
       ROUND(AVG(rating),2) AS avg_rating
FROM swiggy_cuisine
GROUP BY city, cuisine
HAVING COUNT(rating) BETWEEN 10 AND 50
   AND AVG(rating) >= 4.2
ORDER BY cuisine,avg_rating DESC;

-- Finding: After filtering to city-cuisine groups with at least 10 rated
-- restaurants and an average rating of 4.2+, Desserts (76 occurrences) and
-- Ice Cream (75) are by far the most consistent "underserved" pattern,
-- appearing roughly 2.4x more often than the next tier (Beverages and
-- Bakery, 31 each). This holds across many different cities, so it's a
-- market-wide pattern, not a one-off. These are strong candidates for
-- expansion, not proof of demand, since this dataset has no order volume
-- to confirm it.




-- ==========================================================
-- Q3: Does higher cost mean a higher rating?/ Does cost affect rating?
-- ==========================================================
SELECT cost_band,
       COUNT(*) AS restaurants,
       ROUND(AVG(rating), 2) AS avg_rating
FROM swiggy_clean
WHERE rating IS NOT NULL
  AND cost_band <> ''
GROUP BY cost_band
ORDER BY avg_rating;

-- Finding: Premium-priced restaurants have a slightly higher average
-- rating (4.02) than Budget (3.88) and Mid-range (3.86), but the gap is
-- small (about 0.14-0.16 points on a 5-point scale), suggesting cost has
-- only a weak relationship with rating, not a strong one. Most rated
-- restaurants (about 65%, 38,944 of 61,425) fall in the Mid price band,
-- yet don't rate any better than Budget. This will be checked further
-- with a statistical test.

-- Note (Python): Spearman correlation between cost and rating
-- = 0.11 (p < 0.001, highly significant due to large sample size).
-- The relationship is real but very weak -- cost explains almost none
-- of the variation in rating. Confirms the SQL finding above: cost has
-- only a minor effect on rating.



-- ==========================================================
-- Q4: Do better-rated restaurants get more ratings (rating_count)?
-- ==========================================================
-- Correlation coefficient between rating and rating_count_num.
-- Ranges from -1 to 1; near 0 = no real relationship.


SELECT ROUND(CORR(rating, rating_count_num)::numeric, 3) AS correlation
FROM swiggy_clean
WHERE rating IS NOT NULL AND rating_count_num IS NOT NULL;

-- Finding: The correlation between rating and rating_count_num is 0.101
-- (on a scale of -1 to 1). This is very weak and close to 0, meaning
-- there is almost no relationship between how highly a restaurant is
-- rated and how many ratings it has received. A restaurant with a high
-- rating is not meaningfully more likely to have a high rating count,
-- and vice versa. Note: rating_count_num is a minimum count (e.g. "50+"
-- becomes 50), not exact, which may weaken the measured correlation
-- further. This will be checked with a proper significance test
-- (Spearman correlation).

-- ==========================================================
-- Q5: Popular restaurants with a low rating (quality risk)
-- ==========================================================
SELECT name AS restaurant,
       city,
       rating,
       rating_count_num
FROM swiggy_clean
WHERE rating < 3.5
  AND rating_count_num >=500
ORDER BY rating_count_num desc limit 50;


-- Finding: Top 50 restaurants (by rating_count_num) with 500+ ratings
-- and average rating below 3.5 -- these are "quality risks": high
-- order volume but poor ratings, a bad combination for Swiggy's
-- reputation. About a third (18-19) are in Hyderabad, more than any
-- other city, though this may partly reflect Hyderabad having more
-- restaurants overall. Most ratings are 3.0-3.4 (underperforming, not
-- failing). rating_count_num is a bucketed minimum, not exact. Swiggy
-- could review these first given high volume + low rating.

