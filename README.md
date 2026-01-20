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
