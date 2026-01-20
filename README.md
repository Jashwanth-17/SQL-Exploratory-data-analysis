# Retail Sales Data Analysis SQL Project

## Project Overview
**Project Title**: Retail Sales Analysis  
**Database**: `gold_db` (MySQL)  
**Level**: Intermediate to Advanced  
**Author**: Jashwanth

This project demonstrates a real-world data analysis workflow using a retail dataset. The analysis starts with data cleaning and exploration, moves to building key performance indicators (KPIs), and culminates in advanced customer segmentation and trend analysis using complex SQL techniques like Window Functions and CTEs.

## Objectives
1.  **Data Cleaning**: Identify and remove null values, standardize date formats.
2.  **Exploratory Data Analysis (EDA)**: Understand the data distribution, customer demographics, and product performance.
3.  **Business Analysis**: Answer specific business questions regarding sales trends, top-performing categories, and profitability.
4.  **Advanced Segmentation**: Use RFM-style logic to segment customers into VIP, Regular, and New categories.

## Schema Structure
The project uses a **Star Schema** approach with one Fact table and two Dimension tables:



* **`gold_fact_sales`**: The main transaction table containing `order_date`, `sales_amount`, `quantity`, and foreign keys.
* **`gold_dim_customers`**: Contains customer demographics like `age`, `gender`, and `birthdate`.
* **`gold_dim_products`**: Contains product details like `category`, `subcategory`, and `cost`.

---

## Business Problems & Solutions

The following SQL queries were developed to answer key business questions.

### 1. What are the key performance metrics (KPIs) for the business?
Calculated total sales, total quantity sold, average price, and total orders to gauge overall performance.

```sql
SELECT 
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    AVG(price) AS avg_price,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold_fact_sales;
```

### 2. Which categories contribute the most to total revenue?
Identified product categories that drive the highest sales volume to determine focus areas.

```sql
SELECT 
    b.category, 
    SUM(f.sales_amount) AS total_revenue
FROM gold_fact_sales AS f 
LEFT JOIN gold_dim_products AS b ON b.product_key = f.product_key
GROUP BY category
ORDER BY total_revenue DESC;
```

### 3. Who are the top 5 highest-spending customers?
Located the most valuable customers to target for potential loyalty rewards.

```sql
SELECT 
    b.customer_key,
    b.first_name,
    b.last_name,
    SUM(f.sales_amount) AS total_sales
FROM gold_fact_sales AS f
LEFT JOIN gold_dim_customers AS b ON b.customer_key = f.customer_key
GROUP BY 1, 2, 3
ORDER BY total_sales DESC
LIMIT 5;
```

### 4. How has sales performance changed year-over-year (YoY)?
Used Window Functions `(LAG)` to compare current year sales with the previous year to identify growth or decline.

```sql
WITH year_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold_dim_products p 
    LEFT JOIN gold_fact_sales f ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
    GROUP BY 1, 2
)
SELECT 
    order_year,
    product_name,
    current_sales,
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_sales,
    CASE 
        WHEN current_sales > LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) 
        THEN 'Increase' ELSE 'Decrease' 
    END AS trend
FROM year_product_sales;
```

### 5. What is the cumulative sales trend over time?
Used Window Functions `(SUM OVER)` to calculate the running total of sales across years.

```sql
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
```

### 6. How can we segment customers based on spending and loyalty?
Implemented Data Transformation logic to categorize customers into 'VIP' and 'Regular' segments for targeted marketing.

```sql
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
GROUP BY customer_segment;
```

## 🚀 Key Technical Skills Demonstrated
Advanced SQL Functions: Proficient use of `RANK()`, `LAG()`, and `OVER()` for windowing operations.

Data Aggregation: Complex `GROUP BY` and `CASE` statements for conditional logic.

Data Modeling: Creation of SQL Views `(CREATE VIEW)` to store logic for BI tools.

Data Cleaning: Using `CAST` and date formatting functions to prepare raw data.

## 📊 Reports Created
Product Report View (gold_report_products): Aggregates product-level data, including profit margins and performance segments.

Customer Report View (gold_customer_report): Aggregates customer-level data, including age groups, tenure, and average order value.

## 🛠️ How to Use
1. Setup: Import the raw dataset into your MySQL database.
2. Run Analysis: Execute `Project.sql` to perform cleaning and generate insights.
3. Generate Reports: Execute `Product_Report.sql` and `Customer_Report.sql` to create the views used for dashboarding.

👤 Author
Jashwanth Data Analyst | SQL | Python | Power BI

Connect with me on [LinkedIn](https://www.linkedin.com/in/jashwanth-varma-m-b87671208?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_view_base_contact_details%3B81aE%2FakEQrO%2B7bA3F%2B61IA%3D%3D).
