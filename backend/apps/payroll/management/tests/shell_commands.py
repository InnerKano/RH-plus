from apps.core.models import User
from apps.payroll.models import PayrollItem, Contract

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
items = PayrollItem.objects.all()
print(f"Found {items.count()} PayrollItems:")

earnings = []
deductions = []

for item in items:
    print(f"  ID: {item.id} - {item.name} ({item.item_type})")
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
contracts = Contract.objects.all()
print(f"Found {contracts.count()} Contracts:")
for contract in contracts:
    print(f"  ID: {contract.id} - Employee ID: {contract.employee.id} - Salary: ${contract.salary}")
