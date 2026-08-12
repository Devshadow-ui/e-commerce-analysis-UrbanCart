-- 13. For each customer, find their most recent order date and how many days ago that was, relative to the most recent order date in the whole dataset (recency analysis — a mini RFM step).
SELECT
	CUSTOMER_ID,
	MAX(ORDER_DATE) AS LATEST_ORDER,
	MAX(ORDER_DATE) - (
		SELECT
			MAX(ORDER_DATE)
		FROM
			ORDERS
	) AS DAYS_AGO
FROM
	ORDERS
GROUP BY
	CUSTOMER_ID
ORDER BY
	DAYS_AGO DESC

-- 14. Rank products within each category by total revenue using `RANK()` or `DENSE_RANK()`, and return only the top 3 per category.
SELECT * from products
SELECT * from order_items

WITH product_revenue AS (
  SELECT p.category, p.product_id, p.product_name,
         ROUND(SUM(
           COALESCE(oi.quantity, 0) * COALESCE(p.unit_price::numeric, 0) * (1 - COALESCE(oi.discount_pct, 0)/100.0)
         )) AS revenue
  FROM products p
  JOIN order_items oi ON oi.product_id = p.product_id
  GROUP BY p.category, p.product_id, p.product_name
),
ranked_products AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS revenue_rank
  FROM product_revenue
)
SELECT category, product_id, product_name, ROUND(revenue::numeric, 2) AS revenue, revenue_rank
FROM ranked_products
WHERE revenue_rank <= 3
ORDER BY category, revenue_rank;


-- 15. Using a CTE, calculate each customer's total lifetime spend,
-- then bucket customers into `High` / `Medium` / `Low` spend tiers using `NTILE(3)` or `CASE`.

WITH customer_spend AS (
select o.customer_id, 
sum(COALESCE(oi.quantity, 0) * COALESCE(p.unit_price, 0) * (1- COALESCE(oi.discount_pct, 0)/100.0)) AS lifetime_spend
FROM orders o 
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p  ON p.product_id = oi.product_id
GROUP BY o.customer_id
)

SELECT customer_id, lifetime_spend,
NTILE(3) OVER (order by lifetime_spend DESC) AS spend_tier_numeric,


CASE NTILE(3) OVER (order by lifetime_spend DESC)
WHEN 1 THEN 'HIGH'
WHEN 2 THEN 'MEDIUM'
ELSE 'LOW'

END AS spend_tier
FROM customer_spend
ORDER BY lifetime_spend DESC;


-- 16. Calculate a running (cumulative) monthly revenue total for 2023 using a window function (`SUM() OVER (ORDER BY month)`).

with monthly as (
select DATE_TRUNC('month', o.order_date) AS month,
sum(COALESCE(oi.quantity, 0) * COALESCE(p.unit_price, 0) * (1- COALESCE(oi.discount_pct, 0)/100.0)) AS revenue
FROM orders o 
join order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2023
group by month
)

SELECT month, revenue, 
sum(revenue) OVER(ORDER BY MONTH) AS cumulative_revenue
from monthly
order by month;


-- 17. Find the month-over-month % growth in orders using `LAG()`.

WITH monthly_orders AS (
 select DATE_TRUNC('month', order_date) AS month, count(*) AS n_orders
 FROM orders
 group by month
)

SELECT month, n_orders,
LAG(n_orders) OVER (ORDER BY month) AS prev_month_orders,
ROUND(100.0 * (n_orders - LAG(n_orders) OVER (ORDER BY month)) / NULLIF(LAG(n_orders) OVER (ORDER BY month), 0)
, 2)  AS pct_growth
from monthly_orders
order BY month


-- 18. Identify products that are "at risk" — defined as: appear 
-- in `order_items` but have had zero orders in the last 6 months of the dataset's date range (use a subquery/anti-join with a date filter).

with max_date AS (select MAX(order_date) AS 
d from orders),

recent_products AS (
select DISTINCT oi.product_id
from order_items oi
JOIN orders o ON o.order_id = oi.order_id
where o.order_date >= (select d from max_date) - INTERVAL '6 months'
)
select p.product_id, p.product_name, p.category
from products p 
where p.product_id NOT IN (select product_id from recent_products);


-- 19. For each order, calculate what % of that order's total value came from the 
-- single most expensive line item (window function `PARTITION BY order_id`).

WITH line_values AS (
select oi.order_id ,     oi.order_item_id, 
COALESCE(oi.quantity, 0)* COALESCE(p.unit_price, 0) * (1- COALESCE(oi.discount_pct, 0)/100.0) AS line_value
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
),

order_stats AS (
 SELECT * , 
 SUM(line_value) OVER (PARTITION BY order_id) AS order_total,
 MAX(line_value) OVER (PARTITION BY order_id) AS max_line_value
 FROM line_values
)

SELECT DISTINCT order_id, order_total, max_line_value,
ROUND(100.0 * max_line_value/ NULLIF(order_total,0)) AS pct_from_top_item
FROM order_stats
ORDER BY pct_from_top_item DESC NULLS LAST;


-- 20. Build a supplier scorecard: for each supplier, compute total revenue generated,
-- average reliability_score, and average lead_time_days, then rank suppliers by a simple composite score you define (explain your weighting logic in a markdown note — there's no single right answer, but you must justify it).


WITH supplier_perf  AS (
SELECT s.supplier_id, s.supplier_name, s.reliability_score, s.lead_time_days,
sum(COALESCE(oi.quantity, 0) * COALESCE(p.unit_price, 0) * (1- COALESCE(oi.discount_pct, 0)/100.0)) AS total_revenue
from suppliers s
JOIN products p ON p.supplier_id = s.supplier_id
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY s.supplier_id, s.supplier_name, s.reliability_score, s.lead_time_days
)

SELECT *, ROUND((
0.5* PERCENT_RANK() OVER (ORDER BY total_revenue) + 
0.3 * (coalesce(reliability_score, 0) / 100.0) + 
0.2 * (1- PERCENT_RANK() OVER (ORDER BY lead_time_days)))::numeric, 3) AS composite_score
FROM supplier_perf
ORDER BY composite_score DESC;





