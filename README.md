# Swiggy-Sales-Analysis
Swiggy Sales Analysis using SQL &amp; Power BI End-to-end data analytics project involving data cleaning and validation in PostgreSQL, star schema data modeling, KPI development, and interactive Power BI dashboards to analyze revenue, orders, city, restaurant, dish, and category performance.
# 🍔 Swiggy Sales Analysis – End-to-End Data Analytics Project

## 📌 Project Overview
This project presents a **complete end-to-end data analytics solution** built using Swiggy food delivery sales data.  
The goal of the project is to demonstrate **real-world Data Analyst skills**, including:

- Data cleaning & validation using SQL
- Dimensional modeling (Star Schema)
- KPI development
- Business-focused data analysis
- Interactive dashboards using Power BI

The analysis focuses on **sales trends, city performance, restaurant efficiency, dish popularity, customer spending behavior, and category-level insights**.

---

## 🎯 Business Objectives
- Ensure high data quality through SQL-based cleaning and validation
- Design a scalable **Star Schema** for analytical reporting
- Track key KPIs such as revenue, orders, ratings, and AOV
- Identify top-performing cities, restaurants, dishes, and categories
- Enable interactive analysis using Power BI dashboards
- Deliver insights suitable for executive and business decision-making

---

## 🗂️ Dataset Description

### Source
- Raw data stored as CSV files
- Ingested directly into **PostgreSQL**

### Key Attributes
- Order Date  
- State, City, Location  
- Restaurant Name  
- Dish Name  
- Category (Cuisine)  
- Price (INR)  
- Rating & Rating Count  

---

## 🧹 Data Cleaning & Validation (SQL)
All data preparation was performed **entirely using SQL**.

### ✔ Null Value Checks
- Verified missing values in critical columns such as:
  - Order Date
  - City
  - Price
  - Rating

### ✔ Blank / Empty Value Handling
- Identified empty string values
- Standardized text columns to avoid incorrect aggregations

### ✔ Duplicate Detection & Removal
- Detected duplicate records using business-relevant columns
- Removed duplicates using `ROW_NUMBER()` with `PARTITION BY`
- Retained one valid record per order

Result: **Clean, reliable, and analysis-ready dataset**

---

## 🧱 Data Modeling – Star Schema
A **Star Schema** was implemented to support efficient analytics and Power BI reporting.

### ⭐ Fact Table
**fact_swiggy_order**
- price_inr
- rating
- rating_count
- Foreign keys to all dimensions

### 📐 Dimension Tables
- **dim_date** → full_date, year, quarter, month, week, day_name
- **dim_location** → state, city, location
- **dim_restaurant** → restaurant_name
- **dim_category** → cuisine / category
- **dim_dish** → dish_name

### Benefits
- Faster query performance
- Clear separation of facts and dimensions
- BI-friendly and scalable data model

---

## 📊 KPI Development
The following KPIs were calculated using SQL and visualized in Power BI:

- **Total Revenue:** 53.00M INR
- **Total Orders:** 197K
- **Average Rating:** 4.34
- **Average Order Value (AOV)**

These KPIs provide a high-level snapshot of business performance.

---

## 📈 Analytical Insights

### ⏱️ Time-Based Analysis
- Monthly revenue and order trends show seasonality
- **Q2 recorded the highest revenue contribution**
- Clear weekday vs weekend ordering behavior

### 🌆 City-Level Performance
- **Bengaluru** is the highest revenue-generating city
- Other strong cities include Lucknow, Hyderabad, and Mumbai
- Revenue contribution varies significantly across cities

### 🍽️ Restaurant Performance
- KFC and McDonald’s are top revenue-generating restaurants
- Some restaurants have lower order volume but higher AOV, indicating premium pricing

### 🥗 Dish & Category Analysis
- Top dishes by revenue include:
  - Bold BBQ Veggie
  - Korean & Thai Rolls
  - Paneer Butter Masala
- Recommended and Main Course categories dominate revenue contribution

### 💰 Customer Spending Behavior
Customers were segmented into spending ranges:
- Under 100
- 100–199
- 200–299
- 300–499
- 500+

➡ Majority of orders fall in the **200–299 INR range**, indicating mid-price preference.

---

## 📊 Power BI Dashboards

### 📄 Page 1 – Sales Overview (Executive Summary)
- KPI Cards: Total Revenue, Total Orders, Average Rating
- Monthly & Quarterly Revenue Trends
- Revenue by City
- Revenue by Restaurant

**Purpose:** High-level performance monitoring for decision-makers

---

### 📄 Page 2 – City & Dish Performance Analysis
- Revenue & AOV by City
- Top Dishes by Revenue
- Orders & AOV by Restaurant
- Orders & Revenue by Category

**Purpose:** Deep-dive comparative analysis  
🔎 Interactive city slicers enable dynamic filtering across visuals.

---

## 🛠️ Tools & Technologies Used
- **SQL (PostgreSQL)** – Data cleaning, validation, transformation, modeling, and analysis
- **Power BI** – Interactive dashboards and data visualization
- **Star Schema Modeling** – Analytical data design
- **CSV Files** – Source data ingestion into PostgreSQL

---

## ✅ Key Outcomes
- Built a complete analytics pipeline from raw data to dashboards
- Applied advanced SQL concepts (joins, CTEs, window functions)
- Designed BI-ready data models
- Delivered actionable business insights

---

## 🎯 Role Alignment
This project is well-suited for:
- Data Analyst
- Business Intelligence Analyst
- SQL Analyst
- Power BI Developer

---

## 📌 Conclusion
This Swiggy Sales Analysis project demonstrates **industry-standard data analytics practices**, combining backend SQL engineering with frontend BI storytelling. The solution is scalable, insight-driven, and suitable for real-world business decision-making.

---

📬 *Feel free to explore the repository and dashboards. Feedback is welcome!*
