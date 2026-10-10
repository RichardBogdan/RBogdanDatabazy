SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM products;

#Úloha 1
CREATE VIEW high_value_customers AS
SELECT customers.customer_id, customers.customer_name, SUM(orders.sales) AS total_sales FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_id
HAVING SUM(orders.sales) > 2000;

SELECT * FROM high_value_customers;