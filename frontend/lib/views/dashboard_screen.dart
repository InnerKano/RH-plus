import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    print('DashboardScreen: Initializing...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('DashboardScreen: Loading user permissions...');
      authProvider.loadUserPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('DashboardScreen: Building dashboard...');
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.dashboard,
          style: TextStyle(
            color: AppColors.onPrimaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final roleDisplay = authProvider.userPermissions?.roleDisplay ?? 'Usuario';
              print('DashboardScreen: Displaying role: $roleDisplay');
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      roleDisplay,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, RouteNames.login);
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final permissions = authProvider.userPermissions;
          
          print('DashboardScreen: User permissions: $permissions');
          
          if (permissions == null) {
            print('DashboardScreen: Permissions are null, showing loading...');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Cargando permisos...',
                    style: TextStyle(color: AppColors.greyDark),
                  ),
                ],
              ),
            );
          }

          print('DashboardScreen: Permissions loaded, building content...');
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido, ${authProvider.user?.firstName ?? 'Usuario'}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rol: ${permissions.roleDisplay}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Módulos accesibles: ${permissions.accessibleModules.length}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.greyDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Modules section
                Text(
                  'Módulos Disponibles',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Show available modules info
                if (permissions.accessibleModules.isEmpty)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: AppColors.greyDark,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes acceso a ningún módulo',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.greyDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Contacta al administrador para asignar permisos',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.greyDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: _buildModuleCards(context, permissions),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildModuleCards(BuildContext context, UserPermissions permissions) {
    print('DashboardScreen: Building module cards for permissions: ${permissions.accessibleModules}');
    final List<Widget> cards = [];
    
    // User Management - only for users who can manage others
    if (permissions.canManageUsers) {
      print('DashboardScreen: Adding User Management card');
      cards.add(_buildModuleCard(
        context,
        'Gestión de Usuarios',
        Icons.people_outline,
        AppColors.secondaryColor,
        () => Navigator.pushNamed(context, RouteNames.userManagement),
      ));
    }
    
    // Selection module
    if (permissions.canAccessModule('selection')) {
      print('DashboardScreen: Adding Selection card');
      cards.add(_buildModuleCard(
        context,
        'Selección',
        Icons.person_search_outlined,
        AppColors.infoColor,
        () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Módulo de Selección - En desarrollo'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ));
    }
    
    // Affiliation module
    if (permissions.canAccessModule('affiliation')) {
      print('DashboardScreen: Adding Affiliation card');
      cards.add(_buildModuleCard(
        context,
        'Afiliaciones',
        Icons.card_membership_outlined,
        AppColors.successColor,
        () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Módulo de Afiliaciones - En desarrollo'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ));
    }
    
    // Payroll module
    if (permissions.canAccessModule('payroll')) {
      print('DashboardScreen: Adding Payroll card');
      cards.add(_buildModuleCard(
        context,
        'Nómina',
        Icons.payments_outlined,
        AppColors.warningColor,
        () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Módulo de Nómina - En desarrollo'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ));
    }
    
    // Performance module
    if (permissions.canAccessModule('performance')) {
      print('DashboardScreen: Adding Performance card');
      cards.add(_buildModuleCard(
        context,
        'Desempeño',
        Icons.trending_up_outlined,
        AppColors.errorColor,
        () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Módulo de Desempeño - En desarrollo'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ));
    }
    
    // Training module
    if (permissions.canAccessModule('training')) {
      print('DashboardScreen: Adding Training card');
      cards.add(_buildModuleCard(
        context,
        'Capacitación',
        Icons.school_outlined,
        AppColors.primaryColor,
        () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Módulo de Capacitación - En desarrollo'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ));
    }
    
    print('DashboardScreen: Total cards built: ${cards.length}');
    return cards;
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
