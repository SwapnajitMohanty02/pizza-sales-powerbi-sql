
SELECT * FROM pizza_sale;

CREATE TABLE dim_pizza(
    pizza_key serial primary key,
	pizza_id varchar,
	pizza_name varchar(100),
	pizza_category varchar(50),
	pizza_size varchar(10),
	pizza_ingredients text,
	unit_price numeric(10,2)
);
INSERT INTO dim_pizza(
    pizza_id,
	pizza_name,
	pizza_category,
	pizza_size,
	pizza_ingredients,
	unit_price
);
SELECT DISTINCT
    pizza_id,
	pizza_name,
	pizza_category,
	pizza_size,
	pizza_ingredients,
	unit_price
FROM pizza_sale;

SELECT * FROM dim_pizza;

CREATE TABLE dim_date(
    date_key DATE PRIMARY KEY,
	day INT,
	month INT,
	month_name VARCHAR,
	quarter INT,
	year INT,
	weekday VARCHAR(10)
);

INSERT INTO dim_date
SELECT DISTINCT
    order_date as date_key,
	EXTRACT(DAY FROM order_date),
	EXTRACT(MONTH FROM order_date),
	TO_CHAR(order_date,'Month'),
	EXTRACT(QUARTER FROM order_date),
	EXTRACT(YEAR FROM order_date),
	TO_CHAR(order_date,'Day')
FROM pizza_sale;

SELECT  * FROM dim_date;

CREATE TABLE dim_time(
    time_key TIME PRIMARY KEY,
	hour INT,
	minute INT,
	time_slot VARCHAR(20)
);
INSERT INTO dim_time
SELECT DISTINCT
    order_time AS time_key,
	EXTRACT(HOUR FROM order_time),
	EXTRACT(MINUTE FROM order_time),
	CASE
          WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 11 THEN 'Morning'
		  WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 16 THEN 'Afternoon'
          WHEN EXTRACT(HOUR FROM order_time) BETWEEN 17 AND 21 THEN 'Evening'
	      ELSE 'Night'
	END
FROM pizza_sale;

SELECT * FROM dim_time;

CREATE TABLE fact_sales(
     sales_key SERIAL PRIMARY KEY,
	 order_id INT,
	 pizza_key INT,
	 date_key date,
	 time_key time,
	 quantity INT,
	 total_price NUMERIC(10,2),

   CONSTRAINT fk_pizza
       FOREIGN KEY (pizza_key) REFERENCES dim_pizza(pizza_key),

   CONSTRAINT fk_date
       FOREIGN KEY (date_key) REFERENCES dim_date(date_key),

    CONSTRAINT fk_time
	   FOREIGN KEY (time_key) REFERENCES dim_time(time_key)
);
INSERT INTO fact_sales(    
	 order_id,
	 pizza_key,
	 date_key,
	 time_key,
	 quantity,
	 total_price 
)
SELECT DISTINCT
     ps.order_id,
	 dp.pizza_key,
	 ps.order_date,
	 ps.order_time,
	 ps.quantity,
	 ps.total_price
FROM pizza_sale ps
JOIN dim_pizza dp
ON ps.pizza_size = dp.pizza_size
AND ps.pizza_id = dp.pizza_id::INT


SELECT * FROM fact_sales;

--Total Revenue
SELECT 
 SUM(total_price) AS Total_Revenue
FROM fact_sales

--Average Order Value
SELECT
 ROUND(SUM(total_price)/COUNT(DISTINCT order_id)::numeric,2) AS AOV
FROM fact_sales

--Total pizzas sold
SELECT
 SUM(quantity) AS total_pizza
FROM fact_sales

--Total orders placed
SELECT 
 COUNT(DISTINCT order_id) AS total_orders
FROM fact_sales

--Average pizzas per order
SELECT
  CAST(CAST(SUM(quantity) AS decimal (10,2))/
       COUNT(DISTINCT order_id) AS DECIMAL (10,2)) AS average_pizzas_per_order
FROM fact_sales

--Daily Trend Of Total Orders
SELECT 
 dd.weekday,
 COUNT(DISTINCT fs.order_id) as daily_trend
FROM dim_date dd
JOIN fact_sales fs
ON dd.date_key=fs.date_key
GROUP BY weekday

--Monthly Sales By Orders
SELECT
  dd.month_name,
  COUNT(DISTINCT fs.order_id) as monthly_trend
FROM dim_date dd
JOIN fact_sales fs
ON dd.date_key=fs.date_key
GROUP BY month_name

--Percentage of sales by pizza_category
SELECT 
 dp.pizza_category,
 ROUND(SUM(fs.total_price)*100/SUM(SUM(total_price)) OVER (),2) AS PTS
FROM dim_pizza dp
JOIN fact_sales fs
ON dp.pizza_key = fs.pizza_key
GROUP BY dp.pizza_category

--Percentage sale by pizza size
SELECT
   dp.pizza_size,
   ROUND(SUM(fs.total_price)*100/SUM(SUM(fs.total_price)) OVER (),2) 
FROM dim_pizza dp
JOIN fact_sales fs
ON dp.pizza_key = fs.pizza_key
GROUP BY dp.pizza_size

--Total pizzas sold by pizza category(Month is FEBRUARY)
SELECT 
  dp.pizza_category,
  SUM(fs.quantity) AS total_quantity
FROM dim_pizza dp
JOIN fact_sales fs
on dp.pizza_key = fs.pizza_key
JOIN dim_date dd ON dd.date_key = fs.date_key
WHERE dd.month >= 2 and dd.month < 3
GROUP BY dp.pizza_category

--TOP 5 pizzas by Revenue
SELECT 
  dp.pizza_name,
  SUM(fs.total_price) AS total_revenue
FROM dim_pizza dp
JOIN fact_sales fs 
ON dp.pizza_key = fs.pizza_key
GROUP BY dp.pizza_name
ORDER BY SUM(fs.total_price) DESC

--Bottom 5 pizzas by Revenue
SELECT 
  dp.pizza_name,
  SUM(fs.total_price) AS total_revenue
FROM dim_pizza dp
JOIN fact_sales fs 
ON dp.pizza_key = fs.pizza_key
GROUP BY dp.pizza_name
ORDER BY SUM(fs.total_price) ASC

--Top 5 pizzas by Quantity
SELECT 
  dp.pizza_name,
  SUM(fs.quantity) AS total_quantity
FROM dim_pizza dp
JOIN fact_sales fs 
ON dp.pizza_key = fs.pizza_key
GROUP BY dp.pizza_name
ORDER BY SUM(fs.quantity) DESC
  
--Bottom 5 pizzas by Quantity
SELECT 
  dp.pizza_name,
  SUM(fs.quantity) AS total_quantity
FROM dim_pizza dp
JOIN fact_sales fs 
ON dp.pizza_key = fs.pizza_key
GROUP BY dp.pizza_name
ORDER BY SUM(fs.quantity) ASC

--Top 5 pizzas by total order
SELECT 
  dp.pizza_name,
  COUNT(DISTINCT fs.order_id) AS total_quantity
FROM dim_pizza dp
JOIN fact_sales fs 
ON dp.pizza_key = fs.pizza_key
GROUP BY dp.pizza_name
ORDER BY COUNT(DISTINCT fs.order_id) DESC

--Bottom 5 pizza by total order
SELECT 
  dp.pizza_name,
  COUNT(DISTINCT fs.order_id) AS total_quantity
FROM dim_pizza dp
JOIN fact_sales fs 
ON dp.pizza_key = fs.pizza_key
GROUP BY dp.pizza_name
ORDER BY COUNT(DISTINCT fs.order_id) ASC