/*
===============================================================================
Customer Report View
User: Jashwanth
Description: This script creates a SQL View (gold_customer_report) to store 
aggregated customer behavior metrics for BI reporting.
===============================================================================
*/

CREATE OR REPLACE VIEW gold_customer_report AS

WITH base_query AS (
    -- Fetch core customer and transaction details
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        TIMESTAMPDIFF(YEAR, birthdate, CURRENT_DATE) AS age
    FROM gold_fact_sales f
    LEFT JOIN gold_dim_customers c
        ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL
),

customer_aggregation AS (
    -- Aggregate metrics at the customer level
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)

-- Final Report View with segmentation logic
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    
    -- Demographics Segmentation
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    
    -- Business Segmentation (VIP vs Regular)
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    
    last_order_date,
    TIMESTAMPDIFF(MONTH, last_order_date, CURRENT_DATE) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    
    -- Average Order Value (AOV)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,
    
    -- Average Monthly Spend
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation;

SELECT * FROM gold_customer_report;