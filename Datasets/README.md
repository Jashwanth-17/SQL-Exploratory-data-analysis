# 📂 Data Dictionary

This repository utilizes a comprehensive retail dataset structured as a **Star Schema**, consisting of one Fact table and two Dimension tables.

## 📊 Entity Relationship Diagram (ERD)
- **Fact Table:** `gold_fact_sales`
- **Dimension Tables:** `gold_dim_customers`, `gold_dim_products`
- **Relationships:**
  - `gold_fact_sales.customer_key` → `gold_dim_customers.customer_key`
  - `gold_fact_sales.product_key` → `gold_dim_products.product_key`

---

## 1. 🛒 Sales Fact Table (`gold_fact_sales.csv`)
The central table containing all transaction records. Each row represents a specific product sold in an order.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `order_number` | `VARCHAR` | Unique identifier for the transaction (Order ID). |
| `order_date` | `DATE` | The date the order was placed. |
| `product_key` | `INT` | Foreign Key linking to the Product Dimension. |
| `customer_key` | `INT` | Foreign Key linking to the Customer Dimension. |
| `sales_amount` | `DECIMAL` | Total revenue generated from the line item. |
| `quantity` | `INT` | Number of units purchased. |
| `price` | `DECIMAL` | Unit price of the product at the time of sale. |
| `shipping_date`| `DATE` | The date the order was shipped. |
| `due_date` | `DATE` | The date the payment or delivery was due. |

---

## 2. 👥 Customer Dimension (`gold_dim_customers.csv`)
Contains demographic and personal details of the customers.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `customer_key` | `INT` | Primary Key. Unique system identifier for the customer. |
| `customer_number`| `VARCHAR` | Business-facing customer ID code. |
| `first_name` | `VARCHAR` | Customer's first name. |
| `last_name` | `VARCHAR` | Customer's last name. |
| `country` | `VARCHAR` | The country where the customer resides. |
| `birthdate` | `DATE` | Used to calculate customer Age and Age Groups. |
| `gender` | `VARCHAR` | Customer gender (Male/Female/Other). |
| `marital_status`| `VARCHAR` | Single, Married, Divorced, etc. |
| `create_date` | `DATE` | Date the customer account was created (Membership Start Date). |

---

## 3. 📦 Product Dimension (`gold_dim_products.csv`)
Contains details about the product inventory, hierarchy, and costs.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `product_key` | `INT` | Primary Key. Unique system identifier for the product. |
| `product_name` | `VARCHAR` | Full commercial name of the product. |
| `category` | `VARCHAR` | High-level product classification (e.g., Electronics, Furniture). |
| `subcategory` | `VARCHAR` | Granular product classification (e.g., Phones, Chairs). |
| `cost` | `DECIMAL` | Manufacturing or acquisition cost (used to calculate Profit). |
| `maintenance` | `VARCHAR` | Maintenance requirements (if applicable). |

---

## 📅 Data Quality Notes
* **Date Range:** The dataset covers transactions from **2010 to 2024**.
* **Data Cleaning:** Null values in `order_date` and `birthdate` were handled during the SQL preprocessing stage (see `Project.sql`).
