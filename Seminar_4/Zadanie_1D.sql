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
SELECT meno, orderID, datum
FROM tab2
WHERE rn <= 2
ORDER BY meno, rn;

#Úloha 2
WITH tab1 AS (
    SELECT cu.region,
           cu.customer_name,
           SUM(o.profit) AS total_profit
    FROM customers AS cu
    INNER JOIN orders AS o ON cu.customer_id = o.customer_id
    GROUP BY cu.region, cu.customer_name
)
SELECT region,
       customer_name,
       total_profit,
       RANK() OVER (
           PARTITION BY region
           ORDER BY total_profit DESC
       ) AS profit_rank,
       DENSE_RANK() OVER (
           PARTITION BY region
           ORDER BY total_profit DESC
       ) AS profit_dense_rank
FROM tab1
ORDER BY region, profit_rank, customer_name;