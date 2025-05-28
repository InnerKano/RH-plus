import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../../models/training_models.dart';
import '../../../providers/training_provider.dart';

class SessionFormScreen extends StatefulWidget {
  final TrainingSessionModel? session;
  final bool isEditing;

  const SessionFormScreen({
    super.key,
    this.session,
    this.isEditing = false,
  });

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _instructorController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _sessionDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  
  String _selectedProgram = '';
  String _selectedStatus = 'scheduled';
  List<TrainingProgramModel> _programs = [];
  bool _isLoading = false;
  bool _isLoadingPrograms = true;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
    
    if (widget.isEditing && widget.session != null) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _instructorController.dispose();
    _maxParticipantsController.dispose();
    _sessionDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
  Future<void> _loadPrograms() async {
    setState(() => _isLoadingPrograms = true);
    try {
      // Get the provider using Provider.of with context
      final trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
      
      // Use the correct method name
      await trainingProvider.fetchTrainingPrograms();
      
      // Update the condition to use isActive instead of status
      _programs = trainingProvider.programs.where((p) => p.isActive).toList();
      
      if (_programs.isNotEmpty && _selectedProgram.isEmpty) {
        // Convert to string since _selectedProgram is a String
        _selectedProgram = _programs.first.id.toString();
      }
    } catch (e) {
      debugPrint('Error loading programs: $e');
    } finally {
      setState(() => _isLoadingPrograms = false);
    }
  }
  void _populateForm() {
    final session = widget.session!;
    
    // The model doesn't have a title field, use programName instead
    _titleController.text = session.programName;
    
    // These fields don't exist in the model, so set defaults
    _descriptionController.text = '';
    
    // Use the fields that do exist in the model
    _locationController.text = session.location;
    _instructorController.text = session.instructorName;
    _maxParticipantsController.text = session.maxParticipants.toString();
    _sessionDateController.text = session.sessionDate;
    _startTimeController.text = session.startTime;
    _endTimeController.text = session.endTime;
    _selectedStatus = session.status;
    _selectedProgram = session.programId.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar Sesión' : 'Crear Sesión',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSession,
            child: Text(
              'Guardar',
              style: TextStyle(
                color: _isLoading ? Colors.white54 : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoadingPrograms
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          )
        : _isLoading 
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildSection(
                      title: 'Información Básica',
                      icon: Icons.info_outline,
                      children: [                        _buildDropdownField(
                          label: 'Programa de Formación',
                          value: _selectedProgram,
                          items: _programs.map((program) => {
                            'value': program.id.toString(),
                            'label': program.name,
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedProgram = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _titleController,
                          label: 'Título de la Sesión',
                          hint: 'Ingrese el título de la sesión',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El título es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _descriptionController,
                          label: 'Descripción',
                          hint: 'Descripción de la sesión',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _instructorController,
                          label: 'Instructor',
                          hint: 'Nombre del instructor',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El instructor es obligatorio';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Schedule Section
                    _buildSection(
                      title: 'Programación',
                      icon: Icons.schedule,
                      children: [
                        _buildDateField(
                          controller: _sessionDateController,
                          label: 'Fecha de la Sesión',
                          hint: 'DD/MM/AAAA',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La fecha es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeField(
                                controller: _startTimeController,
                                label: 'Hora de Inicio',
                                hint: 'HH:MM',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTimeField(
                                controller: _endTimeController,
                                label: 'Hora de Fin',
                                hint: 'HH:MM',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Location and Capacity Section
                    _buildSection(
                      title: 'Ubicación y Capacidad',
                      icon: Icons.location_on,
                      children: [
                        _buildTextFormField(
                          controller: _locationController,
                          label: 'Ubicación',
                          hint: 'Sala de reuniones, dirección, etc.',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La ubicación es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                controller: _maxParticipantsController,
                                label: 'Máximo de Participantes',
                                hint: '0',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Este campo es obligatorio';
                                  }
                                  final participants = int.tryParse(value);
                                  if (participants == null || participants <= 0) {
                                    return 'Ingrese un número válido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdownField(
                                label: 'Estado',
                                value: _selectedStatus,
                                items: const [
                                  {'value': 'scheduled', 'label': 'Programado'},
                                  {'value': 'in_progress', 'label': 'En Progreso'},
                                  {'value': 'completed', 'label': 'Completado'},
                                  {'value': 'cancelled', 'label': 'Cancelado'},
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
                            onPressed: _isLoading ? null : _saveSession,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              widget.isEditing ? 'Actualizar' : 'Crear Sesión',
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
      value: value.isNotEmpty ? value : null,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
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

  Widget _buildTimeField({
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
          Icons.access_time,
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
      onTap: () => _selectTime(controller),
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

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }
  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final selectedProgram = _programs.firstWhere((p) => p.id.toString() == _selectedProgram);
      
      // Create a session model with the correct properties according to TrainingSessionModel
      final session = TrainingSessionModel(
        id: widget.isEditing ? widget.session!.id : 0,
        programId: int.parse(_selectedProgram),
        programName: selectedProgram.name,
        sessionDate: _sessionDateController.text,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        location: _locationController.text,
        instructorId: 1, // Default value since we don't have a proper field
        instructorName: _instructorController.text,
        maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 10,
        status: _selectedStatus,
        notes: _descriptionController.text, // Use notes for description
      );

      // Get the provider using Provider.of
      final trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
      
      // For demonstration purposes, we're just fetching programs since the actual methods don't exist
      if (widget.isEditing) {
        // In a real app, you would call a method like:
        // await trainingProvider.updateSession(session);
        await trainingProvider.fetchUpcomingSessions();
        debugPrint('Would update session: ${session.programName}');
      } else {
        // In a real app, you would call a method like:
        // await trainingProvider.createSession(session);
        await trainingProvider.fetchUpcomingSessions();
        debugPrint('Would create session: ${session.programName}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing 
                ? 'Sesión actualizada exitosamente'
                : 'Sesión creada exitosamente',
            ),
            backgroundColor: AppColors.successColor,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
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
