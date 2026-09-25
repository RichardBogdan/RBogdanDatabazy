SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;

/*Úloha 2*/
SELECT orders.order_id, customers.customer_name, orders.sales FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id
WHERE orders.sales > 500;  