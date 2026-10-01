SELECT * FROM flourmills_sales;

#Úloha 1
SELECT product_name, total_amount FROM flourmills_sales
WHERE total_amount > (SELECT AVG(total_amount) FROM flourmills_sales);

#Úloha 2
