import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/providers/payroll_provider.dart';
import 'package:rh_plus/providers/employee_provider.dart';
import 'package:rh_plus/models/payroll_models.dart';
import 'package:intl/intl.dart';

class ContractsManagementScreen extends StatefulWidget {
  const ContractsManagementScreen({Key? key}) : super(key: key);

  @override
  State<ContractsManagementScreen> createState() => _ContractsManagementScreenState();
}

class _ContractsManagementScreenState extends State<ContractsManagementScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }

  Future<void> _loadData() async {
    final payrollProvider = Provider.of<PayrollProvider>(context, listen: false);
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    
    try {
      await Future.wait([
        payrollProvider.fetchContracts(),
        employeeProvider.fetchEmployees(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Contratos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to contract form
              _showContractForm();
            },
          ),
        ],
      ),
      body: Consumer<PayrollProvider>(
        builder: (context, payrollProvider, child) {
          if (payrollProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (payrollProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${payrollProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (payrollProvider.contracts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay contratos registrados'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: payrollProvider.contracts.length,
            itemBuilder: (context, index) {
              final contract = payrollProvider.contracts[index];
              return _buildContractCard(contract);
            },
          );
        },
      ),
    );
  }

  Widget _buildContractCard(ContractModel contract) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: contract.isActive ? Colors.green : Colors.grey,
          child: Icon(
            contract.isActive ? Icons.check : Icons.pause,
            color: Colors.white,
          ),
        ),
        title: Text(
          contract.employeeName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${contract.position} - ${contract.department}'),
            Text(
              'Salario: ${currencyFormat.format(contract.salary)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            contract.isActive ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: contract.isActive ? Colors.white : Colors.black87,
              fontSize: 12,
            ),
          ),
          backgroundColor: contract.isActive ? Colors.green : Colors.grey.shade300,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Tipo de Contrato:', contract.contractType),
                _buildDetailRow('Jornada Laboral:', contract.workSchedule),
                _buildDetailRow('Fecha Inicio:', contract.startDate),
                if (contract.endDate != null)
                  _buildDetailRow('Fecha Fin:', contract.endDate!),
                _buildDetailRow('Moneda:', contract.currency),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showContractForm(contract: contract),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showContractDetails(contract),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver Detalles'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  void _showContractForm({ContractModel? contract}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ContractFormDialog(contract: contract),
    );
  }

  void _showContractDetails(ContractModel contract) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Contrato'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Empleado:', contract.employeeName),
              _buildDetailRow('Posición:', contract.position),
              _buildDetailRow('Departamento:', contract.department),
              _buildDetailRow('Tipo:', contract.contractType),
              _buildDetailRow('Jornada:', contract.workSchedule),
              _buildDetailRow('Salario:', currencyFormat.format(contract.salary)),
              _buildDetailRow('Moneda:', contract.currency),
              _buildDetailRow('Fecha Inicio:', contract.startDate),
              if (contract.endDate != null)
                _buildDetailRow('Fecha Fin:', contract.endDate!),
              _buildDetailRow('Estado:', contract.isActive ? 'Activo' : 'Inactivo'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _ContractFormDialog extends StatefulWidget {
  final ContractModel? contract;
    const _ContractFormDialog({this.contract});

  @override
  State<_ContractFormDialog> createState() => _ContractFormDialogState();
}

class _ContractFormDialogState extends State<_ContractFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _salaryController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // Dropdown values
  String? _selectedEmployeeId;
  String _contractType = 'INDEFINITE';
  String _workSchedule = 'FULL_TIME';
  String _currency = 'COP';
  bool _isActive = true;

  // Available options
  final Map<String, String> _contractTypes = {
    'INDEFINITE': 'Indefinido',
    'FIXED_TERM': 'Término Fijo',
    'TEMPORARY': 'Temporal',
    'INTERNSHIP': 'Pasantía',
  };

  final Map<String, String> _workSchedules = {
    'FULL_TIME': 'Tiempo Completo',
    'PART_TIME': 'Tiempo Parcial',
    'FLEX_TIME': 'Tiempo Flexible',
    'SHIFT_WORK': 'Trabajo por Turnos',
  };

  final Map<String, String> _currencies = {
    'COP': 'Peso Colombiano',
    'USD': 'Dólar Estadounidense',
    'EUR': 'Euro',
  };

  List<Map<String, dynamic>> _employees = [];
  bool _isLoadingEmployees = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    if (widget.contract != null) {
      _initializeFormWithContract(widget.contract!);
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    _departmentController.dispose();
    _salaryController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      // Simulated employee data - in a real app, you'd fetch this from a service
      setState(() {
        _employees = [
          {'id': 7, 'name': 'Juan Pérez'},
          {'id': 8, 'name': 'María García'},
          {'id': 9, 'name': 'Carlos López'},
          {'id': 10, 'name': 'Ana Martínez'},
        ];
        _isLoadingEmployees = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEmployees = false;
      });
    }
  }

  void _initializeFormWithContract(ContractModel contract) {
    _selectedEmployeeId = contract.employeeId.toString();
    _positionController.text = contract.position;
    _departmentController.text = contract.department;
    _salaryController.text = contract.salary.toString();
    _startDateController.text = contract.startDate;
    _endDateController.text = contract.endDate ?? '';
    _contractType = contract.contractType;
    _workSchedule = contract.workSchedule;
    _currency = contract.currency;
    _isActive = contract.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contract == null ? 'Nuevo Contrato' : 'Editar Contrato'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Employee Selection
                if (widget.contract == null)
                  DropdownButtonFormField<String>(
                    value: _selectedEmployeeId,
                    decoration: const InputDecoration(
                      labelText: 'Empleado *',
                      border: OutlineInputBorder(),
                    ),
                    items: _isLoadingEmployees
                        ? []
                        : _employees.map((employee) {
                            return DropdownMenuItem<String>(
                              value: employee['id'].toString(),
                              child: Text(employee['name']),
                            );
                          }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEmployeeId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleccione un empleado';
                      }
                      return null;
                    },
                  ),
                
                if (widget.contract == null) const SizedBox(height: 16),

                // Position
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    labelText: 'Posición *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese la posición';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Department
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Departamento *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el departamento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contract Type
                DropdownButtonFormField<String>(
                  value: _contractType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Contrato *',
                    border: OutlineInputBorder(),
                  ),
                  items: _contractTypes.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _contractType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Work Schedule
                DropdownButtonFormField<String>(
                  value: _workSchedule,
                  decoration: const InputDecoration(
                    labelText: 'Jornada Laboral *',
                    border: OutlineInputBorder(),
                  ),
                  items: _workSchedules.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _workSchedule = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Salary
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _salaryController,
                        decoration: const InputDecoration(
                          labelText: 'Salario *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingrese el salario';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Ingrese un valor numérico válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _currency,
                        decoration: const InputDecoration(
                          labelText: 'Moneda',
                          border: OutlineInputBorder(),
                        ),
                        items: _currencies.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.key),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _currency = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        decoration: const InputDecoration(
                          labelText: 'Fecha Inicio *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(_startDateController, 'Fecha de Inicio'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Seleccione la fecha de inicio';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        decoration: const InputDecoration(
                          labelText: 'Fecha Fin (Opcional)',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(_endDateController, 'Fecha de Fin'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Active Status
                CheckboxListTile(
                  title: const Text('Contrato Activo'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value ?? true;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveContract,
          child: Text(widget.contract == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _selectDate(TextEditingController controller, String label) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    
    if (date != null) {
      controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _saveContract() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payrollProvider = Provider.of<PayrollProvider>(context, listen: false);

    final contractData = {
      'employee': int.parse(_selectedEmployeeId ?? '0'),
      'position': _positionController.text.trim(),
      'department': _departmentController.text.trim(),
      'contract_type': _contractType,
      'work_schedule': _workSchedule,
      'salary': _salaryController.text.trim(),
      'currency': _currency,
      'start_date': _startDateController.text,
      'end_date': _endDateController.text.isEmpty ? null : _endDateController.text,
      'is_active': _isActive,
    };

    bool success;
    if (widget.contract == null) {
      success = await payrollProvider.createContract(contractData);
    } else {
      success = await payrollProvider.updateContract(widget.contract!.id, contractData);
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.contract == null 
              ? 'Contrato creado exitosamente'
              : 'Contrato actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh the contracts list
      await payrollProvider.fetchContracts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${payrollProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
