/*
===============================================================================
Retail Sales Data Analysis Project
User: Jashwanth
Tool Used: MySQL
Description: This script performs data cleaning, exploratory data analysis (EDA),
and advanced business analysis on retail sales data.
===============================================================================
*/

-- =============================================================================
-- 1. DATA EXPLORATION & UNDERSTANDING
-- =============================================================================

-- Explore table structures
SELECT * FROM information_schema.columns WHERE table_name = 'gold_fact_sales';
DESCRIBE gold_fact_sales;
DESCRIBE gold_dim_customers;

-- Explore distinct categories and products
SELECT DISTINCT category, subcategory, product_name 
FROM gold_dim_products
ORDER BY 1, 2, 3;


-- =============================================================================
-- 2. DATA CLEANING & STANDARDIZATION
-- =============================================================================
/* Step 1: Handle missing values in date columns
Step 2: Cast columns to the correct Date data type 
*/

SET SQL_SAFE_UPDATES = 0;

-- Clean Sales Table Dates
UPDATE gold_fact_sales
SET order_date = NULL
WHERE TRIM(order_date) = '';

ALTER TABLE gold_fact_sales MODIFY order_date DATE;
ALTER TABLE gold_fact_sales MODIFY shipping_date DATE;
ALTER TABLE gold_fact_sales MODIFY due_date DATE;

-- Clean Customer Table Dates
UPDATE gold_dim_customers
SET birthdate = NULL
WHERE TRIM(birthdate) = '';

ALTER TABLE gold_dim_customers MODIFY birthdate DATE;


-- =============================================================================
-- 3. DESCRIPTIVE STATISTICS (EDA)
-- =============================================================================

-- Calculate the Date Range of the data
SELECT 
    MIN(order_date) AS First_Date,
    MAX(order_date) AS Last_Date,
    TIMESTAMPDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years
FROM gold_fact_sales;

-- Calculate Customer Age Range (Oldest vs Youngest)
SELECT 
    MIN(birthdate) AS oldest_birthdate,
    TIMESTAMPDIFF(YEAR, MIN(birthdate), CURDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    TIMESTAMPDIFF(YEAR, MAX(birthdate), CURDATE()) AS youngest_age
FROM gold_dim_customers;


-- =============================================================================
-- 4. KEY PERFORMANCE INDICATORS (KPIs)
-- =============================================================================

-- Aggregate Metrics
SELECT SUM(sales_amount) AS total_sales FROM gold_fact_sales;
SELECT SUM(quantity) AS total_quantity FROM gold_fact_sales;
SELECT AVG(price) AS avg_price FROM gold_fact_sales;
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold_fact_sales;
SELECT COUNT(product_key) AS total_products FROM gold_dim_products;
SELECT COUNT(customer_key) AS total_customers FROM gold_dim_customers;

-- Consolidated KPI Report
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold_fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold_fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold_fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold_fact_sales
UNION ALL
SELECT 'Total Products', COUNT(product_key) FROM gold_dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold_dim_customers;


-- =============================================================================
-- 5. DIMENSIONAL ANALYSIS
-- =============================================================================

-- Analysis by Country
SELECT country, COUNT(customer_id) AS total_customers
FROM gold_dim_customers
GROUP BY country
ORDER BY 2 DESC;

-- Analysis by Category (Revenue)
SELECT 
    b.category, 
    SUM(f.sales_amount) AS total_revenue
FROM gold_fact_sales AS f 
LEFT JOIN gold_dim_products AS b ON b.product_key = f.product_key
GROUP BY category
ORDER BY 2 DESC;

-- Analysis by Customer (Top Spenders)
SELECT 
    b.customer_key,
    b.first_name,
    b.last_name,
    SUM(f.sales_amount) AS total_sales
FROM gold_fact_sales AS f
LEFT JOIN gold_dim_customers AS b ON b.customer_key = f.customer_key
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

-- Analysis by Product (Top 5 Best Sellers)
SELECT
    b.product_name,
    SUM(f.sales_amount) AS highest_revenue
FROM gold_fact_sales AS f
LEFT JOIN gold_dim_products AS b ON b.product_key = f.product_key
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- =============================================================================
-- 6. TIME SERIES ANALYSIS
-- =============================================================================

-- Total Sales per Year
SELECT 
    YEAR(order_date) AS order_year, 
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity 
FROM gold_fact_sales
WHERE order_date IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- Total Sales per Month
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS order_month, 
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold_fact_sales
WHERE order_date IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- =============================================================================
-- 7. ADVANCED ANALYTICS (Window Functions & CTEs)
-- =============================================================================

-- 7.1 Cumulative (Running) Totals
SELECT 
    order_year,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_year) AS running_total_sales
FROM
    (SELECT 
        YEAR(order_date) AS order_year, 
        SUM(sales_amount) AS total_sales
    FROM gold_fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY 1) AS yearly_sales;

-- 7.2 Year-over-Year (YoY) Growth Analysis
WITH year_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold_dim_products p 
    LEFT JOIN gold_fact_sales f ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
    GROUP BY 1, 2
),
calculated_metrics AS (
    SELECT 
        order_year,
        product_name,
        current_sales,
        AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
        LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_sales
    FROM year_product_sales
)
SELECT 
    order_year,
    product_name,
    current_sales,
    avg_sales,
    (current_sales - avg_sales) AS diff_avg,
    CASE WHEN current_sales > avg_sales THEN 'Above Avg' ELSE 'Below Avg' END AS Avg_change,
    (current_sales - prev_sales) AS diff_sale,
    CASE WHEN current_sales > prev_sales THEN 'Increase' ELSE 'Decrease' END AS Prev_change
FROM calculated_metrics
ORDER BY product_name, order_year;

-- 7.3 Part-to-Whole Analysis (Category Contribution)
WITH category_sales AS (
    SELECT 
        b.category, 
        SUM(p.sales_amount) AS total_sales
    FROM gold_fact_sales p 
    LEFT JOIN gold_dim_products b ON p.product_key = b.product_key
    GROUP BY 1
)
SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    CONCAT(ROUND((total_sales / SUM(total_sales) OVER()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;


-- =============================================================================
-- 8. SEGMENTATION ANALYSIS
-- =============================================================================

-- 8.1 Product Cost Segmentation
WITH product_segments AS (
    SELECT 
        product_key, 
        product_name, 
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold_dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY 1
ORDER BY 2 DESC;

-- 8.2 Customer Segmentation (RFM-style)
/* Segments:
- VIP: > 12 months history & > €5,000 spend
- Regular: > 12 months history & <= €5,000 spend
- New: < 12 months history 
*/
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold_fact_sales f
    LEFT JOIN gold_dim_customers c ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;