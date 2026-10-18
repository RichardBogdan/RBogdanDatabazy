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

#Úloha 3
WITH tab AS(
    SELECT 
        cu.customer_name,
        SUM(o.sales) AS total_sales
    FROM customers AS cu
    INNER JOIN orders AS o ON cu.customer_id = o.customer_id
    GROUP BY cu.customer_name
),
tab2 AS (
    SELECT
        *,
        NTILE(4) OVER(
            ORDER BY total_sales DESC
        ) AS quartile
    FROM tab
)
SELECT * FROM tab2;

#Úloha 4
WITH tab AS(
    SELECT 
        DATE_TRUNC('month',order_date) AS month,
        SUM(sales) AS monthly_sales 
    FROM orders 
    GROUP BY DATE_TRUNC('month',order_date)
),
tab2 AS(
    SELECT 
        *,
        LAG(monthly_sales,1) OVER(
            ORDER BY month 
        ) AS prev_month_sales,
        LEAD(monthly_sales,1) OVER(
            ORDER BY month 
        ) AS next_month_sales
    FROM tab
)
SELECT * FROM tab2;

#Úloha 5
SELECT              /*opravenie*/
    p.category,
    p.product_name,
    SUM(o.sales) AS product_sales,
    SUM(SUM(o.sales)) OVER (PARTITION BY p.category) AS category_total,
    ROUND(
        SUM(o.sales) * 100.0 /
        SUM(SUM(o.sales)) OVER (PARTITION BY p.category),
        2
    ) AS pct_of_category
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category, p.product_name;

WITH tab AS (           /*prehladnejsia podoba*/
    SELECT 
        p.category, 
        p.product_name, 
        SUM(o.sales) AS product_sales
    FROM orders AS o
    JOIN products AS p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT 
    *,
    SUM(product_sales) OVER (PARTITION BY category) AS category_total,
    ROUND(
        product_sales * 100.0 /
        SUM(product_sales) OVER (PARTITION BY category),
        2
    ) AS pct_of_category
 FROM tab;

#Úloha 6
WITH tab AS (
    SELECT 
        cu.customer_id,
        cu.customer_name,
        o.order_date
    FROM customers AS cu
    INNER JOIN orders AS o ON cu.customer_id = o.customer_id
),
tab2 AS (
    SELECT 
        customer_id,
        customer_name,
        MAX(order_date) OVER (PARTITION BY customer_id) AS last_order_date,
        MAX(order_date) OVER () AS latest_order_date
    FROM tab
)
SELECT 
    DISTINCT customer_id, 
    customer_name, 
    last_order_date
FROM tab2
WHERE last_order_date < latest_order_date - INTERVAL '90 days'
ORDER BY last_order_date ASC;
