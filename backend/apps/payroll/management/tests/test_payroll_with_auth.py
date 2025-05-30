#!/usr/bin/env python
"""
Get fresh authentication token and test PayrollEntry creation
"""
import os
import sys
import django
import requests
import json

# Add the project directory to the Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

def get_auth_token():
    """Get fresh authentication token"""
    url = "http://localhost:8000/api/core/token/"
    data = {
        "email": "testadmin@rhplus.com",
        "password": "testpass123"
    }
    
    try:
        response = requests.post(url, json=data)
        if response.status_code == 200:
            tokens = response.json()
            print("✅ Authentication successful!")
            return tokens.get('access')
        else:
            print(f"❌ Authentication failed: {response.status_code}")
            print(f"Response: {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error getting token: {str(e)}")
        return None

def test_payroll_creation():
    """Test PayrollEntry creation endpoint with fresh token"""
    
    # Get fresh token
    token = get_auth_token()
    if not token:
        print("Cannot proceed without valid token")
        return
    
    # API endpoint
    url = "http://localhost:8000/api/payroll/entries/"
    
    # Headers with fresh authentication token
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {token}'
    }
    
    # Test data for PayrollEntry creation
    test_data = {
        "employee": 1,
        "payroll_period": 11,
        "details": [
            {
                "item_type": "earnings", 
                "payroll_item": 1, 
                "amount": "3000.00"
            },
            {
                "item_type": "deductions", 
                "payroll_item": 6, 
                "amount": "120.00"
            }
        ]
    }
    
    print("\nTesting PayrollEntry creation...")
    print(f"URL: {url}")
    print(f"Data: {json.dumps(test_data, indent=2)}")
    
    try:
        response = requests.post(url, headers=headers, json=test_data)
        
        print(f"\nResponse Status: {response.status_code}")
        
        if response.status_code == 201:
            print("✅ SUCCESS: PayrollEntry created successfully!")
            response_data = response.json()
            print(f"Created PayrollEntry ID: {response_data.get('id')}")
            print(f"Response Data: {json.dumps(response_data, indent=2)}")
        else:
            print("❌ FAILED: PayrollEntry creation failed")
            print(f"Response Text: {response.text}")
            
            # Try to parse error details
            try:
                error_data = response.json()
                print(f"Error Details: {json.dumps(error_data, indent=2)}")
            except:
                print("Could not parse error response as JSON")
                
    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Could not connect to server. Is it running on localhost:8000?")
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")

if __name__ == "__main__":
    test_payroll_creation()
