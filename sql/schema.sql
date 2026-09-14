-- create a star scheme table --
--Create Customer Dimension
CREATE TABLE dim_customer (
    customer_id VARCHAR(50) PRIMARY KEY,
    age INT,
    employment_status VARCHAR(50),
    location VARCHAR(50),
    account_tenure INT
);

--  Create Payment History Dimension
CREATE TABLE dim_payment_history (
    customer_id VARCHAR(50) REFERENCES dim_customer(customer_id),
    month_1 VARCHAR(20),
    month_2 VARCHAR(20),
    month_3 VARCHAR(20),
    month_4 VARCHAR(20),
    month_5 VARCHAR(20),
    month_6 VARCHAR(20)
);

--  Create Fact Table
CREATE TABLE fact_risk (
    customer_id VARCHAR(50) REFERENCES dim_customer(customer_id),
    income NUMERIC,
    credit_score NUMERIC,
    credit_utilization NUMERIC,
    missed_payments INT,
    delinquent_account INT,
    loan_balance NUMERIC,
    debt_to_income_ratio NUMERIC,
    risk_tier VARCHAR(20)
);

select * from fact_risk



--Create indexes on high-cardinality join/filter columns
CREATE INDEX idx_fact_risk_customer ON fact_risk(customer_id);
CREATE INDEX idx_fact_delinquent ON fact_risk(delinquent_account);
CREATE INDEX idx_cust_location ON dim_customer(location);

-- Automated Data Audit View (Flags orphaned records or invalid values)
CREATE VIEW v_data_quality_audit AS
SELECT 
    'Fact without Customer Dimension' AS Issue_Type, 
    COUNT(*) AS Flagged_Records
FROM fact_risk f
LEFT JOIN dim_customer c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 
    'Invalid Negative Income' AS Issue_Type, 
    COUNT(*)
FROM fact_risk
WHERE income < 0;

select * from v_data_quality_audit
