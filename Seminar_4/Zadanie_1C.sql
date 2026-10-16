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