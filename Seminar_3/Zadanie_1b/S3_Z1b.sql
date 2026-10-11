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