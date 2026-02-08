DROP table if exists pizza_sale
create table pizza_sale(pizza_id int,
order_id int,
pizza_name_id varchar,
quantity int,
order_date date,
order_time time,
unit_price float,
total_price float,
pizza_size varchar,
pizza_category varchar,
pizza_ingredients varchar,
pizza_name varchar
)

select * from pizza_sale

--Total Revenue
SELECT 
  CONCAT(ROUND(sum(total_price)/1000.0),'K') as Total_Revenue
from pizza_sale

--Average Order Value
SELECT
  ROUND((SUM(total_price)/COUNT(DISTINCT order_id))::numeric,2) AS AOV 
FROM pizza_sale

--Total Pizzas Sold
SELECT 
  SUM(quantity) AS Total_Pizzas_Sold 
FROM pizza_sale

--Total Order Placed
SELECT 
  COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sale

--Average Pizzas Per Order
SELECT 
  CAST(CAST(SUM(quantity) AS decimal(10,2))/
       CAST(COUNT(DISTINCT order_id) AS decimal(10,2)) AS decimal(10,2))
  AS Average_Pizza_Per_Order 
FROM pizza_sale

--Daily trend for total orders
SELECT 
 TO_CHAR(order_date,'Day') AS order_day,
 COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sale
GROUP BY order_day
ORDER BY MIN(EXTRACT(dow FROM order_date))

--Monthly trend for orders
SELECT
 TO_CHAR(order_date,'Month') AS order_day,
 COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sale
GROUP BY order_day
ORDER BY MIN(EXTRACT(dow FROM order_date))

SELECT
 DATE_TRUNC('Month',order_date) as order_day,
 COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sale
GROUP BY order_day
ORDER BY MIN(EXTRACT(dow FROM order_date))
--Percentage Of Sales By Pizza Category
SELECT 
 pizza_category, 
 SUM(total_price) * 100 / (SELECT SUM(total_price) FROM pizza_sale) AS PCT
FROM pizza_sale
GROUP BY pizza_category

SELECT 
 pizza_category, 
 (SUM(total_price) * 100 / SUM(SUM(total_price)) OVER ()) AS PCT
FROM pizza_sale
GROUP BY pizza_category
--Percentage Of Sales By Pizza Size
SELECT 
  pizza_size,
  CAST(SUM(total_price)AS decimal(10,2)) AS total_sales,
  CAST(SUM(total_price) * 100 / (SELECT SUM(total_price)FROM pizza_sale)AS decimal(10,2)) AS PCT
FROM pizza_sale
GROUP BY pizza_size
ORDER BY PCT DESC

--Total pizza sold by pizza category
SELECT 
  pizza_category,
  SUM(quantity) AS total_quantity 
FROM pizza_sale
WHERE EXTRACT (MONTH FROM order_date) = 2
GROUP BY pizza_category

-----Optimized query
SELECT 
  pizza_category,
  SUM(quantity) AS total_quantity 
FROM pizza_sale
WHERE EXTRACT (MONTH FROM order_date) >= 2
      AND EXTRACT (MONTH FROM order_date) < 3
GROUP BY pizza_category


--Top 5 pizzas by revenue
SELECT
  pizza_name,
  SUM(total_price) AS total_revenue
FROM pizza_sale
GROUP BY pizza_name
ORDER BY total_revenue DESC LIMIT 5

--Bottom 5 pizzas by Revenue
SELECT
  pizza_name,
  ROUND(SUM(total_price)::numeric,2) AS total_revenue
FROM pizza_sale
GROUP BY pizza_name
ORDER BY total_revenue ASC LIMIT 5

 --Top 5 pizzas by quantity
SELECT
  pizza_name,
  SUM(quantity) AS total_quantity
FROM pizza_sale
GROUP BY pizza_name
ORDER BY total_quantity DESC LIMIT 5

--Bottom 5 pizzas by quantity
SELECT
  pizza_name,
  SUM(quantity) AS total_quantity
FROM pizza_sale
GROUP BY pizza_name
ORDER BY total_quantity ASC LIMIT 5

--Top 5 pizzas by total order
SELECT
  pizza_name,
  COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sale
GROUP BY pizza_name
ORDER BY total_orders DESC LIMIT 5

--Bottom 5 pizzas by total order
SELECT
  pizza_name,
  COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sale
GROUP BY pizza_name
ORDER BY total_orders ASC LIMIT 5
