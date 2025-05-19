-- 3. Account Inactivity Alert (Updated with Correct Plan Flags)

-- Step 1: Get the most recent successful inflow per plan
WITH last_inflow_txns AS (
    SELECT
        s.plan_id,
        MAX(s.created_on) AS last_transaction_date  -- Latest deposit date for each plan
    FROM savings_savingsaccount s
    WHERE
        s.transaction_status = 'success' 
        AND s.confirmed_amount > 0                  -- Only actual deposits
    GROUP BY s.plan_id
)

-- Step 2: Identify inactive plans and label them properly
SELECT
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,                                      -- Plan category based on flags
    lt.last_transaction_date,
    DATEDIFF(CURDATE(), lt.last_transaction_date) AS inactivity_days  -- Days since last inflow
FROM plans_plan p
JOIN last_inflow_txns lt ON p.id = lt.plan_id         -- Only plans with inflows
WHERE
    p.is_deleted = 0                                   -- Active plans only
    AND DATEDIFF(CURDATE(), lt.last_transaction_date) > 365  -- Inactive for more than a year
ORDER BY inactivity_days DESC;
