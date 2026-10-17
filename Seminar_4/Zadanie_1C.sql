SELECT * FROM retail_sales;


SELECT customer_id, SUM(quantity) FROM retail_sales
GROUP BY customer_id
ORDER BY SUM(quantity) ASC;

SELECT customer_id, quantity, SUM(quantity) OVER(PARTITION BY customer_id) AS total_quantity FROM retail_sales
ORDER BY customer_id ASC;   /*idcko, kvantita(dogabana zas) a xtelkovy pocet nakupenych pre customera*/

SELECT customer_id, quantity, SUM(quantity) OVER() AS total_quantity FROM retail_sales
ORDER BY customer_id ASC;   /*idcko, kvantita??(dogabana) a celkovy pocet nakupanej kvantity*/

#Úloha 2
SELECT customer_id, 
        invoice_no, 
        invoice_date, 
        quantity, 
        unit_price, 
        quantity * unit_price AS revenue,
        SUM(quantity * unit_price) OVER (
            PARTITION BY customer_id
            ORDER BY invoice_date ASC
            RANGE BETWEEN INTERVAL '14 days' PRECEDING AND CURRENT ROW) AS revenue_last_14_days
        FROM retail_sales
    WHERE customer_id IS NOT NULL
    ORDER BY customer_id, invoice_date;

#Úloha 3
SELECT stock_code, 
        country, 
        invoice_date, 
        quantity, 
        ROUND(AVG(quantity) OVER(
            PARTITION BY stock_code,country
            ORDER BY invoice_date ASC
            RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
        ),2) AS avg_quantity_7_days 
    FROM retail_sales
WHERE quantity > 1
ORDER BY stock_code, country, invoice_date;

#Úloha 4

WITH objednavky AS (
    SELECT customer_id, invoice_no, invoice_date
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id, invoice_no, invoice_date
),
s_nasledujucou AS (
    SELECT customer_id,
           invoice_no,
           invoice_date::date,
           LEAD(invoice_date) OVER (
               PARTITION BY customer_id
               ORDER BY invoice_date
           )::date AS next_invoice_date
    FROM objednavky
)
SELECT customer_id,
       invoice_no,
       invoice_date,
       next_invoice_date,
       next_invoice_date::date - invoice_date::date AS days_to_next_invoice
FROM s_nasledujucou
WHERE next_invoice_date IS NOT NULL
ORDER BY days_to_next_invoice DESC;

#Úloha 5
WITH tab AS (
    SELECT stock_code,
        invoice_no, 
        invoice_date,
        LAG(unit_price,1) OVER(
            PARTITION BY stock_code
            ORDER BY invoice_date ASC
        ) AS previous_price,
        LAG(unit_price,0) OVER(
            PARTITION BY stock_code
            ORDER BY invoice_date ASC
        ) AS current_price
    FROM retail_sales
)
SELECT stock_code,
        invoice_no, 
        invoice_date,
        previous_price,
        current_price, 
        current_price - previous_price AS price_difference
    FROM tab
    WHERE previous_price IS NOT NULL AND previous_price != current_price
    ORDER BY invoice_no ASC;

#Úloha 6
WITH tab AS (
    SELECT customer_id,
           SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT customer_id,
       total_amount,
       NTILE(4) OVER (ORDER BY total_amount DESC) AS sales_quartile
FROM tab
ORDER BY total_amount DESC;

#Úloha 7
WITH tab AS (
    SELECT country,
           DATE_TRUNC('month', invoice_date)::date AS month,
           SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    GROUP BY country, DATE_TRUNC('month', invoice_date)
)
SELECT country,
       month,
       total_amount,
       NTILE(4) OVER (
           PARTITION BY country
           ORDER BY total_amount DESC
       ) AS sales_quartile
FROM tab
ORDER BY country, month;

#Úloha 8
WITH cislovane AS (
    SELECT customer_id,
           invoice_no,
           invoice_date,
           stock_code,
           description,
           quantity,
           unit_price,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY invoice_date ASC, invoice_no ASC
           ) AS rn
    FROM retail_sales
    WHERE customer_id IS NOT NULL
)
SELECT customer_id,
       invoice_no,
       invoice_date,
       stock_code,
       description,
       quantity,
       unit_price
FROM cislovane
WHERE rn = 1
ORDER BY customer_id ASC;

#Úloha 9
WITH tab AS(
    SELECT 
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        quantity * unit_price AS amount,
        ROW_NUMBER() OVER(
            PARTITION BY invoice_no
            ORDER BY quantity * unit_price DESC
        ) AS row_num
        FROM retail_sales
)
SELECT * FROM tab
WHERE row_num BETWEEN 1 AND 3; 

#Úloha 10

WITH tab AS(
    SELECT 
        country, 
        DATE_TRUNC('month',invoice_date) AS month, 
        customer_id, 
        SUM(unit_price * quantity) AS total_amount
    FROM retail_sales
    GROUP BY country,DATE_TRUNC('month',invoice_date),customer_id
),
d_ranked AS (SELECT 
    country, 
    month, 
    customer_id, 
    total_amount,
    DENSE_RANK() OVER(
        PARTITION BY country, month
        ORDER BY total_amount DESC
    ) AS sales_rank
FROM tab
)
SELECT country, month::date, customer_id, total_amount, sales_rank
FROM d_ranked
WHERE sales_rank BETWEEN 1 AND 5
ORDER BY country, month, sales_rank, customer_id ;