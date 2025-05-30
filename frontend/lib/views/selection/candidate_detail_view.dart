import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/providers/selection_provider.dart';
import '../../models/selection_models.dart';
import '../../utils/constants.dart';
import '../../models/candidate_model.dart';

class CandidateDetailView extends StatefulWidget {
  final CandidateModel candidate;

  const CandidateDetailView({
    Key? key,
    required this.candidate,
  }) : super(key: key);

  @override
  State<CandidateDetailView> createState() => _CandidateDetailViewState();
}

class _CandidateDetailViewState extends State<CandidateDetailView> {
  int? _selectedStageId;
  bool _isUpdatingStage = false;


  @override
  void initState() {
    super.initState();
    _selectedStageId = widget.candidate.currentStageId;
    // Cargar etapas si no están cargadas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
      if (selectionProvider.stages.isEmpty) {
        selectionProvider.loadStages();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidate;
    final selectionProvider = Provider.of<SelectionProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          candidate.fullName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.textColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.greyLight,
                      child: Text(
                        candidate.firstName.isNotEmpty ? candidate.firstName[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate.fullName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            candidate.currentStageName ?? 'Sin etapa actual',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.greyDark,
                                ),
                          ),
                          const SizedBox(height: 8),
                          _buildStatusChip(candidate.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Datos personales
                Text(
                  'Datos Personales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Divider(height: 24, color: AppColors.greyLight),
                _buildDetailRow(Icons.badge_outlined, 'Documento', '${candidate.documentType} ${candidate.documentNumber}'),
                _buildDetailRow(Icons.email_outlined, 'Correo', candidate.email),
                _buildDetailRow(Icons.phone_outlined, 'Teléfono', candidate.phone),
                _buildDetailRow(Icons.person_pin_outlined, 'Género', candidate.gender),
                _buildDetailRow(
                  Icons.cake_outlined,
                  'Fecha de nacimiento',
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(candidate.birthDate)),
                ),
                _buildDetailRow(Icons.location_on_outlined, 'Dirección', candidate.address ?? 'No especificada'),

                const SizedBox(height: 32),

                // Información de proceso
                Text(
                  'Información de Proceso',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Divider(height: 24, color: AppColors.greyLight),
                _buildDetailRow(Icons.work_outline, 'Etapa', candidate.currentStageName ?? 'No especificado'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: DropdownButtonFormField<int>(
                    value: _selectedStageId,
                    decoration: const InputDecoration(
                      labelText: 'Asignar nueva etapa',
                      border: OutlineInputBorder(),
                    ),
                    items: selectionProvider.stages.map((stage) {
                      return DropdownMenuItem<int>(
                        value: stage.id,
                        child: Text(stage.name),
                      );
                    }).toList(),
                    onChanged: _isUpdatingStage
                        ? null
                        : (int? newStageId) async {
                            if (newStageId == null || newStageId == _selectedStageId) return;
                            setState(() => _isUpdatingStage = true);
                            final success = await selectionProvider.updateCandidateStage(
                              candidate.id,
                              newStageId,
                            );
                            if (!mounted) return;
                            setState(() {
                              _isUpdatingStage = false;
                              if (success) {
                                _selectedStageId = newStageId;
                                final newStage = selectionProvider.stages.firstWhere((s) => s.id == newStageId);
                                candidate.currentStageName = newStage.name;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Etapa asignada correctamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(selectionProvider.error ?? 'Error al asignar etapa'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            });
                          },
                  ),
                ),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Fecha de registro',
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(candidate.createdAt)),
                ),
                const SizedBox(height: 32),

                // Acciones (en desarrollo)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: AppColors.greyDark),
                        label: const Text(
                          'Volver',
                          style: TextStyle(color: AppColors.greyDark, fontWeight: FontWeight.w500),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.greyDark),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.greyDark,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final statusInfo = SelectionStatus.displayNames[status] ?? status;
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Text(
        statusInfo,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case SelectionStatus.applied:
        return Colors.blue;
      case SelectionStatus.inProgress:
        return Colors.orange;
      case SelectionStatus.approved:
        return Colors.green;
      case SelectionStatus.rejected:
        return Colors.red;
      case SelectionStatus.hired:
        return Colors.purple;
      case SelectionStatus.withdrawn:
        return AppColors.greyDark;
      default:
        return AppColors.greyDark;
    }
  }
}