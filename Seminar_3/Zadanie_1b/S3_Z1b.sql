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