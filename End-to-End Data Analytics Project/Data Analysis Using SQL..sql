-- Data Analysis

-- Find the number of businesses in each category
WITH cte AS (
SELECT business_id, TRIM(A.value) AS category
FROM tbl_yelp_businesses
, LATERAL SPLIT_TO_TABLE(categories,',') A
)
SELECT category,COUNT(*) AS no_of_business
FROM cte
GROUP BY 1
ORDER BY 2 DESC;

--2. Find the top 10 users who have reviewed the most businesses in the 'Restaurants' category.

SELECT r.user_id, COUNT(DISTINCT r.business_id)
FROM tbl_yelp_reviews r
INNER JOIN tbl_yelp_businesses b 
ON r.business_id=b.business_id
WHERE b.categories ILIKE '%restaurant%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--3. Find the most popular categories of businesses (based on the number of reviews).
WITH cte AS (
SELECT business_id, TRIM(A.value) AS category
FROM tbl_yelp_businesses
, LATERAL SPLIT_TO_TABLE(categories,',') A
)
SELECT category, COUNT(*) AS no_of_reviews 
FROM cte
INNER JOIN tbl_yelp_reviews r 
ON cte.business_id=r.business_id
GROUP BY 1
ORDER BY 2 DESC;

-- 4. Find the top 3 most recent reviews for each business.
WITH cte AS (
SELECT r.*,b.name
, ROW_NUMBER() OVER(PARTITION BY r.business_id ORDER BY r.review_date DESC) AS rn
FROM tbl_yelp_reviews r
INNER JOIN tbl_yelp_businesses b 
ON r.business_id=b.business_id
)
SELECT * FROM cte
WHERE rn<=3;

-- 5. Find the month with the highest number of reviews.

SELECT MONTH(review_date) AS review_month, COUNT(*) AS no_of_reviews
FROM tbl_yelp_reviews
GROUP BY 1
ORDER BY 2 DESC;

-- 6. Find the percentage of 5-star reviews for each business.
SELECT b.business_id,b.name,COUNT(*) AS total_reviews,
SUM(CASE WHEN r.review_stars=5 THEN 1 ELSE 0 END) AS star5_reviews,
ROUND(star5_reviews*100/total_reviews,2) AS percent_5_star
FROM tbl_yelp_reviews r
INNER JOIN tbl_yelp_businesses b 
ON r.business_id=b.business_id
GROUP BY 1,2

-- 7. Find the top 5 most reviewed businesses in each city.

WITH cte AS (
SELECT b.city,b.business_id,b.name,COUNT(*) AS total_reviews,
FROM tbl_yelp_reviews r
INNER JOIN tbl_yelp_businesses b 
ON r.business_id=b.business_id
GROUP BY 1,2,3
ORDER BY 1
)

SELECT *
FROM cte
QUALIFY ROW_NUMBER() OVER(PARTITION BY city ORDER BY total_reviews DESC) <=5;

-- 8. Find the average rating of businesses that have at least 100 reviews.
WITH cte AS (
SELECT r.user_id,COUNT(*) AS total_reviews
FROM tbl_yelp_reviews r
INNER JOIN tbl_yelp_businesses b 
ON r.business_id=b.business_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
)
SELECT user_id,business_id,
FROM tbl_yelp_reviews
WHERE user_id IN (SELECT user_id FROM cte)
GROUP BY 1,2
ORDER BY user_id;

-- 10. Find top 10 businesses with highest positive sentiment reviews.
SELECT r.business_id,b.name, COUNT(*) AS total_reviews
FROM tbl_yelp_reviews r
INNER JOIN tbl_yelp_businesses b 
ON r.business_id=b.business_id
WHERE sentiments='Positive'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;







 


