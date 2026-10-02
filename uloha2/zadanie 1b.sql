SELECT * FROM flourmills_sales;

#Úloha 1
SELECT product_name, total_amount FROM flourmills_sales
WHERE total_amount > (SELECT AVG(total_amount) FROM flourmills_sales);

#Úloha 2
SELECT sales_id, sale_date, region, product_category FROM flourmills_sales
WHERE product_category = (SELECT product_category FROM flourmills_sales GROUP BY product_category
ORDER BY SUM(quantity_sold) DESC
LIMIT 1)
ORDER BY sales_id ASC;

#Úloha 3
SELECT product_name, total_amount, (SELECT AVG(total_amount) FROM flourmills_sales) AS avg_amount FROM flourmills_sales;

#Úloha 4
SELECT product_name, total_amount, total_amount / (SELECT SUM(total_amount) FROM flourmills_sales) AS amount_share FROM flourmills_sales;

#Úloha 5
SELECT mesiac, monthly_sales FROM (
    SELECT EXTRACT(MONTH FROM sale_date) AS mesiac, SUM(total_amount) AS monthly_sales FROM flourmills_sales GROUP BY mesiac)
ORDER BY mesiac ASC;

#Úloha 6 
SELECT * FROM (
    SELECT product_category, SUM(total_amount) AS total_sales FROM flourmills_sales 
    GROUP BY product_category)                                          /*nerozumiem asi zadaniu lebo vsetky su vyssie ako 50 000 000*/
WHERE total_sales > 50000000
ORDER BY product_category DESC;

#Úloha 7
SELECT f1.product_name, f1.product_category, f1.total_amount FROM flourmills_sales AS f1
WHERE f1.total_amount > (
    SELECT AVG(f2.total_amount) FROM flourmills_sales AS f2         
    WHERE f2.product_category = f1.product_category);

#Úloha 8
SELECT f1.product_name, f1.region, f1.total_amount,
(   SELECT MIN(f2.total_amount)
    FROM flourmills_sales AS f2
    WHERE f2.region = f1.region) AS region_min_amount FROM flourmills_sales AS f1;
