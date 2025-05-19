-- 1. High-Value Customers with Multiple Products

-- Step 1: Get total inflow per user and plan, tagging savings vs investment
WITH funded_plans AS (
    SELECT
        s.owner_id,                             -- Customer/user ID
        s.plan_id,                              -- Specific plan funded
        p.is_regular_savings,                   -- Flag for savings
        p.is_a_fund,                            -- Flag for investment
        SUM(CAST(s.confirmed_amount AS DECIMAL(18,2)))/100 AS total_deposit  -- Total deposit per plan (convert from kobo to Naira)
    FROM savings_savingsaccount s
    JOIN plans_plan p ON s.plan_id = p.id
    WHERE
        s.transaction_status = 'success'									-- Only successful transactions
        AND s.confirmed_amount > 0											-- Only actual deposits
    GROUP BY s.owner_id, s.plan_id, p.is_regular_savings, p.is_a_fund
),

-- Step 2: Aggregate funded savings plans
savings_customers AS (
    SELECT
        owner_id,
        COUNT(DISTINCT plan_id) AS savings_count,							-- Count of funded savings plans
        SUM(total_deposit) AS savings_total
    FROM funded_plans
    WHERE is_regular_savings = 1  -- Flag indicates savings
    GROUP BY owner_id
),

-- Step 3: Aggregate funded investment plans
investment_customers AS (
    SELECT
        owner_id,
        COUNT(DISTINCT plan_id) AS investment_count,						-- Count of funded investment plans
        SUM(total_deposit) AS investment_total
    FROM funded_plans
    WHERE is_a_fund = 1           -- Flag indicates investment
    GROUP BY owner_id
)

-- Step 4: Combine users who have BOTH savings and investment
SELECT
    u.id AS owner_id,
    u.name,
    s.savings_count,
    i.investment_count,
    ROUND(s.savings_total + i.investment_total, 2) AS total_deposits
FROM users_customuser u
JOIN savings_customers s ON u.id = s.owner_id
JOIN investment_customers i ON u.id = i.owner_id
ORDER BY total_deposits DESC;
