-- 4. Customer Lifetime Value (CLV) Estimation
-- CLV Formula: (total_transactions / tenure_months) * 12 * 0.001
-- Assumes profit per transaction is 0.1% (i.e., multiplier = 0.001)

-- Step 1: Aggregate total number of successful inflow transactions for each customer
WITH customer_txns AS (
    SELECT 
        sa.owner_id,                                     -- Foreign key to users_customuser.id
        COUNT(*) AS total_transactions                   -- Number of successful deposit transactions
    FROM savings_savingsaccount sa
    WHERE 
        sa.transaction_status = 'success'                -- Only consider successful inflows
        AND sa.confirmed_amount > 0                      -- Only actual deposits
    GROUP BY sa.owner_id
),

-- Step 2: Calculate how long each customer has been active (in months)
customer_tenure AS (
    SELECT 
        u.id AS customer_id,                             -- Primary key of user
        u.name,                                          -- Full name of user
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months  -- Duration of activity since signup
    FROM users_customuser u
),

-- Step 3: Estimate CLV using frequency and tenure
clv_calc AS (
    SELECT 
        ct.customer_id,
        ct.name,
        ct.tenure_months,
        IFNULL(tx.total_transactions, 0) AS total_transactions,          -- Fill in 0 if no transactions
        ROUND(
            (IFNULL(tx.total_transactions, 0) / GREATEST(ct.tenure_months, 1))  -- Avoid division by zero
            * 12 * 0.001,                                                -- Normalize to annual rate and apply profit factor
            2
        ) AS estimated_clv                                               -- Final Customer Lifetime Value
    FROM customer_tenure ct
    LEFT JOIN customer_txns tx ON ct.customer_id = tx.owner_id          -- Include users with zero transactions
)

-- Step 4: Return the CLV result set, sorted by value
SELECT * 
FROM clv_calc
ORDER BY estimated_clv DESC;                                            -- Show customers with highest projected value first
