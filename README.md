# UrbanCart — E-commerce Data Cleaning, EDA & SQL Analysis

## 📌 Project Overview

**UrbanCart** is an e-commerce analytics project focused on cleaning transactional data, performing exploratory data analysis (EDA), and answering business questions using PostgreSQL.

The project works with data covering customers, orders, order items, products, shipments, warehouses, and suppliers.

The workflow combines:

- **Python & Pandas** for data cleaning and EDA
- **Matplotlib & Seaborn** for visualization
- **PostgreSQL / pgAdmin** for SQL-based business analysis
- **SQL window functions, CTEs, joins and aggregations** for advanced analysis


# 📁 Repository Structure

```text
UrbanCart/
│
├── data/
│   ├── raw/
│   └── data_cleaned/
│
├── notebooks/
│   ├── urban_cart_data_cleaning.ipynb
│   └── Exploratory_data_analysis.ipynb
│
├── sql/
│   ├── lvl_1.sql
│   ├── lvl_2.sql
│   └── lvl_3.sql
│
├── docs/
│   └── SQL_Analysis.md
│
├── images/
│    └── eda/
│    └── sql/
│
├── .gitignore
└── README.md
```

---

## 🎯 Project Objectives

The main objectives of the project are to:

1. Clean and validate the raw UrbanCart datasets.
2. Handle missing, invalid, duplicate and inconsistent data.
3. Standardize categorical values and date fields.
4. Identify invalid relationships between tables.
5. Perform univariate and business-focused EDA.
6. Analyze sales, orders, customers, products, shipping and suppliers.
7. Solve progressively difficult SQL business problems.
8. Demonstrate practical SQL techniques used in data analytics.

---

## 🗂️ Dataset Structure

The project uses seven related tables:

| Table | Description |
|---|---|
| `customers` | Customer details, location, signup date and segment |
| `orders` | Order information, customer, warehouse, status and payment mode |
| `order_items` | Products purchased, quantity and discount |
| `products` | Product, category, price, weight and supplier information |
| `shipments` | Shipping, delivery, carrier and shipping-cost information |
| `warehouses` | Warehouse locations and capacity |
| `suppliers` | Supplier details, lead time and reliability |



# 🧹 Data Cleaning

Data cleaning was performed using the `urban_cart_data_cleaning.ipynb` notebook.

### Major cleaning steps

#### 1. Date standardization

Converted date columns to proper Pandas datetime values and handled mixed date formats.

Columns included:

- `signup_date`
- `order_date`
- `ship_date`
- `delivery_date`

#### 2. Missing values

Checked and handled missing values in important fields.

Examples:

- Removed rows with missing `quantity`.
- Removed orders with missing `order_date`.
- Removed products with missing `unit_price`.
- Removed shipments where both shipping and delivery dates were missing.

#### 3. Invalid numeric values

`unit_price` was converted to numeric and negative prices were removed.

Negative order quantities were also identified and removed.

```text
Negative quantity rows identified: 1,849
```

#### 4. Duplicate records

Duplicate records were checked across the datasets and removed where necessary.

#### 5. Categorical standardization

Inconsistent capitalization and whitespace were standardized using:

```python
.str.strip().str.title()
```

This was particularly useful for fields such as:

- customer segments
- product categories
- carriers
- order statuses
- IDs and other categorical columns

#### 6. Phone number validation

Phone numbers were checked for invalid lengths.

```text
10-digit phone numbers: 3,791
5-digit invalid phone numbers: 209
```

Invalid 5-digit phone values were replaced with missing values.

#### 7. Delivery-time validation

A `delivery_days` column was created:

```python
delivery_days = delivery_date - ship_date
```

Negative and unrealistic delivery durations were removed.

The cleaned delivery-time range was restricted to:

```text
0 ≤ delivery_days ≤ 20
```

#### 8. Referential integrity

Invalid foreign-key relationships were identified.

Examples:

```text
Orders with invalid customer IDs: 79
Order items with invalid product IDs: 567
```

These invalid records were removed before the cleaned data was loaded into PostgreSQL.





# 🔎 Exploratory Data Analysis

EDA was performed in `Exploratory_data_analysis.ipynb`.

## Univariate Analysis

A reusable univariate-analysis function was created to inspect individual columns based on their data type.

For numeric columns:

- Summary statistics
- Histogram
- Boxplot

For categorical columns:

- Value counts
- Bar chart

---

## Business EDA

The analysis explored several relationships.

### Customer Segment vs Order Value

Calculated order-level revenue using:

```text
quantity × unit_price × (1 - discount)
```

Then compared order values across customer segments using boxplots and median order values.

### Carrier vs Shipping Cost

Compared:

- number of shipments
- mean shipping cost
- median shipping cost
- standard deviation

Shipping costs were also visualized using boxplots.

### Carrier vs Delivery Time

Compared delivery-time distributions across different carriers.

### Warehouse vs Delivery Time

Calculated average and median delivery time for each warehouse.

### Local vs Cross-City Delivery

Compared delivery times based on whether the warehouse and customer were in the same city.

### Category vs Discount

Compared average and median discount percentages across product categories.

---

