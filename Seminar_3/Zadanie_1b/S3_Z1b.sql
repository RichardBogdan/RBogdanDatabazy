-- Active: 1790255622640@@127.0.0.1@5432@datacraftinglab_db@public
SELECT * FROM flourmills_sales;
#Úloha 1
WITH daily_sales AS (
    SELECT sale_date, SUM(total_amount) AS celkova_hodnota_predaja FROM flourmills_sales
    GROUP BY sale_date
)
SELECT * FROM daily_sales
WHERE celkova_hodnota_predaja > 3000000
ORDER BY celkova_hodnota_predaja DESC;

#Úloha2
WITH category_sales AS (
    SELECT product_category, SUM(total_amount) AS celkova_hodnota_predaja FROM flourmills_sales
    GROUP BY product_category
)
SELECT * FROM category_sales
ORDER BY celkova_hodnota_predaja DESC;

#Úloha 3

WITH product_sales AS (
    SELECT product_category,
           product_name,
           SUM(total_amount) AS total_product_sales
    FROM flourmills_sales
    GROUP BY product_category, product_name
),
ranked_products AS (
    SELECT product_category,
           product_name,
           total_product_sales,
           RANK() OVER (
               PARTITION BY product_category
               ORDER BY total_product_sales DESC
           ) AS category_rank
    FROM product_sales
)
SELECT product_category,
       product_name,
       total_product_sales,
       category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY product_category, category_rank
LIMIT 10;

#Úloha 4

WITH prve AS (
    SELECT customer_type,
           SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY customer_type
),
druhe AS (
    SELECT customer_type,
           revenue,
           SUM(revenue) OVER () AS total_revenue,
           ROUND(revenue * 100.0 / SUM(revenue) OVER (), 2) AS revenue_percentage
    FROM prve
)
SELECT customer_type,
       revenue,
       total_revenue,
       revenue_percentage
FROM druhe
ORDER BY revenue DESC;

#Úloha 5
WITH tab AS (
    SELECT customer_id,
        product_name,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY sale_date DESC
        ) AS rn
    FROM flourmills_sales
)
SELECT customer_id,
       product_name,
       sale_date,
       total_amount
FROM tab
WHERE rn = 1
ORDER BY customer_id ASC
LIMIT 5;

#Úloha 6
WITH RECURSIVE cte AS(
    SELECT MIN(sale_date) AS mini, MAX(sale_date) AS maxi FROM flourmills_sales
), 
rcte AS (
    SELECT mini AS n FROM cte

    UNION ALL

    SELECT r.n + 1
    FROM rcte r
    CROSS JOIN cte c
    WHERE r.n < c.maxi

)
SELECT *
FROM rcte;

#Úloha 7

WITH RECURSIVE monthly_revenue AS (
    SELECT DATE_TRUNC('month', sale_date) AS month, SUM(total_amount) AS revenue FROM flourmills_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
ordered_months AS (
    SELECT ROW_NUMBER() OVER (ORDER BY month) AS rn,
    month, 
    revenue FROM monthly_revenue
),
cumulative_target AS (

    SELECT rn, month, revenue, revenue AS cumulative_revenue FROM ordered_months
    WHERE rn = 1

    UNION ALL

    
    SELECT om.rn,
           om.month,
           om.revenue,
           ct.cumulative_revenue + om.revenue
    FROM cumulative_target ct
    JOIN ordered_months om
      ON om.rn = ct.rn + 1
    WHERE ct.cumulative_revenue < 500000000
)
SELECT rn,
       month,
       revenue,
       cumulative_revenue
FROM cumulative_target
ORDER BY rn;