#!/usr/bin/env python3
import requests
import json
from decimal import Decimal

# Configuration
BASE_URL = "http://localhost:8000"
LOGIN_URL = f"{BASE_URL}/api/core/token/"
CREATE_ENTRY_URL = f"{BASE_URL}/api/payroll/entries/"

# Test admin credentials
credentials = {
    "email": "testadmin@rhplus.com", 
    "password": "testpass123"
}

def main():
    print("🔐 Authenticating...")
    
    # Get access token
    response = requests.post(LOGIN_URL, json=credentials)
    
    if response.status_code == 200:
        tokens = response.json()
        access_token = tokens['access']
        headers = {'Authorization': f'Bearer {access_token}'}
        print("✅ Authentication successful!")
        
        # Create PayrollEntry with correct data structure
        print("\n📝 Creating PayrollEntry with correct data...")
        
        # Available IDs from database:
        # PayrollItems: 22-31 (22=Salario Básico, 27=Salud 4%)
        # Contracts: 7-11 (Employee IDs: 1,7,8,9,10)
        # PayrollPeriods: 11 (June 2025)
        
        payroll_data = {
            "employee": 7,  # Employee ID
            "contract": 8,  # Contract ID for Employee 7
            "period": 11,   # PayrollPeriod ID (June 2025)
            "base_salary": "1952937.00",  # Base salary from contract 8
            "details": [
                {
                    "item_type": "earnings",
                    "payroll_item": 22,  # Salario Básico
                    "amount": "1952937.00"
                },
                {
                    "item_type": "earnings", 
                    "payroll_item": 23,  # Horas Extra
                    "amount": "100000.00"
                },
                {
                    "item_type": "deductions",
                    "payroll_item": 27,  # Salud (4%)
                    "amount": "78117.48"  # 4% of base salary
                },
                {
                    "item_type": "deductions",
                    "payroll_item": 28,  # Pensión (4%)
                    "amount": "78117.48"  # 4% of base salary
                }
            ]
        }
        
        print(f"URL: {CREATE_ENTRY_URL}")
        print(f"Data: {json.dumps(payroll_data, indent=2)}")
        
        response = requests.post(CREATE_ENTRY_URL, json=payroll_data, headers=headers)
        
        print(f"Response Status: {response.status_code}")
        
        if response.status_code == 201:
            result = response.json()
            print("✅ SUCCESS: PayrollEntry created successfully!")
            print(f"Raw Response: {json.dumps(result, indent=2)}")
            
        else:
            print("❌ FAILED: PayrollEntry creation failed")
            try:
                error_data = response.json()
                print(f"Error Details: {json.dumps(error_data, indent=2)}")
            except:
                print(f"Response Text: {response.text}")
            
    else:
        print(f"❌ Authentication failed: {response.status_code}")
        print(response.text)

if __name__ == "__main__":
    main()
