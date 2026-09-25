SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;

/*Úloha 2*/
SELECT orders.order_id, customers.customer_name, orders.sales FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id
WHERE orders.sales > 500;  

/*Úloha 3*/
SELECT orders.order_id, customers.customer_name, products.category, orders.sales FROM orders
INNER JOIN customers ON orders.customer_id = customers.customer_id
INNER JOIN products ON orders.product_id = products.product_id;

/*Úloha 4*/
SELECT customers.region, SUM(orders.sales) FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.region;

/*Úloha 5*/
SELECT products.sub_category sc, SUM(orders.sales) sos FROM products
LEFT JOIN orders on products.product_id = orders.product_id
GROUP BY sc;