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