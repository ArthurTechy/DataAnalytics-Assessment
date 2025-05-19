-- 2. Transaction Frequency Analysis

-- Step 1: Aggregate total transactions and transaction window (min and max month) for each user
WITH transaction_counts AS (
    SELECT 
        sa.owner_id,                                           -- Unique customer ID
        COUNT(*) AS total_transactions,                        -- Total transactions by the customer
        DATE_FORMAT(MIN(sa.created_on), '%Y-%m-01') AS first_month, -- First transaction date normalized to month start
        DATE_FORMAT(MAX(sa.created_on), '%Y-%m-01') AS last_month   -- Most recent transaction date normalized
    FROM savings_savingsaccount sa
    GROUP BY sa.owner_id
),

-- Step 2: Compute active months and average monthly transaction frequency
monthly_avg AS (
    SELECT 
        tc.owner_id,
        tc.total_transactions,
        GREATEST(
            PERIOD_DIFF(DATE_FORMAT(tc.last_month, '%Y%m'), DATE_FORMAT(tc.first_month, '%Y%m')) + 1,
            1  -- Prevent division by zero if all transactions occur in the same month
        ) AS active_months,
        ROUND(
            tc.total_transactions / GREATEST(
                PERIOD_DIFF(DATE_FORMAT(tc.last_month, '%Y%m'), DATE_FORMAT(tc.first_month, '%Y%m')) + 1,
                1
            ),
            2
        ) AS avg_txn_per_month
    FROM transaction_counts tc
),

-- Step 3: Categorize users based on their average monthly frequency
categorized_users AS (
    SELECT 
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month BETWEEN 3 AND 9.99 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_txn_per_month
    FROM monthly_avg
)

-- Step 4: Aggregate counts and average frequency per category
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,                                 -- How many customers fall into each group
    ROUND(AVG(avg_txn_per_month), 2) AS avg_transactions_per_month
FROM categorized_users
GROUP BY frequency_category
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency'); -- Custom display order
