#!/usr/bin/env python3
import requests
import json

# Configuration
BASE_URL = "http://localhost:8000"
LOGIN_URL = f"{BASE_URL}/api/core/token/"

# Test admin credentials
credentials = {
    "email": "testadmin@rhplus.com", 
    "password": "testpass123"
}

def get_auth_headers():
    """Get authentication headers"""
    response = requests.post(LOGIN_URL, json=credentials)
    if response.status_code == 200:
        tokens = response.json()
        return {'Authorization': f'Bearer {tokens["access"]}'}
    return None

def test_complete_workflow():
    """Test complete payroll workflow"""
    headers = get_auth_headers()
    if not headers:
        print("❌ Authentication failed")
        return
    
    print("🔐 Authentication successful!")
    
    # 1. Get the newly created PayrollEntry
    print("\n📊 1. Testing PayrollEntry retrieval...")
    entries_response = requests.get(f"{BASE_URL}/api/payroll/entries/", headers=headers)
    
    if entries_response.status_code == 200:
        entries = entries_response.json()
        print(f"✅ Retrieved {len(entries)} PayrollEntries")
        
        # Find our new entry (ID 11)
        new_entry = None
        for entry in entries:
            if entry['id'] == 11:
                new_entry = entry
                break
        
        if new_entry:
            print(f"📋 Found new entry (ID {new_entry['id']}):")
            print(f"  Employee: {new_entry.get('employee_name', 'N/A')}")
            print(f"  Base Salary: ${new_entry['base_salary']}")
            print(f"  Total Earnings: ${new_entry.get('total_earnings', 'N/A')}")
            print(f"  Total Deductions: ${new_entry.get('total_deductions', 'N/A')}")
            print(f"  Net Pay: ${new_entry.get('net_pay', 'N/A')}")
            print(f"  Status: {new_entry.get('status', 'N/A')}")
            
    # 2. Test PayrollEntry approval
    print("\n✅ 2. Testing PayrollEntry approval...")
    approve_response = requests.post(f"{BASE_URL}/api/payroll/entries/11/approve/", headers=headers)
    
    if approve_response.status_code == 200:
        approved_entry = approve_response.json()
        print(f"✅ PayrollEntry 11 approved successfully!")
        print(f"Status: {approved_entry.get('status', 'N/A')}")
        print(f"Approved by: {approved_entry.get('approved_by_name', 'N/A')}")
        print(f"Approved at: {approved_entry.get('approved_at', 'N/A')}")
    else:
        print(f"❌ Approval failed: {approve_response.status_code}")
        print(approve_response.text)
    
    # 3. Test another PayrollEntry creation (different contract)
    print("\n📝 3. Testing second PayrollEntry creation...")
    payroll_data = {
        "employee": 8,  # Employee ID
        "contract": 9,  # Contract ID for Employee 8
        "period": 11,   # PayrollPeriod ID (June 2025)
        "base_salary": "3351394.00",  # Base salary from contract 9
        "details": [
            {
                "item_type": "earnings",
                "payroll_item": 22,  # Salario Básico
                "amount": "3351394.00"
            },
            {
                "item_type": "earnings", 
                "payroll_item": 24,  # Bonificación
                "amount": "200000.00"
            },
            {
                "item_type": "deductions",
                "payroll_item": 27,  # Salud (4%)
                "amount": "134055.76"  # 4% of base salary
            },
            {
                "item_type": "deductions",
                "payroll_item": 28,  # Pensión (4%)
                "amount": "134055.76"  # 4% of base salary
            }
        ]
    }
    
    create_response = requests.post(f"{BASE_URL}/api/payroll/entries/", json=payroll_data, headers=headers)
    
    if create_response.status_code == 201:
        new_entry = create_response.json()
        print(f"✅ Second PayrollEntry created successfully! ID: {new_entry['id']}")
        print(f"Base Salary: ${new_entry['base_salary']}")
        print(f"Details count: {len(new_entry['details'])}")
    else:
        print(f"❌ Second creation failed: {create_response.status_code}")
        print(create_response.text)
    
    # 4. Get summary statistics
    print("\n📈 4. Payroll summary statistics:")
    final_entries_response = requests.get(f"{BASE_URL}/api/payroll/entries/", headers=headers)
    
    if final_entries_response.status_code == 200:
        all_entries = final_entries_response.json()
        print(f"Total PayrollEntries: {len(all_entries)}")
        
        total_base_salary = sum(float(entry['base_salary']) for entry in all_entries)
        print(f"Total Base Salary: ${total_base_salary:,.2f}")
        
        pending_count = sum(1 for entry in all_entries if entry.get('status') == 'pending')
        approved_count = sum(1 for entry in all_entries if entry.get('status') == 'approved')
        
        print(f"Pending entries: {pending_count}")
        print(f"Approved entries: {approved_count}")

if __name__ == "__main__":
    test_complete_workflow()
