# Customer Deposit Behavior and Engagement Analysis

This project analyzes customer deposit behaviors, transaction frequency, plan inactivity, and estimated customer lifetime value (CLV) using SQL queries executed over a fintech-style relational database.

## Table of Contents
- [Overview](#overview)
- [Question-by-Question Explanation](#question-by-question-explanation)
- [Challenges and Resolutions](#challenges-and-resolutions)
- [Conclusion](#conclusion)

## Overview

The analysis addresses four business-driven questions related to customer savings and investment behavior. Each query was crafted using well-structured CTEs and filtering logic to extract insights around engagement, cross-product usage, and profitability.

All monetary values (e.g., `confirmed_amount`) in the database are recorded in **kobo** and were converted to **naira** by dividing by 100 for reporting and calculations.

## Question-by-Question Explanation

### 1. High-Value Customers with Multiple Products

This query identifies users who have funded both a **savings plan** and an **investment plan**. Plan types were determined using:
- `is_regular_savings = 1` for savings
- `is_a_fund = 1` for investments

Only successful transactions (`transaction_status = 'success'` and `confirmed_amount > 0`) were counted. Users were filtered to include only those who have at least one of each product type.

**Key Metrics**:
- Number of distinct funded savings and investment plans per user
- Total deposit amount (in naira)
- Ordered list of customers by total deposit value

---

### 2. Transaction Frequency Analysis

This query segments users based on how frequently they transact. It:
- Computes the number of transactions per user
- Calculates active months from the first to last transaction
- Derives average transactions per month
- Classifies users into frequency bands

**Classification Criteria**:
- High Frequency (≥ 10 transactions/month)
- Medium Frequency (3–9.99 transactions/month)
- Low Frequency (< 3 transactions/month)

---

### 3. Account Inactivity Alert

This analysis identifies **active plans** that have not received a deposit in over one year. It:
- Finds the latest inflow (`confirmed_amount > 0`) for each plan
- Uses `DATEDIFF(CURDATE(), last_transaction_date)` to measure inactivity
- Categorizes the plan as either 'Savings' or 'Investment' using:
  - `is_regular_savings = 1` → 'Savings'
  - `is_a_fund = 1` → 'Investment'

**Output Includes**:
- Plan ID, Owner ID
- Plan type (Savings/Investment)
- Last inflow date
- Inactivity duration in days

---

### 4. Customer Lifetime Value (CLV) Estimation

CLV is estimated based on customer tenure and transaction count. Tenure is calculated from the signup (`date_joined`) to the current date.

**CLV Formula**:
\[
\text{CLV} = \left( \frac{\text{Total Transactions}}{\text{Tenure in Months}} \right) \times 12 \times 0.001
\]

**Metrics Displayed**:
- Account tenure (in months)
- Total successful deposit transactions
- Estimated CLV (in naira, rounded to 2 decimal places)

---

## Challenges and Resolutions

### 1. Accurately Defining Plan Types
The dataset did not use traditional `plan_type_id` labels. Instead, boolean fields `is_regular_savings` and `is_a_fund` were used to classify plans correctly.

### 2. Currency Normalization
All monetary fields were stored in **kobo**. Values were converted to naira using division by 100 for readability and financial accuracy.

### 3. Avoiding Divide-by-Zero in CLV and Frequency Calculations
Used `GREATEST(..., 1)` to ensure no division by zero when calculating averages with short tenure or transaction periods.

### 4. Null Handling in Joins
Used `LEFT JOIN` and `IFNULL` to ensure users with no transactions were still considered in the CLV output with appropriate defaults.

---

## Conclusion

These SQL-based analyses provide actionable insights for customer segmentation, product performance, and long-term value estimation. The approach is optimized for clarity, maintainability, and extensibility across other verticals such as churn prediction or revenue modeling.