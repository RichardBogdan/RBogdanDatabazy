\set ON_ERROR_STOP on
CREATE SCHEMA IF NOT EXISTS gold;

BEGIN;

DROP TABLE IF EXISTS gold.fact_order,
                     gold.dim_date,
                     gold.dim_customer,
                     gold.dim_product,
                     gold.dim_employee,
                     gold.dim_shipper,
                     gold.sdim_day,
                     gold.sdim_month,
                     gold.sdim_quarter,
                     gold.sdim_address,
                     gold.sdim_city,
                     gold.sdim_country,
                     gold.sdim_category,
                     gold.sdim_supplier_address,
                     gold.sdim_supplier_city,
                     gold.sdim_supplier_country
CASCADE;

CREATE TABLE gold.sdim_day (
    day_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    day          INT         NOT NULL,
    day_of_week  VARCHAR(45) NOT NULL,
    UNIQUE (day, day_of_week)
);

CREATE TABLE gold.sdim_month (
    month_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    month        INT         NOT NULL UNIQUE,
    month_name   VARCHAR(45) NOT NULL
);

CREATE TABLE gold.sdim_quarter (
    quarter_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    quarter      INT         NOT NULL UNIQUE,
    quarter_name VARCHAR(2)  NOT NULL
);

CREATE TABLE gold.sdim_address (
    address_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    address      VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE gold.sdim_city (
    city_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city         VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE gold.sdim_country (
    country_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country      VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE gold.sdim_category (
    category_id   INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);

CREATE TABLE gold.sdim_supplier_address (
    address_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    address      VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE gold.sdim_supplier_city (
    city_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city         VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE gold.sdim_supplier_country (
    country_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country      VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE gold.dim_employee (
    employee_id INT PRIMARY KEY,
    last_name   VARCHAR(15),
    first_name  VARCHAR(15)
);

CREATE TABLE gold.dim_shipper (
    shipper_id   INT PRIMARY KEY,
    shipper_name VARCHAR(25)
);

CREATE TABLE gold.dim_date (
    date_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_date  DATE NOT NULL UNIQUE,
    day_id     INT NOT NULL REFERENCES gold.sdim_day (day_id),
    week       INT,
    month_id   INT NOT NULL REFERENCES gold.sdim_month (month_id),
    year       INT,
    quarter_id INT NOT NULL REFERENCES gold.sdim_quarter (quarter_id)
);

CREATE TABLE gold.dim_customer (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(50),
    address_id    INT NOT NULL REFERENCES gold.sdim_address (address_id),
    city_id       INT NOT NULL REFERENCES gold.sdim_city (city_id),
    country_id    INT NOT NULL REFERENCES gold.sdim_country (country_id)
);

CREATE TABLE gold.dim_product (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(50),
    unit          VARCHAR(25),
    supplier_name VARCHAR(45),
    category_id   INT NOT NULL REFERENCES gold.sdim_category (category_id),
    address_id    INT NOT NULL REFERENCES gold.sdim_supplier_address (address_id),
    city_id       INT NOT NULL REFERENCES gold.sdim_supplier_city (city_id),
    country_id    INT NOT NULL REFERENCES gold.sdim_supplier_country (country_id)
);

CREATE TABLE gold.fact_order (
    order_detail_id INT PRIMARY KEY,
    order_id        INT           NOT NULL,
    quantity        INT           NOT NULL CHECK (quantity > 0),
    price           NUMERIC(10,2) NOT NULL,
    total_amount    NUMERIC(12,2) NOT NULL,
    employee_id     INT NOT NULL REFERENCES gold.dim_employee (employee_id),
    date_id         INT NOT NULL REFERENCES gold.dim_date (date_id),
    customer_id     INT NOT NULL REFERENCES gold.dim_customer (customer_id),
    product_id      INT NOT NULL REFERENCES gold.dim_product (product_id),
    shipper_id      INT NOT NULL REFERENCES gold.dim_shipper (shipper_id)
);

CREATE INDEX ON gold.fact_order (order_id);
CREATE INDEX ON gold.fact_order (employee_id);
CREATE INDEX ON gold.fact_order (date_id);
CREATE INDEX ON gold.fact_order (customer_id);
CREATE INDEX ON gold.fact_order (product_id);
CREATE INDEX ON gold.fact_order (shipper_id);

INSERT INTO gold.sdim_day (day, day_of_week)
SELECT DISTINCT
    EXTRACT(DAY FROM order_date)::INT,
    TO_CHAR(order_date, 'FMDay')
FROM silver.stg_orders
ORDER BY 1, 2;

INSERT INTO gold.sdim_month (month, month_name)
SELECT DISTINCT
    EXTRACT(MONTH FROM order_date)::INT,
    TO_CHAR(order_date, 'FMMonth')
FROM silver.stg_orders
ORDER BY 1;

INSERT INTO gold.sdim_quarter (quarter, quarter_name)
SELECT DISTINCT
    EXTRACT(QUARTER FROM order_date)::INT,
    'Q' || EXTRACT(QUARTER FROM order_date)::INT
FROM silver.stg_orders
ORDER BY 1;

INSERT INTO gold.sdim_address (address)
SELECT DISTINCT address FROM silver.stg_customers ORDER BY address;

INSERT INTO gold.sdim_city (city)
SELECT DISTINCT city FROM silver.stg_customers ORDER BY city;

INSERT INTO gold.sdim_country (country)
SELECT DISTINCT country FROM silver.stg_customers ORDER BY country;

INSERT INTO gold.sdim_category (category_id, category_name)
SELECT category_id, category_name
FROM silver.stg_categories
ORDER BY category_id;

INSERT INTO gold.sdim_supplier_address (address)
SELECT DISTINCT address FROM silver.stg_suppliers ORDER BY address;

INSERT INTO gold.sdim_supplier_city (city)
SELECT DISTINCT city FROM silver.stg_suppliers ORDER BY city;

INSERT INTO gold.sdim_supplier_country (country)
SELECT DISTINCT country FROM silver.stg_suppliers ORDER BY country;

INSERT INTO gold.dim_employee (employee_id, last_name, first_name)
SELECT employee_id, last_name, first_name
FROM silver.stg_employees
ORDER BY employee_id;

INSERT INTO gold.dim_shipper (shipper_id, shipper_name)
SELECT shipper_id, shipper_name
FROM silver.stg_shippers
ORDER BY shipper_id;

INSERT INTO gold.dim_date (full_date, day_id, week, month_id, year, quarter_id)
SELECT
    d.order_date,
    sd.day_id,
    EXTRACT(WEEK FROM d.order_date)::INT,
    sm.month_id,
    EXTRACT(YEAR FROM d.order_date)::INT,
    sq.quarter_id
FROM (SELECT DISTINCT order_date FROM silver.stg_orders) d
JOIN gold.sdim_day     sd ON sd.day     = EXTRACT(DAY FROM d.order_date)::INT
                         AND sd.day_of_week = TO_CHAR(d.order_date, 'FMDay')
JOIN gold.sdim_month   sm ON sm.month   = EXTRACT(MONTH FROM d.order_date)::INT
JOIN gold.sdim_quarter sq ON sq.quarter = EXTRACT(QUARTER FROM d.order_date)::INT
ORDER BY d.order_date;

INSERT INTO gold.dim_customer (customer_id, customer_name, address_id, city_id, country_id)
SELECT
    c.customer_id,
    c.customer_name,
    a.address_id,
    ci.city_id,
    co.country_id
FROM silver.stg_customers c
JOIN gold.sdim_address a  ON a.address  = c.address
JOIN gold.sdim_city    ci ON ci.city    = c.city
JOIN gold.sdim_country co ON co.country = c.country
ORDER BY c.customer_id;

INSERT INTO gold.dim_product (
    product_id, product_name, unit, supplier_name,
    category_id, address_id, city_id, country_id
)
SELECT
    p.product_id,
    p.product_name,
    p.unit,
    s.supplier_name,
    p.category_id,
    sa.address_id,
    sc.city_id,
    sco.country_id
FROM silver.stg_products p
JOIN silver.stg_suppliers s            ON s.supplier_id = p.supplier_id
JOIN gold.sdim_supplier_address sa     ON sa.address    = s.address
JOIN gold.sdim_supplier_city sc        ON sc.city       = s.city
JOIN gold.sdim_supplier_country sco    ON sco.country   = s.country
ORDER BY p.product_id;

INSERT INTO gold.fact_order (
    order_detail_id, order_id, quantity, price, total_amount,
    employee_id, date_id, customer_id, product_id, shipper_id
)
SELECT
    od.order_detail_id,
    od.order_id,
    od.quantity,
    p.price,
    od.quantity * p.price,
    o.employee_id,
    d.date_id,
    o.customer_id,
    od.product_id,
    o.shipper_id
FROM silver.stg_orderdetails od
JOIN silver.stg_orders   o ON o.order_id   = od.order_id
JOIN silver.stg_products p ON p.product_id = od.product_id
JOIN gold.dim_date       d ON d.full_date  = o.order_date
ORDER BY od.order_detail_id;

COMMIT;