# 📈 Time-Series Analysis

The EDA also included time-based analysis.

### Monthly Orders

Created monthly and yearly order counts and visualized the monthly order trend.

### Monthly Revenue

Calculated order revenue using:

```text
quantity × unit_price × (1 - discount)
```

and analyzed monthly revenue trends.

### Average Delivery Time by Month

Calculated monthly average delivery time and visualized its trend over time.

---

# 📉 Additional Analysis

### Outlier Detection

Boxplots were used to inspect:

- `unit_price`
- `quantity`
- `delivery_days`

### Correlation Analysis

A correlation heatmap was created for:

- `quantity`
- `unit_price`
- `discount_pct`

---

# 🧠 SQL Analysis

SQL analysis is divided into three levels based on difficulty.

## Level 1 

`lvl_1.sql`

Topics covered:

- Basic counts
- `JOIN`
- `GROUP BY`
- `ORDER BY`
- `LIMIT`
- Percentage calculations
- `COUNT()`
- `AVG()`
- Ranking within groups

Business questions include:

1. Total orders, customers and products
2. Top product categories by quantity sold
3. Cities with the highest number of orders
4. Order-status distribution
5. Top customers by number of orders
6. Average product price by category
7. Most common payment mode by customer segment

---

## Level 2

`lvl_2.sql`

Topics covered:

- Date functions
- `DATE_TRUNC`
- `EXTRACT`
- CTEs
- `LEFT JOIN`
- Anti-joins
- Revenue calculations
- Supplier/product/order relationships

Business questions include:

8. Monthly revenue trend for 2023
9. Highest and lowest warehouse order value
10. Discount vs category revenue
11. Customers with no orders
12. Top suppliers by revenue

---

## Level 3 — Advanced

`lvl_3(1).sql`

Topics covered:

- CTEs
- Window functions
- `RANK()`
- `DENSE_RANK()`
- `NTILE()`
- `LAG()`
- `SUM() OVER()`
- `MAX() OVER()`
- `PERCENT_RANK()`
- Running totals
- Customer segmentation
- Recency analysis
- Supplier scoring

Business questions include:

13. Customer recency analysis
14. Top 3 products by revenue within each category
15. Customer lifetime-spend tiers
16. Cumulative monthly revenue
17. Month-over-month order growth
18. Products at risk due to no recent orders
19. Contribution of the most expensive line item to an order
20. Supplier performance scorecard

---

# 🛠️ SQL Concepts Demonstrated

The project demonstrates practical use of:

```text
SELECT
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT
JOIN
LEFT JOIN
CTE (WITH)
CASE
COALESCE
COUNT
SUM
AVG
ROUND
DATE_TRUNC
EXTRACT
RANK
DENSE_RANK
NTILE
LAG
PERCENT_RANK
Window Functions
Subqueries
```

---

# 🧮 Revenue Definition

Where revenue is calculated, the project generally uses:

```text
Revenue =
Quantity × Unit Price × (1 - Discount Percentage / 100)
```

This calculation is used across both the Python analysis and SQL analysis.

---



> Keep database credentials, passwords, local file paths and other machine-specific information out of GitHub.

---

# 🚀 How to Run the Project

## 1. Clone the repository

```bash
git clone <your-repository-url>
cd UrbanCart
```

## 2. Install Python dependencies

```bash
pip install pandas matplotlib seaborn sqlalchemy psycopg2-binary jupyter
```

## 3. Run the cleaning notebook

Open:

```text
notebooks/urban_cart_data_cleaning.ipynb
```

The notebook:

1. Loads the raw datasets.
2. Cleans and validates the data.
3. Saves cleaned CSV files.
4. Loads the cleaned data into PostgreSQL.

## 4. Run the EDA notebook

Open:

```text
notebooks/Exploratory_data_analysis.ipynb
```

Run the analysis and visualizations after the cleaned data is available.

## 5. Run the SQL analysis

Open the SQL files in PostgreSQL/pgAdmin:

```text
sql/lvl_1.sql
sql/lvl_2.sql
sql/lvl_3.sql
```

Execute the questions progressively from Level 1 to Level 3.

---

# 📌 Key Takeaways

This project demonstrates an end-to-end analytics workflow:

```text
Raw Data
   ↓
Data Cleaning
   ↓
Data Validation
   ↓
Exploratory Data Analysis
   ↓
PostgreSQL
   ↓
SQL Business Questions
   ↓
Advanced Analytics
```

The project focuses not only on writing SQL queries, but also on understanding **why the data needs to be cleaned before analysis** and how cleaned relational data can be used to answer practical business questions.

---

# 📚 Project Files

| File | Purpose |
|---|---|
| `urban_cart_data_cleaning.ipynb` | Data cleaning, validation and PostgreSQL loading |
| `Exploratory_data_analysis.ipynb` | EDA, visualizations and time-series analysis |
| `lvl_1.sql` | Beginner SQL analysis |
| `lvl_2.sql` | Intermediate SQL analysis |
| `lvl_3(1).sql` | Advanced SQL and window-function analysis |

---

## 👤 Author

**Ruchir Saraf**

Data Analytics Project — UrbanCart E-commerce Analytics
