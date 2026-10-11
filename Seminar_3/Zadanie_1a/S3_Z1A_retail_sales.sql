SELECT * FROM orders;

#Úloha 8
CREATE OR REPLACE PROCEDURE get_customer_sales(p_customer_id VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales NUMERIC;
BEGIN
    SELECT COALESCE(SUM(sales), 0)
    INTO v_total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Zákazník: %, celkový predaj: %', p_customer_id, v_total_sales;
END;
$$;
CALL get_customer_sales('C001');

#Úloha 9

CREATE OR REPLACE PROCEDURE apply_regional_discount(
    region_name VARCHAR,
    discount_rate NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders o
    SET sales = n.new_sales
    FROM (
        SELECT order_id, sales * (1 - discount_rate) AS new_sales
        FROM orders
        WHERE region = region_name
    ) n
    WHERE o.order_id = n.order_id;

    RAISE NOTICE 'Bola aplikovaná zľava % %% na región %', discount_rate * 100, region_name;
END;
$$;
CALL apply_regional_discount('West', 0.10);