import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/providers/affiliation_provider.dart';
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/models/affiliation_models.dart';

class AffiliationMainScreen extends StatefulWidget {
  const AffiliationMainScreen({Key? key}) : super(key: key);

  @override
  State<AffiliationMainScreen> createState() => _AffiliationMainScreenState();
}

class _AffiliationMainScreenState extends State<AffiliationMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isInitialized) return;

    final provider = Provider.of<AffiliationProvider>(context, listen: false);
    await provider.fetchAffiliationTypes();
    await provider.fetchAffiliations();
    await provider.fetchProviders();
    
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Gestión de Afiliaciones',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Afiliaciones'),
            Tab(text: 'Proveedores'),
            Tab(text: 'Tipos'),
          ],
        ),
      ),
      body: Consumer<AffiliationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInitialData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAffiliationsTab(provider),
              _buildProvidersTab(provider),
              _buildTypesTab(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(),
        child: const Icon(Icons.add),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildAffiliationsTab(AffiliationProvider provider) {
    final affiliations = provider.affiliations;

    if (affiliations.isEmpty) {
      return const Center(
        child: Text('No hay afiliaciones registradas'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: affiliations.length,
      itemBuilder: (context, index) {
        final affiliation = affiliations[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(affiliation.employeeName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(affiliation.providerName),
                Text(affiliation.affiliationTypeName),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(affiliation.startDate),
                const SizedBox(width: 8),
                Icon(
                  affiliation.isActive ? Icons.check_circle : Icons.cancel,
                  color: affiliation.isActive ? Colors.green : Colors.red,
                ),
              ],
            ),
            onTap: () => _navigateToEdit(affiliation),
          ),
        );
      },
    );
  }

  Widget _buildProvidersTab(AffiliationProvider provider) {
    final providers = provider.providers;

    if (providers.isEmpty) {
      return const Center(
        child: Text('No hay proveedores registrados'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),      itemCount: providers.length,
      itemBuilder: (context, index) {
        final insuranceProvider = providers[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(insuranceProvider.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insuranceProvider.affiliationTypeName),
                if (insuranceProvider.nit != null) Text('NIT: ${insuranceProvider.nit}'),
              ],
            ),
            trailing: Icon(
              insuranceProvider.isActive ? Icons.check_circle : Icons.cancel,
              color: insuranceProvider.isActive ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypesTab(AffiliationProvider provider) {
    final types = provider.affiliationTypes;

    if (types.isEmpty) {
      return const Center(
        child: Text('No hay tipos de afiliación registrados'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(type.name),
            subtitle: type.description != null ? Text(type.description!) : null,
          ),
        );
      },
    );
  }

  void _navigateToCreate() {
    Navigator.pushNamed(
      context,
      RouteNames.affiliationForm,
      arguments: {'affiliation': null, 'isEditing': false},
    );
  }

  void _navigateToEdit(Affiliation affiliation) {
    Navigator.pushNamed(
      context,
      RouteNames.affiliationForm,
      arguments: {'affiliation': affiliation, 'isEditing': true},
    );
  }
}
