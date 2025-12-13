-- create the table
create table swiggy(
	State varchar(25),
	City varchar(25),
	Order_Date	date,
	Restaurant_Name varchar(60),
	Location varchar(50),
	Category varchar(60),
	Dish_Name varchar(200),
	Price_INR float,
	Rating float,
	Rating_Count int
	);
-- import the data 
select * from swiggy;

-- DATA CLEANING AND VALIDETION
-- null check
SELECT 
	SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
	SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
	SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
	SUM(CASE WHEN restaurant_name IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name,
	SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS null_lacation,
	SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
	SUM(CASE WHEN dish_name IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
	SUM(CASE WHEN price_inr IS NULL THEN 1 ELSE 0 END) AS null_price_inr,
	SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
	SUM(CASE WHEN rating_count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
from swiggy;

-- blank/empty string check

SELECT *
FROM swiggy
WHERE state = '' OR city = '' OR restaurant_name = '' OR location = '' OR category = '' OR dish_name = '';

-- duplicate detection

SELECT 
	state,city,order_date,restaurant_name,location,category,dish_name,price_inr,rating,rating_count,COUNT(*) AS cnt_dt
FROM swiggy
GROUP BY 
	state,city,order_date,restaurant_name,location,category,dish_name,price_inr,rating,rating_count
HAVING COUNT(*) > 1 ;

-- duplicate removal

WITH cte AS(
	SELECT ctid, ROW_NUMBER() OVER( 
		PARTITION BY state,city,order_date,restaurant_name,location,category,dish_name,price_inr,rating,rating_count
		ORDER BY (SELECT NULL)) AS rn
	FROM swiggy
) 
DELETE FROM swiggy
WHERE ctid IN (SELECT ctid FROM cte WHERE rn > 1);


-- Create dimension table and fact table
-- create dimension table

CREATE TABLE dim_date (
	date_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	full_date DATE,
	year INT,
	quarter INT,
	month INT,
	month_name VARCHAR(20),
	week INT,
	day_name VARCHAR(20)
);
ALTER TABLE dim_date ADD COLUMN day INT;
ALTER TABLE dim_date RENAME COLUMN date to day;

CREATE TABLE dim_location(
	location_id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	state VARCHAR(50),
	city VARCHAR(50),
	location VARCHAR(200)
);


CREATE TABLE dim_restaurant(
	restaurant_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	restaurant_name VARCHAR(250)
);

CREATE TABLE dim_category(
	category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	category VARCHAR(200)
);

CREATE TABLE dim_dish(
	dish_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	dish_name VARCHAR(200)
);

-- create fact table

CREATE TABLE fact_swiggy_order(
	order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	date_id INT,
	category_id INT,
	dish_id INT,
	restaurant_id INT,
	location_id INT,
	rating DECIMAL(4,2),
	rating_count INT,
	price_inr DECIMAL(10,2),
	FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
	FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
	FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
	FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
	FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);

-- insert the data into all tables

-- insert into dim_date

INSERT INTO dim_date(full_date, year, month, month_name, week, day_name,quarter)
SELECT DISTINCT
	order_date,
	EXTRACT(YEAR FROM order_date),
	EXTRACT(MONTH FROM order_date),
	TO_CHAR(order_date,'Month'),
	EXTRACT(WEEK FROM order_date),
	TO_CHAR(order_date,'Day'),
	EXTRACT(QUARTER FROM order_date)
FROM swiggy
WHERE order_date IS NOT NULL;

UPDATE dim_date SET day = EXTRACT(DAY FROM full_date);

SELECT * FROM dim_date;

-- insert into dim_location

INSERT INTO dim_location(state, city, location)
SELECT DISTINCT
	state,
	city,
	location
FROM swiggy;

SELECT * FROM dim_location;

-- insert into dim_restaurant
INSERT INTO dim_restaurant(restaurant_name)
SELECT DISTINCT
	restaurant_name
FROM swiggy;

SELECT * FROM dim_restaurant;

-- insert into dim_category

INSERT INTO dim_category(category)
SELECT DISTINCT 
	category
FROM swiggy;

SELECT * FROM dim_category;

-- insert into dim_dish

INSERT INTO dim_dish(dish_name)
SELECT DISTINCT
	dish_name
FROM swiggy;

SELECT * FROM dim_dish;

-- insert into fact table
SELECT * FROM fact_swiggy_order;

INSERT INTO fact_swiggy_order(date_id, category_id, dish_id, restaurant_id, location_id, rating, rating_count, price_inr)
SELECT
	d1.date_id,
	d4.category_id,
	d5.dish_id,
	d3.restaurant_id,
	d2.location_id,
	s.rating,
	s.rating_count,
	s.price_inr
FROM swiggy s
JOIN dim_date d1
	ON d1.full_date = s.order_date
JOIN dim_location d2
	ON d2.state = s.state
	AND d2.city = s.city
	AND d2.location = s.location
JOIN dim_restaurant d3
	ON d3.restaurant_name = s.restaurant_name
JOIN dim_category d4
	ON d4.category = s.category
JOIN dim_dish d5
	ON d5.dish_name = s.dish_name;

-- Questions 
-- kpi's

-- Q1 Total Orders

SELECT COUNT(*) AS total_orders
FROM fact_swiggy_order;

--Q2  Total Revenue (INR Million)

SELECT TO_CHAR(SUM(price_inr)/1000000,'FM999999990.0000') || 'M INR' AS "Total Revenue (INR Million)"
FROM fact_swiggy_order;

--Q3 Average Dish Price

SELECT TO_CHAR(ROUND(AVG(price_inr),2),'FM999999990.00') || ' INR' AS average_price_dish
FROM fact_swiggy_order fo
RIGHT JOIN dim_dish d
	ON d.dish_id = fo.dish_id;

--Q4 Average Rating

SELECT ROUND(AVG(rating),2) AS average_rating
FROM fact_swiggy_order;

--Q5 Monthly order trends

SELECT d.month_name,TO_CHAR(SUM(fo.price_inr)/1000000,'FM999999990.00') || 'M INR' AS revenue,COUNT(fo.order_id) AS total_order
FROM dim_date d
JOIN fact_swiggy_order fo
	ON d.date_id = fo.date_id
GROUP BY d.month_name,d.month
ORDER BY d.month;

--Q6 Quarterly order trends

SELECT d.quarter,TO_CHAR(SUM(fo.price_inr)/1000000,'FM999999990.00') || 'M INR' AS revenue,COUNT(fo.order_id) AS total_order
FROM dim_date d
JOIN fact_swiggy_order fo
	ON d.date_id = fo.date_id
GROUP BY d.quarter;

--Q7 Year-wise growth

SELECT d.year,TO_CHAR(SUM(fo.price_inr)/1000000,'FM999999990.00') || 'M INR' AS revenue,COUNT(fo.order_id) AS total_order
FROM dim_date d
JOIN fact_swiggy_order fo
	ON d.date_id = fo.date_id
GROUP BY d.year;

--Q7 Day-of-week patterns

SELECT d.day_name,TO_CHAR(SUM(fo.price_inr)/1000000,'FM999999990.00') || 'M INR' AS revenue,COUNT(fo.order_id) AS total_order
FROM dim_date d
JOIN fact_swiggy_order fo
	ON d.date_id = fo.date_id
GROUP BY d.day_name
ORDER BY 
	CASE TRIM(d.day_name)
		WHEN 'Monday' THEN 1
		WHEN 'Tuesday' THEN 2
		WHEN 'Wednesday' THEN 3
		WHEN 'Thursday' THEN 4
		WHEN 'Friday' THEN 5
		WHEN 'Saturday' THEN 6
		WHEN 'Sunday' THEN 7
	END;

--Q8 Top 10 cities by order volume

SELECT d.city,COUNT(*) AS total_order
FROM fact_swiggy_order fo
JOIN dim_location d 
	ON d.location_id = fo.location_id
GROUP BY d.city
ORDER BY total_order DESC
LIMIT 10;

--Q9 Revenue contribution by states

SELECT d.state,TO_CHAR(SUM(fo.price_inr)/1000000,'FM9999999990.00') || 'M INR' AS total_order
FROM fact_swiggy_order fo
JOIN dim_location d 
	ON d.location_id = fo.location_id
GROUP BY d.state
ORDER BY total_order DESC;

--Q10 Top 10 restaurants by orders AND revenue

SELECT d.restaurant_name,COUNT(*) AS total_order,SUM(fo.price_inr) AS total_revenue
FROM dim_restaurant d
JOIN fact_swiggy_order fo
	ON d.restaurant_id = fo.restaurant_id
GROUP BY d.restaurant_name
ORDER BY total_revenue DESC
LIMIT 10;

--Q11 Top categories (Indian, Chinese, etc.)

SELECT d.category,COUNT(*) AS total_order
FROM dim_category d
JOIN fact_swiggy_order fo
	ON d.category_id = fo.category_id
GROUP BY d.category
ORDER BY total_order DESC
LIMIT 50;

--Q12 Most ordered dishes

SELECT d.dish_name, COUNT(*) AS total_order
FROM dim_dish d
JOIN fact_swiggy_order fo
	ON d.dish_id = fo.dish_id
GROUP BY d.dish_name
ORDER BY total_order DESC
LIMIT 10;

--Q13 Cuisine performance → Orders + Avg Rating

SELECT d.dish_name, COUNT(*) AS total_order, 
	ROUND(AVG(fo.rating),2) AS average_rating
FROM dim_dish d
JOIN fact_swiggy_order fo
	ON d.dish_id = fo.dish_id
GROUP BY d.dish_name
ORDER BY total_order DESC;

--Q14
-- Customer Spending Insights
-- Buckets of customer spend:
-- •	Under 100
-- •	100 – 199
-- •	200 – 299
-- •	300 – 499
-- •	500+
-- With total order distribution across these ranges.
-- Distribution of dish ratings from 1 – 5.

WITH ranges AS(SELECT 
		CASE 
			WHEN price_inr < 100 THEN 'under 100'
			WHEN price_inr >= 100 AND price_inr < 200 THEN '100-199'
			WHEN price_inr >= 200 AND price_inr < 300 THEN '200-299'
			WHEN price_inr >= 300 AND price_inr < 500 THEN '300-499'
			WHEN price_inr >= 500 THEN '500+'
		END AS customer_range,
		COUNT(*) AS total_customer
FROM fact_swiggy_order
GROUP BY 
		CASE 
			WHEN price_inr < 100 THEN 'under 100'
			WHEN price_inr >= 100 AND price_inr < 200 THEN '100-199'
			WHEN price_inr >= 200 AND price_inr < 300 THEN '200-299'
			WHEN price_inr >= 300 AND price_inr < 500 THEN '300-499'
			WHEN price_inr >= 500 THEN '500+'
		END)
SELECT customer_range,total_customer
FROM ranges
ORDER BY 
	CASE customer_range
		WHEN 'under 100' THEN 1
		WHEN '100-199' THEN 2
		WHEN '200-299' THEN 3
		WHEN '300-499' THEN 4
		WHEN '500+' THEN 5
	END;

--Q15 Show all dishes and their categories.

SELECT DISTINCT d.dish_name,MAX(c.category) AS category
FROM dim_dish d
LEFT JOIN fact_swiggy_order f
	ON d.dish_id = f.dish_id
LEFT JOIN dim_category c
	ON c.category_id = f.category_id
GROUP BY d.dish_name;

--Q16 Find all orders placed on a specific date (your choice).

SELECT order_id
FROM fact_swiggy_order f
JOIN dim_date d
	ON d.date_id = f.date_id
WHERE d.full_date = '02-02-2025';

--Q17 Find which restaurant has the highest average order price.

SELECT d.restaurant_name,ROUND(AVG(fo.price_inr),2) AS avg_order_price
FROM dim_restaurant d
JOIN fact_swiggy_order fo
	ON d.restaurant_id = fo.restaurant_id
GROUP BY d.restaurant_name
ORDER BY avg_order_price DESC
LIMIT 10;

-- Q18 For each restaurant, rank dishes by revenue

WITH dish_revenue AS (
	SELECT r.restaurant_name,d.dish_name,SUM(f.price_inr) revenue
	FROM dim_restaurant r
	LEFT JOIN fact_swiggy_order f
		ON f.restaurant_id = r.restaurant_id
	LEFT JOIN dim_dish d
		ON f.dish_id = d.dish_id
	GROUP BY r.restaurant_name,d.dish_name
)
SELECT restaurant_name,dish_name,revenue,
	RANK() OVER(PARTITION BY restaurant_name ORDER BY revenue DESC) AS rank
FROM dish_revenue
ORDER BY restaurant_name,rank;

-- Q19 For each category, find the dish with the highest rating.

SELECT c.category,d.dish_name,f.rating,
	RANK() OVER(PARTITION BY c.category ORDER BY f.rating DESC) AS rank
FROM dim_dish d
LEFT JOIN fact_swiggy_order f
	ON d.dish_id = f.dish_id
LEFT JOIN dim_category c
	ON c.category_id = f.category_id;
