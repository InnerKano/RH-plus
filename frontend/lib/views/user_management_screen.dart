import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_management_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.canManageUsers) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.unauthorizedAccess)),
        );
        return;
      }
      
      final userProvider = Provider.of<UserManagementProvider>(context, listen: false);
      userProvider.setToken(authProvider.token);
      userProvider.loadUsers();
      userProvider.loadAvailableRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.userManagement),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<UserManagementProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.users.isEmpty) {
            return const Center(
              child: Text('No hay usuarios para mostrar'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userProvider.users.length,
            itemBuilder: (context, index) {
              final user = userProvider.users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('${user.firstName} ${user.lastName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      Text(
                        'Rol: ${user.roleDisplay}',
                        style: TextStyle(
                          color: _getRoleColor(user.role),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.department != null)
                        Text('Depto: ${user.department}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showUpdateRoleDialog(context, user, userProvider),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case UserRoles.superuser:
        return Colors.red;
      case UserRoles.admin:
        return Colors.purple;
      case UserRoles.hrManager:
        return Colors.blue;
      case UserRoles.supervisor:
        return Colors.green;
      case UserRoles.employee:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showUpdateRoleDialog(BuildContext context, User user, UserManagementProvider userProvider) {
    String selectedRole = user.role;
    String? selectedDepartment = user.department;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${AppStrings.updateRole} - ${user.firstName} ${user.lastName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: AppStrings.role,
                      border: OutlineInputBorder(),
                    ),
                    items: userProvider.availableRoles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role['code'],
                        child: Text(role['name']!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedRole = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedRole == UserRoles.supervisor || selectedRole == UserRoles.employee)
                    TextFormField(
                      initialValue: selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: AppStrings.department,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        selectedDepartment = value.isEmpty ? null : value;
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await userProvider.updateUserRole(
                      user.id,
                      selectedRole,
                      selectedDepartment,
                      null, // managerId - could be implemented later
                    );
                    
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message']),
                        backgroundColor: result['success'] ? Colors.green : Colors.red,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
