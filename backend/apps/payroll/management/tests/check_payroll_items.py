#!/usr/bin/env python3
import requests
import json

# Configuration
BASE_URL = "http://localhost:8000"
LOGIN_URL = f"{BASE_URL}/api/core/token/"
ITEMS_URL = f"{BASE_URL}/api/payroll/items/"
CONTRACTS_URL = f"{BASE_URL}/api/payroll/contracts/"
EMPLOYEES_URL = f"{BASE_URL}/api/affiliation/employees/"

# Test admin credentials
credentials = {
    "email": "testadmin@rhplus.com",
    "password": "TestPass123!"
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
        print(f"Token: {access_token}")
        
        # Get PayrollItems
        print("\n📋 Getting PayrollItems...")
        items_response = requests.get(ITEMS_URL, headers=headers)
        
        if items_response.status_code == 200:
            items = items_response.json()
            print(f"✅ Found {len(items)} PayrollItems:")
            earnings = []
            deductions = []
            
            for item in items:
                print(f"  ID: {item['id']} - {item['name']} ({item['item_type']}) - {item['calculation_type']}")
                if item['item_type'] == 'EARNING':
                    earnings.append(item)
                else:
                    deductions.append(item)
            
            print(f"\n📈 Earnings ({len(earnings)}):")
            for item in earnings:
                print(f"  ID: {item['id']} - {item['name']}")
            
            print(f"\n📉 Deductions ({len(deductions)}):")
            for item in deductions:
                print(f"  ID: {item['id']} - {item['name']}")
                
        else:
            print(f"❌ Failed to get PayrollItems: {items_response.status_code}")
            print(items_response.text)
        
        # Get Contracts to understand the data structure
        print("\n💼 Getting Contracts...")
        contracts_response = requests.get(CONTRACTS_URL, headers=headers)
        
        if contracts_response.status_code == 200:
            contracts = contracts_response.json()
            print(f"✅ Found {len(contracts)} Contracts:")
            for contract in contracts:
                print(f"  ID: {contract['id']} - Employee ID: {contract['employee']} - Salary: ${contract['salary']}")
        else:
            print(f"❌ Failed to get Contracts: {contracts_response.status_code}")
            print(contracts_response.text)
        
        # Get Employees 
        print("\n👥 Getting Employees...")
        employees_response = requests.get(EMPLOYEES_URL, headers=headers)
        
        if employees_response.status_code == 200:
            employees = employees_response.json()
            print(f"✅ Found {len(employees)} Employees:")
            for employee in employees:
                print(f"  ID: {employee['id']} - {employee['first_name']} {employee['last_name']}")
        else:
            print(f"❌ Failed to get Employees: {employees_response.status_code}")
            print(employees_response.text)
            
    else:
        print(f"❌ Authentication failed: {response.status_code}")
        print(response.text)

if __name__ == "__main__":
    main()
