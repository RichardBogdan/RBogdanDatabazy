
\set ON_ERROR_STOP on \encoding UTF8;

CREATE SCHEMA IF NOT EXISTS silver;


DROP VIEW IF EXISTS silver.stg_orderdetails,
                    silver.stg_orders,
                    silver.stg_products,
                    silver.stg_categories,
                    silver.stg_suppliers,
                    silver.stg_customers,
                    silver.stg_employees,
                    silver.stg_shippers
CASCADE;

CREATE VIEW silver.stg_categories AS
SELECT
    categoryid                      AS category_id,
    TRIM(categoryname)              AS category_name,
    TRIM(description)               AS description
FROM bronze.categories;

CREATE VIEW silver.stg_customers AS
SELECT
    customerid                      AS customer_id,
    TRIM(customername)              AS customer_name,
    TRIM(contactname)               AS contact_name,
    TRIM(address)                   AS address,
    TRIM(city)                      AS city,
    NULLIF(TRIM(postalcode), '')    AS postal_code,
    TRIM(country)                   AS country
FROM bronze.customers;

CREATE VIEW silver.stg_employees AS
SELECT
    employeeid                      AS employee_id,
    TRIM(lastname)                  AS last_name,
    TRIM(firstname)                 AS first_name,
    birthdate                       AS birth_date,
    NULLIF(TRIM(photo), '')         AS photo,
    NULLIF(TRIM(notes), '')         AS notes
FROM bronze.employees;

CREATE VIEW silver.stg_shippers AS
SELECT
    shipperid                       AS shipper_id,
    TRIM(shippername)               AS shipper_name,
    NULLIF(TRIM(phone), '')         AS phone
FROM bronze.shippers;

CREATE VIEW silver.stg_suppliers AS
SELECT
    supplierid                      AS supplier_id,
    TRIM(suppliername)              AS supplier_name,
    TRIM(contactname)               AS contact_name,
    TRIM(address)                   AS address,
    TRIM(city)                      AS city,
    NULLIF(TRIM(postalcode), '')    AS postal_code,
    TRIM(country)                   AS country,
    NULLIF(TRIM(phone), '')         AS phone
FROM bronze.suppliers;

CREATE VIEW silver.stg_products AS
SELECT
    productid                       AS product_id,
    TRIM(productname)               AS product_name,
    supplierid                      AS supplier_id,
    categoryid                      AS category_id,
    TRIM(unit)                      AS unit,
    price                           AS price
FROM bronze.products;

CREATE VIEW silver.stg_orders AS
SELECT
    orderid                         AS order_id,
    customerid                      AS customer_id,
    employeeid                      AS employee_id,
    orderdate                       AS order_date,
    shipperid                       AS shipper_id
FROM bronze.orders;

CREATE VIEW silver.stg_orderdetails AS
SELECT
    orderdetailid                   AS order_detail_id,
    orderid                         AS order_id,
    productid                       AS product_id,
    quantity                        AS quantity
FROM bronze.orderdetails;