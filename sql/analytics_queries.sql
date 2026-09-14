-- Queries --

-- Delinquency Rate by Employment Status
SELECT 
    c.employment_status,
    COUNT(f.customer_id) AS total_customers,
    SUM(f.delinquent_account) AS total_defaults,
    ROUND(AVG(f.delinquent_account) * 100, 2) AS default_rate_pct,
    ROUND(AVG(f.loan_balance), 2) AS avg_loan_balance
FROM fact_risk f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.employment_status
ORDER BY default_rate_pct DESC;

-- Portfolio Risk Exposure by Risk Tier
SELECT 
    risk_tier,
    COUNT(customer_id) AS total_accounts,
    ROUND(AVG(credit_utilization) * 100, 2) AS avg_utilization_pct,
    SUM(loan_balance) AS total_portfolio_exposure
FROM fact_risk
GROUP BY risk_tier
ORDER BY total_portfolio_exposure DESC;

-- Top 3 Highest Loan Balances per Location 
WITH RankedLoans AS (
    SELECT 
        c.location,
        f.customer_id,
        f.loan_balance,
        f.risk_tier,
        RANK() OVER(PARTITION BY c.location ORDER BY f.loan_balance DESC) as rank
    FROM fact_risk f
    JOIN dim_customer c ON f.customer_id = c.customer_id
)
SELECT * 
FROM RankedLoans 
WHERE rank <= 3
Order by rank;
