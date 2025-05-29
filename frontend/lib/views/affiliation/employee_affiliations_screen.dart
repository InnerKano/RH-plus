import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/models/affiliation_models.dart';
import 'package:rh_plus/providers/affiliation_provider.dart';
import 'package:rh_plus/utils/constants.dart';

class EmployeeAffiliationsScreen extends StatefulWidget {
  final int employeeId;
  final String employeeName;

  const EmployeeAffiliationsScreen({
    Key? key,
    required this.employeeId,
    required this.employeeName,
  }) : super(key: key);

  @override
  State<EmployeeAffiliationsScreen> createState() => _EmployeeAffiliationsScreenState();
}

class _EmployeeAffiliationsScreenState extends State<EmployeeAffiliationsScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAffiliations();
    });
  }

  Future<void> _loadAffiliations() async {
    if (_isInitialized) return;

    final provider = Provider.of<AffiliationProvider>(context, listen: false);
    await provider.fetchAffiliations(employeeId: widget.employeeId);
    
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Afiliaciones - ${widget.employeeName}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
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
                    onPressed: _loadAffiliations,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final affiliations = provider.affiliations;
          if (affiliations.isEmpty) {
            return const Center(
              child: Text('No hay afiliaciones registradas para este empleado'),
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
                child: ExpansionTile(
                  title: Text(affiliation.affiliationTypeName),
                  subtitle: Text(affiliation.providerName),
                  trailing: Icon(
                    affiliation.isActive ? Icons.check_circle : Icons.cancel,
                    color: affiliation.isActive ? Colors.green : Colors.red,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (affiliation.affiliationNumber != null)
                            ListTile(
                              title: const Text('Número de Afiliación'),
                              subtitle: Text(affiliation.affiliationNumber!),
                              dense: true,
                            ),
                          ListTile(
                            title: const Text('Fecha de Inicio'),
                            subtitle: Text(affiliation.startDate),
                            dense: true,
                          ),
                          if (affiliation.endDate != null)
                            ListTile(
                              title: const Text('Fecha de Fin'),
                              subtitle: Text(affiliation.endDate!),
                              dense: true,
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _navigateToEdit(affiliation),
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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

  void _navigateToCreate() {
    Navigator.pushNamed(
      context,
      RouteNames.affiliationForm,
      arguments: {
        'affiliation': null,
        'employeeId': widget.employeeId,
        'isEditing': false,
      },
    );
  }

  void _navigateToEdit(Affiliation affiliation) {
    Navigator.pushNamed(
      context,
      RouteNames.affiliationForm,
      arguments: {
        'affiliation': affiliation,
        'employeeId': widget.employeeId,
        'isEditing': true,
      },
    );
  }
}
