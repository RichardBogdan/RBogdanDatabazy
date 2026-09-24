CREATE Table customers
(
    customer_ID VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);
CREATE table products
(
    product_ID VARCHAR (20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
);

CREATE Table orders
(
    order_ID VARCHAR(20) PRIMARY KEY,
    customer_ID VARCHAR(20),
        FOREIGN KEY (customer_ID) 
            REFERENCES customers(customer_ID),
    product_ID VARCHAR(20),
        FOREIGN KEY (product_ID)
            REFERENCES products(product_ID),
    order_date DATE,
    ship_date DATE,
    sales NUMERIC(10,2),
    quantity INT,
    discount NUMERIC(10,2),
    profit NUMERIC(10,2)
);

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;

SELECT product_ID FROM products;