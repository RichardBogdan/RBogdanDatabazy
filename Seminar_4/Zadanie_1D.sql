-- Active: 1790255622640@@127.0.0.1@5432@superstore
SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM products;

#Úloha 1
WITH tab AS (
    SELECT cu.customer_id,
           cu.customer_name AS meno,
           o.order_id AS orderID,
           o.order_date AS datum
    FROM customers AS cu
    INNER JOIN orders AS o ON cu.customer_id = o.customer_id
),
tab2 AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY datum DESC, orderID DESC
           ) AS rn
    FROM tab
)
SELECT meno, orderID, datum, rn
FROM tab2
WHERE rn <= 2
ORDER BY meno, rn;