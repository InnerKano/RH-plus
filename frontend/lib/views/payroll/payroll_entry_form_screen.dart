import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/providers/payroll_provider.dart';
import 'package:rh_plus/providers/employee_provider.dart';
import 'package:rh_plus/models/employee_model.dart';
import 'package:rh_plus/models/payroll_models.dart';

class PayrollEntryFormScreen extends StatefulWidget {
  const PayrollEntryFormScreen({Key? key}) : super(key: key);

  @override
  State<PayrollEntryFormScreen> createState() => _PayrollEntryFormScreenState();
}

class _PayrollEntryFormScreenState extends State<PayrollEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
    // Form data
  EmployeeModel? _selectedEmployee;
  ContractModel? _selectedContract;
  PayrollPeriodModel? _selectedPeriod;
  
  // Dynamic payroll items
  List<PayrollEntryItem> _earningsItems = [];
  List<PayrollEntryItem> _deductionsItems = [];
    bool _isLoading = false;
  bool _isSubmitting = false;
  bool _dataInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataInitialized) {
      _dataInitialized = true;
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    
    try {
      // Fetch employees, periods, and payroll items
      await Future.wait([
        context.read<EmployeeProvider>().fetchEmployees(),
        context.read<PayrollProvider>().fetchOpenPayrollPeriods(),
        context.read<PayrollProvider>().fetchPayrollItems(),
      ]);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error loading data: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onEmployeeChanged(EmployeeModel? employee) async {
    setState(() {
      _selectedEmployee = employee;
      _selectedContract = null;
    });

    if (employee != null) {
      setState(() => _isLoading = true);
      try {
        await context.read<PayrollProvider>().fetchContractsByEmployee(employee.id);
        final contracts = context.read<PayrollProvider>().contracts;
        if (contracts.isNotEmpty) {
          setState(() => _selectedContract = contracts.first);
        }
      } catch (e) {
        _showErrorSnackBar('Error loading contracts: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addEarningItem() {
    setState(() {
      _earningsItems.add(PayrollEntryItem());
    });
  }

  void _removeEarningItem(int index) {
    setState(() {
      _earningsItems.removeAt(index);
    });
  }

  void _addDeductionItem() {
    setState(() {
      _deductionsItems.add(PayrollEntryItem());
    });
  }

  void _removeDeductionItem(int index) {
    setState(() {
      _deductionsItems.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEmployee == null || _selectedContract == null || _selectedPeriod == null) {
      _showErrorSnackBar('Please fill all required fields');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Prepare entry details
      List<Map<String, dynamic>> details = [];
      
      // Add earnings
      for (var item in _earningsItems) {
        if (item.payrollItem != null && item.amount > 0) {
          details.add({
            'payroll_item': item.payrollItem!.id,
            'amount': item.amount,
            'quantity': item.quantity,
            'notes': item.notes?.isNotEmpty == true ? item.notes : null,
          });
        }
      }
      
      // Add deductions
      for (var item in _deductionsItems) {
        if (item.payrollItem != null && item.amount > 0) {
          details.add({
            'payroll_item': item.payrollItem!.id,
            'amount': item.amount,
            'quantity': item.quantity,
            'notes': item.notes?.isNotEmpty == true ? item.notes : null,
          });
        }
      }

      if (details.isEmpty) {
        _showErrorSnackBar('Please add at least one payroll item');
        return;
      }

      // Create payroll entry
      final entryData = {
        'contract': _selectedContract!.id,
        'period': _selectedPeriod!.id,
        'details': details,
      };

      final success = await context.read<PayrollProvider>().createPayrollEntry(entryData);
      
      if (success) {
        _showSuccessSnackBar('Payroll entry created successfully');
        Navigator.of(context).pop();
      } else {
        _showErrorSnackBar('Failed to create payroll entry');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating payroll entry: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Payroll Entry'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeSection(),
            const SizedBox(height: 20),
            _buildContractSection(),
            const SizedBox(height: 20),
            _buildPeriodSection(),
            const SizedBox(height: 20),
            _buildEarningsSection(),
            const SizedBox(height: 20),
            _buildDeductionsSection(),
          ],
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
              'Employee Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<EmployeeProvider>(
              builder: (context, employeeProvider, child) {
                final employees = employeeProvider.employees;                return DropdownButtonFormField<EmployeeModel>(
                  value: _selectedEmployee,
                  decoration: const InputDecoration(
                    labelText: 'Select Employee *',
                    border: OutlineInputBorder(),
                  ),
                  items: employees.map((employee) {
                    return DropdownMenuItem<EmployeeModel>(
                      value: employee,
                      child: Text('${employee.firstName} ${employee.lastName}'),
                    );
                  }).toList(),
                  onChanged: _onEmployeeChanged,
                  validator: (value) => value == null ? 'Please select an employee' : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contract Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_selectedContract != null) ...[
              _buildInfoRow('Position', _selectedContract!.position),
              _buildInfoRow('Department', _selectedContract!.department),
              _buildInfoRow('Salary', '\$${_selectedContract!.salary.toStringAsFixed(2)}'),
              _buildInfoRow('Type', _selectedContract!.contractType),
            ] else
              const Text('Select an employee to view contract information'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payroll Period',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<PayrollProvider>(
              builder: (context, payrollProvider, child) {
                final periods = payrollProvider.periods;
                return DropdownButtonFormField<PayrollPeriodModel>(
                  value: _selectedPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Select Period *',
                    border: OutlineInputBorder(),
                  ),
                  items: periods.map((period) {
                    return DropdownMenuItem<PayrollPeriodModel>(
                      value: period,
                      child: Text('${period.name} (${period.startDate} - ${period.endDate})'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedPeriod = value),
                  validator: (value) => value == null ? 'Please select a period' : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Earnings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _addEarningItem,
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_earningsItems.isEmpty)
              const Text('No earnings added. Click + to add earnings.')
            else
              ..._earningsItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildPayrollItemRow(
                  item: item,
                  itemType: 'EARNING',
                  onRemove: () => _removeEarningItem(index),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Deductions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _addDeductionItem,
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_deductionsItems.isEmpty)
              const Text('No deductions added. Click + to add deductions.')
            else
              ..._deductionsItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildPayrollItemRow(
                  item: item,
                  itemType: 'DEDUCTION',
                  onRemove: () => _removeDeductionItem(index),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollItemRow({
    required PayrollEntryItem item,
    required String itemType,
    required VoidCallback onRemove,
  }) {
    return Consumer<PayrollProvider>(
      builder: (context, payrollProvider, child) {
        final availableItems = itemType == 'EARNING'
            ? payrollProvider.getEarnings()
            : payrollProvider.getDeductions();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<PayrollItemModel>(
                        value: item.payrollItem,
                        decoration: InputDecoration(
                          labelText: 'Select ${itemType.toLowerCase()}',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: availableItems.map((payrollItem) {
                          return DropdownMenuItem<PayrollItemModel>(
                            value: payrollItem,
                            child: Text(payrollItem.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            item.payrollItem = value;
                            if (value?.defaultAmount != null) {
                              item.amount = value!.defaultAmount!;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: item.amount > 0 ? item.amount.toString() : '',
                        onChanged: (value) {
                          item.amount = double.tryParse(value) ?? 0.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Quantity (optional)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: item.quantity > 0 ? item.quantity.toString() : '1',
                        onChanged: (value) {
                          item.quantity = double.tryParse(value) ?? 1.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          item.notes = value;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Entry'),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for managing payroll entry items
class PayrollEntryItem {
  PayrollItemModel? payrollItem;
  double amount = 0.0;
  double quantity = 1.0;
  String? notes;

  PayrollEntryItem({
    this.payrollItem,
    this.amount = 0.0,
    this.quantity = 1.0,
    this.notes,
  });
}
