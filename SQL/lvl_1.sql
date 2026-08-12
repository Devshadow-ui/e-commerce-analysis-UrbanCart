-- 1. How many total orders, total customers, and total distinct products does UrbanCart have?
SELECT
(SELECT count(*) from customers) as total_customers,
(SELECT count(*) from products) as total_products,
(SELECT count(*)FROM orders) as total_orders;


-- 2. What are the top 10 product categories by total quantity sold?
SELECT p.category, SUM(oi.quantity) AS total_quantity
from order_items oi
JOIN products p ON
p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_quantity DESC

-- 3. Which 5 cities have generated the highest number of orders?

SELECT c.city, count(o.order_id) AS total_orders
from orders o
JOIN customers c ON
c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY total_orders DESC
LIMIT 5;


-- 4. What percentage of orders fall into each `order_status` (Delivered/Cancelled/Returned/etc.)?

SELECT order_status,
	count(*) AS n,
	round(100.0*count(*) / sum(count(*)) OVER(), 2) AS pct
FROM orders
GROUP BY order_status
order by pct DESC

-- 5. List the 10 customers who have placed the most orders, along with their city and segment.

SELECT c.customer_id, c.customer_name, c.city, c.customer_segment, count(o.order_id) AS num_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.city, c.customer_segment
ORDER BY num_orders DESC
LIMIT 10;

-- 6. What is the average unit price per product category?

select category, round(AVG(unit_price)) as avg_unit_price from products
GROUP BY category
ORDER BY avg_unit_price DESC

-- 7. Which payment mode is most commonly used, and does that vary by customer segment?
WITH mode_counts AS (
select c.customer_segment, o.payment_mode, count(*) AS n,
RANK() OVER (PARTITION BY c.customer_segment ORDER BY COUNT(*) DESC) AS rnk
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_segment, o.payment_mode
)
SELECT customer_segment, payment_mode, n
FROM mode_counts
WHERE rnk=1
ORDER BY customer_segment

