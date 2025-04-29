-- Which store is the most overstocked?
WITH cte AS 
(
  SELECT t1.store_id, t1.product_id, SUM(t1.quantity) AS quantity, AVG(t2.stock_level) AS stock,
  (AVG(t2.stock_level) / SUM(t1.quantity)) AS percentage
  FROM sales AS t1 
  LEFT JOIN inventory AS t2
  ON t1.store_id = t2.store_id AND t1.product_id = t2.product_id
  GROUP BY t1.store_id, t1.product_id
)
SELECT store_id 
FROM cte 
GROUP BY store_id 
ORDER BY AVG(percentage) DESC 
LIMIT 1;

-- Are any slow-moving products taking up inventory space?
WITH cte AS 
(
  SELECT product_id, SUM(stock_level) AS stock
  FROM inventory 
  GROUP BY product_id 
)
SELECT t1.product_id
FROM cte AS t1
LEFT JOIN sales AS t2
ON t1.product_id = t2.product_id
GROUP BY t1.product_id
ORDER BY AVG(t1.stock) / SUM(t2.quantity) DESC
LIMIT 5;

-- What are the top selling products by region?
WITH cte AS 
(
  SELECT SUM(quantity) AS total_sold, region, t1.product_id
  FROM sales AS t1
  LEFT JOIN stores AS t2
  ON t1.store_id = t2.store_id
  GROUP BY region, product_id
  ORDER BY region
),
ranked_products AS 
(
  SELECT product_id, region, total_sold,
  RANK() OVER (PARTITION BY region ORDER BY total_sold DESC) AS rank_no
  FROM cte
)
SELECT * 
FROM ranked_products 
WHERE rank_no <= 3;

-- How does sales vary by month?
SELECT EXTRACT(MONTH FROM `date`) AS month_sales,
SUM(price) AS total_revenue
FROM sales
GROUP BY month_sales
ORDER BY month_sales;

-- How does sales vary by day?
SELECT WEEKDAY(`date`) AS weekday, 
ROUND(SUM(price), 2) AS total_revenue,
ROUND(AVG(price), 2) AS average_per_day
FROM sales
GROUP BY weekday
ORDER BY weekday;

-- Who are the frequent buyer based on age group?
WITH small_age AS
(
  SELECT * 
  FROM customers
  WHERE age <= 20
),
mid_age AS 
(
  SELECT * 
  FROM customers
  WHERE age >= 20 AND age <= 50
),
old_age AS
(
  SELECT * 
  FROM customers 
  WHERE age >= 50
)
SELECT 
  (SELECT COUNT(*) FROM small_age) AS small_age_count,
  (SELECT COUNT(*) FROM mid_age) AS mid_age_count,
  (SELECT COUNT(*) FROM old_age) AS old_age_count;

-- Profitability
SELECT * 
FROM sales AS t1
LEFT JOIN sales AS t2
ON t1.product_id = t2.product_id;

WITH cte AS
(
  SELECT t1.product_id, 
  ROUND(AVG(t1.cost_price), 2) AS cost_price, 
  ROUND(AVG(((t2.price / (100 - t2.discount) * 100) / t2.quantity)), 2) AS price_per_unit,
  ROUND(AVG(((t2.price / (100 - t2.discount) * 100) / t2.quantity)) / AVG(t1.cost_price) * 100, 2) AS percentage_profit
  FROM products
