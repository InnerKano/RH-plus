import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/models/affiliation_models.dart';
import 'package:rh_plus/models/user_model.dart';
import 'package:rh_plus/providers/affiliation_provider.dart';
import 'package:rh_plus/utils/constants.dart';

class AffiliationFormScreen extends StatefulWidget {
  final Affiliation? affiliation;
  final bool isEditing;

  const AffiliationFormScreen({
    Key? key,
    this.affiliation,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<AffiliationFormScreen> createState() => _AffiliationFormScreenState();
}

class _AffiliationFormScreenState extends State<AffiliationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _affiliationNumberController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  User? _selectedUser;
  int? _selectedType;
  int? _selectedInsuranceProvider;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _affiliationNumberController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();

    if (widget.isEditing && widget.affiliation != null) {
      _populateForm();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _affiliationNumberController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final affiliation = widget.affiliation!;
    _affiliationNumberController.text = affiliation.affiliationNumber ?? '';
    _startDateController.text = affiliation.startDate;
    _endDateController.text = affiliation.endDate ?? '';
    _selectedInsuranceProvider = affiliation.provider;
    _isActive = affiliation.isActive;
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<AffiliationProvider>(context, listen: false);
      await provider.fetchEmployeeUsers();
      await provider.fetchAffiliationTypes();
      await provider.fetchProviders();

      if (widget.isEditing && widget.affiliation != null) {
        // Find the user by ID when editing
        final employeeId = widget.affiliation!.employee.toString();
        final user = provider.employeeUsers.firstWhere(
          (user) => user.id == employeeId,
          orElse: () => User(
            id: '-1',
            email: '',
            firstName: '',
            lastName: '',
            role: 'EMPLOYEE',
            roleDisplay: 'Empleado',
            isActive: true,
            dateJoined: DateTime.now(),
          ),
        );
        if (user.id != '-1') {
          setState(() => _selectedUser = user);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar Afiliación' : 'Nueva Afiliación',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEmployeeSection(),
                    const SizedBox(height: 24),
                    _buildAffiliationSection(),
                    const SizedBox(height: 24),
                    _buildDateSection(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmployeeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Empleado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<AffiliationProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<String>(
                  value: _selectedUser?.id,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar Empleado',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.employeeUsers.map((user) {
                    return DropdownMenuItem<String>(
                      value: user.id,
                      child: Text(
                          '${user.firstName} ${user.lastName} - ${user.email}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final user = provider.employeeUsers.firstWhere(
                        (u) => u.id == value,
                        orElse: () => User(
                          id: '-1',
                          email: '',
                          firstName: '',
                          lastName: '',
                          role: 'EMPLOYEE',
                          roleDisplay: 'Empleado',
                          isActive: true,
                          dateJoined: DateTime.now(),
                        ),
                      );
                      if (user.id != '-1') {
                        setState(() => _selectedUser = user);
                      }
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione un empleado';
                    }
                    return null;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAffiliationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles de Afiliación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<AffiliationProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Afiliación',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedType,
                      items: provider.affiliationTypes.map((type) {
                        return DropdownMenuItem(
                          value: type.id,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                          _selectedInsuranceProvider = null;
                        });
                        if (value != null) {
                          provider.fetchProviders(typeId: value);
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor seleccione un tipo de afiliación';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Proveedor',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedInsuranceProvider,
                      items: _selectedType == null
                          ? []
                          : provider.getProvidersByType(_selectedType!).map((prov) {
                              return DropdownMenuItem(
                                value: prov.id,
                                child: Text(prov.name),
                              );
                            }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedInsuranceProvider = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor seleccione un proveedor';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _affiliationNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Número de Afiliación',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fechas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'Fecha de Inicio',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _startDateController),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor seleccione una fecha de inicio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _endDateController,
              decoration: const InputDecoration(
                labelText: 'Fecha de Fin (Opcional)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _endDateController),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Activa'),
              value: _isActive,
              onChanged: (bool value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.primaryColor),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(widget.isEditing ? 'Actualizar' : 'Guardar'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      controller.text = formattedDate;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AffiliationProvider>(context, listen: false);      final affiliationData = {
        'employee': int.parse(_selectedUser?.id ?? '0'),
        'provider': _selectedInsuranceProvider,
        'affiliation_number': _affiliationNumberController.text,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text.isNotEmpty ? _endDateController.text : null,
        'is_active': _isActive,
      };

      if (widget.isEditing && widget.affiliation != null) {
        await provider.updateAffiliation(widget.affiliation!.id, affiliationData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Afiliación actualizada exitosamente')),
          );
        }
      } else {
        await provider.createAffiliation(affiliationData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Afiliación creada exitosamente')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la afiliación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
