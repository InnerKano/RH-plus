from apps.core.models import User

# Check and reactivate test user
try:
    test_user = User.objects.get(email="testadmin@rhplus.com")
    print(f"Current status - Active: {test_user.is_active}, Staff: {test_user.is_staff}")
    
    # Ensure user is properly activated
    test_user.is_active = True
    test_user.is_staff = True
    test_user.is_superuser = True
    test_user.save()
    
    print(f"Updated status - Active: {test_user.is_active}, Staff: {test_user.is_staff}")
    print("✅ Test user activated successfully")
    
except User.DoesNotExist:
    print("❌ Test user not found")
