ALTER TABLE orders
ALTER COLUMN order_date TYPE DATE
USING order_date::DATE;

-- 8. What is the month-over-month total revenue (quantity × unit price × (1-discount)) trend for 2023?
SELECT 
DATE_TRUNC('month', o.order_date) AS month,
ROUND(SUM(oi.quantity*p.unit_price*(1-oi.discount_pct/100.0))) as revenue
from orders o
join order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE EXTRACT(YEAR FROM o.order_date)= 2023
GROUP BY month
ORDER BY month


-- 9. Which warehouse has shipped the highest total order value? Which has the lowest?


WITH warehouse_totals AS (
    SELECT
        o.warehouse_id,
        w.warehouse_name,
        COUNT(o.order_id) AS total_orders,
        ROUND(
            SUM(
                oi.quantity
                * p.unit_price::numeric
                * (1 - oi.discount_pct / 100.0)
            ),
            2
        ) AS total_order_value
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN warehouses w
        ON o.warehouse_id = w.warehouse_id
    GROUP BY o.warehouse_id, w.warehouse_name
)

SELECT *
FROM (
    SELECT *, 'Highest' AS label
    FROM warehouse_totals
    ORDER BY total_order_value DESC
    LIMIT 1
) highest

UNION ALL

SELECT *
FROM (
    SELECT *, 'Lowest' AS label
    FROM warehouse_totals
    ORDER BY total_order_value
    LIMIT 1
) lowest;

-- 10. Which product categories have the highest average discount given, and does that correlate with lower or higher total revenue?
SELECT * from order_items
SELECT * from products

SELECT p.category, round(AVG(oi.discount_pct::numeric), 2) AS avg_discount,
ROUND(SUM(oi.quantity * p.unit_price* (1- discount_pct/100.0))) as total_order_value
FROM order_items oi 
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_discount DESC;

-- 11. Find all customers who have never placed a single order (i.e., exist in `customers` but not in `orders`) — this tests LEFT JOIN / anti-join thinking.
SELECT c.customer_id, c.customer_name from customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id 
WHERE o.order_id IS NULL


-- 12. Which suppliers have products with the highest total revenue generated (join supplier → product → order_items)?
select * from suppliers
select * from order_items
select * from products

select ROUND(SUM(oi.quantity*p.unit_price*(1-oi.discount_pct/100.0))) as revenue, s.supplier_name
from products p 
join suppliers s ON s.supplier_id = p.supplier_id
JOIN order_items oi ON oi.product_id = p.product_id
group by s.supplier_name
ORDER by revenue DESC
LIMIT 5;

