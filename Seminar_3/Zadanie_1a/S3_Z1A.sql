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

#Uloha 2
CREATE VIEW regional_monthly_sales AS
SELECT customers.region, DATE_TRUNC('month', order_date) AS month, SUM(orders.sales) AS regional_monthly_sales FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.region, DATE_TRUNC('month', order_date)

SELECT * FROM regional_monthly_sales
WHERE region = 'West';

#Úloha 3
CREATE VIEW analyst_orders AS
SELECT order_id, customer_id, product_id, sales, quantity, discount FROM orders;
SELECT * FROM analyst_orders;

#Úloha 4
CREATE INDEX idx_orders_customer_id
ON orders(customer_id);
SELECT *
FROM orders
WHERE customer_id = 'C001';

#Úloha 5
CREATE INDEX idx_orders_order_date
ON orders(order_date);
SELECT DATE_TRUNC('month', order_date) AS month, SUM(sales) FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY DATE_TRUNC('month', order_date) ASC;
