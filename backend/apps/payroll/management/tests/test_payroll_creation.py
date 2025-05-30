#!/usr/bin/env python
"""
Test script for PayrollEntry creation endpoint
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

def test_payroll_creation():
    """Test PayrollEntry creation endpoint"""
    
    # API endpoint
    url = "http://localhost:8000/api/payroll/entries/"
    
    # Headers with authentication token
    headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzM1NTU0MDUzLCJpYXQiOjE3MzU1NTA0NTMsImp0aSI6ImM0YTMxODkzMzY5OTQ1M2U4YzBlYjM1YjY4ZDk3YTgwIiwidXNlcl9pZCI6MX0.3j3QWu7p1mf_lEIJi7cWiZA7c6fRkEQI8_s4jUNxr-k'
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
    
    print("Testing PayrollEntry creation...")
    print(f"URL: {url}")
    print(f"Data: {json.dumps(test_data, indent=2)}")
    
    try:
        response = requests.post(url, headers=headers, json=test_data)
        
        print(f"\nResponse Status: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        
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
