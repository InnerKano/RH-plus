#!/usr/bin/env python3
import os
import sys
import django

# Add the project root to Python path
sys.path.append('C:\\Users\\kevin\\Documents\\GitHub\\RH-plus\\backend')

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from apps.core.models import User

def main():
    print("🔍 Checking existing users...")
    
    # Check if test admin exists
    try:
        test_user = User.objects.get(email="testadmin@rhplus.com")
        print(f"✅ Test admin user found:")
        print(f"  Email: {test_user.email}")
        print(f"  Is Active: {test_user.is_active}")
        print(f"  Is Staff: {test_user.is_staff}")
        print(f"  Role: {test_user.role}")
        print(f"  Has Password: {bool(test_user.password)}")
        
        # Try to activate if not active
        if not test_user.is_active:
            test_user.is_active = True
            test_user.save()
            print("🔧 Activated test user")
            
    except User.DoesNotExist:
        print("❌ Test admin user not found, creating new one...")
        test_user = User.objects.create_user(
            email="testadmin@rhplus.com",
            password="TestPass123!",
            first_name="Test",
            last_name="Admin",
            role="SUPERUSER",
            is_active=True,
            is_staff=True,
            is_superuser=True
        )
        print(f"✅ Created test admin user: {test_user.email}")
    
    # List all users for reference
    print(f"\n👥 All users in system:")
    users = User.objects.all()
    for user in users:
        print(f"  {user.email} - {user.role} - Active: {user.is_active}")
    
    # Get PayrollItem data
    print(f"\n📋 Getting PayrollItems...")
    from apps.payroll.models import PayrollItem
    items = PayrollItem.objects.all()
    print(f"Found {items.count()} PayrollItems:")
    
    earnings = []
    deductions = []
    
    for item in items:
        print(f"  ID: {item.id} - {item.name} ({item.item_type}) - {item.calculation_type}")
        if item.item_type == 'EARNING':
            earnings.append(item)
        else:
            deductions.append(item)
    
    print(f"\n📈 Earnings ({len(earnings)}):")
    for item in earnings:
        print(f"  ID: {item.id} - {item.name}")
    
    print(f"\n📉 Deductions ({len(deductions)}):")
    for item in deductions:
        print(f"  ID: {item.id} - {item.name}")
    
    # Get Contract data
    print(f"\n💼 Getting Contracts...")
    from apps.payroll.models import Contract
    contracts = Contract.objects.all()
    print(f"Found {contracts.count()} Contracts:")
    for contract in contracts:
        print(f"  ID: {contract.id} - Employee ID: {contract.employee.id} - Salary: ${contract.salary}")

if __name__ == "__main__":
    main()
