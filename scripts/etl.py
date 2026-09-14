import os
import pandas as pd
import numpy as np

def clean_data(file_path):
    df = pd.read_csv(file_path)
    
    # Drop empty/junk columns
    junk_cols = [col for col in df.columns if 'Unnamed' in col]
    df.drop(columns=junk_cols, inplace=True)
    
    # Impute missing values
    df['Income'] = df['Income'].fillna(df.groupby('Employment_Status')['Income'].transform('median'))
    df['Credit_Score'] = df['Credit_Score'].fillna(df['Credit_Score'].median())
    df['Loan_Balance'] = df['Loan_Balance'].fillna(0)
    
    # Feature Engineering
    df['Risk_Tier'] = pd.cut(
        df['Credit_Score'], 
        bins=[0, 580, 670, 740, 850], 
        labels=['Poor', 'Fair', 'Good', 'Excellent']
    )
    
    return df

def create_star_schema(df):
    # Dim Customer
    dim_customer = df[['Customer_ID', 'Age', 'Employment_Status', 'Location', 'Account_Tenure']].copy()
    
    # Dim Payment History
    dim_payment = df[['Customer_ID', 'Month_1', 'Month_2', 'Month_3', 'Month_4', 'Month_5', 'Month_6']].copy()
    
    # Fact Customer Risk
    fact_risk = df[['Customer_ID', 'Income', 'Credit_Score', 'Credit_Utilization', 
                    'Missed_Payments', 'Delinquent_Account', 'Loan_Balance', 
                    'Debt_to_Income_Ratio', 'Risk_Tier']].copy()
                    
    return dim_customer, dim_payment, fact_risk

if __name__ == "__main__":
    
    os.makedirs('data\processed', exist_ok=True)

    df_clean = clean_data('C:\Divyesh_Projects\Data Analyst Project\Delinquency_prediction_dataset.csv')
    dim_cust, dim_pay, fact_risk = create_star_schema(df_clean)
    
    dim_cust.to_csv('data\processed\dim_customer.csv', index=False)
    dim_pay.to_csv('data\processed\dim_payment_history.csv', index=False)
    fact_risk.to_csv('data\\processed\\fact_customer_risk.csv', index=False)
    print("ETL pipeline executed successfully!")