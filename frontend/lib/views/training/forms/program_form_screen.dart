import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../models/training_models.dart';
import '../../../providers/training_provider.dart';
import '../../../widgets/loading_state_widget.dart';
import '../../../widgets/error_dialog.dart';

class ProgramFormScreen extends StatefulWidget {
  final TrainingProgramModel? program;
  final bool isEditing;

  const ProgramFormScreen({
    super.key,
    this.program,
    this.isEditing = false,
  });

  @override
  State<ProgramFormScreen> createState() => _ProgramFormScreenState();
}

class _ProgramFormScreenState extends State<ProgramFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _objectivesController = TextEditingController();
  final _durationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  
  String _selectedStatus = 'draft';
  String _selectedType = 'technical';
  String _selectedDepartment = '';
  List<String> _departments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    
    if (widget.isEditing && widget.program != null) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _objectivesController.dispose();
    _durationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _loadDepartments() {
    // This would typically load from an API
    _departments = [
      'Recursos Humanos',
      'Tecnología',
      'Ventas',
      'Marketing',
      'Finanzas',
      'Operaciones',
      'General',
    ];
    
    if (_departments.isNotEmpty) {
      _selectedDepartment = _departments.first;
    }
  }
  void _populateForm() {
    final program = widget.program!;
    _nameController.text = program.name;
    _descriptionController.text = program.description;
    _objectivesController.text = program.objectives;
    _durationController.text = program.durationHours.toString();
    
    // These fields are not in the model, so using default values
    _startDateController.text = '';
    _endDateController.text = '';
    _selectedStatus = program.isActive ? 'active' : 'draft';
    _selectedType = 'technical'; // Default value
    _selectedDepartment = _departments.first; // Default value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar Programa' : 'Crear Programa',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: Consumer<TrainingProvider>(
        builder: (context, provider, _) {
          return LoadingStateWidget(
            isLoading: provider.isLoading,
            error: provider.error,
            onRetry: () {
              if (widget.isEditing) {
                // Recargar datos del programa
                _populateForm();
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Basic Information Section
                    _buildSection(
                      title: 'Información Básica',
                      icon: Icons.info_outline,
                      children: [
                        _buildTextFormField(
                          controller: _nameController,
                          label: 'Nombre del Programa',
                          hint: 'Ingrese el nombre del programa',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El nombre es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _descriptionController,
                          label: 'Descripción',
                          hint: 'Descripción detallada del programa',
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La descripción es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _objectivesController,
                          label: 'Objetivos',
                          hint: 'Objetivos del programa de formación',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Configuration Section
                    _buildSection(
                      title: 'Configuración',
                      icon: Icons.settings,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                label: 'Tipo',
                                value: _selectedType,
                                items: const [
                                  {'value': 'technical', 'label': 'Técnico'},
                                  {'value': 'soft_skills', 'label': 'Habilidades Blandas'},
                                  {'value': 'leadership', 'label': 'Liderazgo'},
                                  {'value': 'compliance', 'label': 'Cumplimiento'},
                                  {'value': 'safety', 'label': 'Seguridad'},
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdownField(
                                label: 'Estado',
                                value: _selectedStatus,
                                items: const [
                                  {'value': 'draft', 'label': 'Borrador'},
                                  {'value': 'active', 'label': 'Activo'},
                                  {'value': 'archived', 'label': 'Archivado'},
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStatus = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                label: 'Departamento',
                                value: _selectedDepartment,
                                items: _departments.map((dept) => {
                                  'value': dept,
                                  'label': dept,
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDepartment = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _durationController,
                                label: 'Duración (horas)',
                                hint: '0',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final duration = double.tryParse(value);
                                    if (duration == null || duration <= 0) {
                                      return 'Ingrese una duración válida';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Date Range Section
                    _buildSection(
                      title: 'Fechas',
                      icon: Icons.calendar_today,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                controller: _startDateController,
                                label: 'Fecha de Inicio',
                                hint: 'DD/MM/AAAA',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDateField(
                                controller: _endDateController,
                                label: 'Fecha de Fin',
                                hint: 'DD/MM/AAAA',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: AppColors.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProgram,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              widget.isEditing ? 'Actualizar' : 'Crear Programa',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(item['label']!),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryColor,
        ),
        suffixIcon: Icon(
          Icons.calendar_today,
          color: AppColors.primaryColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      onTap: () => _selectDate(controller),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }  
  Future<void> _saveProgram() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<TrainingProvider>(context, listen: false);
    
    try {
      final programData = {
        if (widget.program?.id != null) 'id': widget.program!.id,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'training_type': _selectedType,
        'duration_hours': double.parse(_durationController.text),
        'objectives': _objectivesController.text,
        'is_active': _selectedStatus == 'active',
      };

      if (widget.isEditing) {
        await provider.updateProgram(programData);
      } else {
        await provider.createProgram(programData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing 
              ? 'Programa actualizado exitosamente'
              : 'Programa creado exitosamente'
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        context.showError(
          'Error al ${widget.isEditing ? 'actualizar' : 'crear'} el programa: ${e.toString()}',
          onRetry: _saveProgram,
        );
      }
    }
  }
}
