from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import SelectionStage, Candidate, SelectionProcess, ProcessCandidate, CandidateDocument
from .serializers import (
    SelectionStageSerializer, CandidateSerializer, SelectionProcessSerializer,
    ProcessCandidateSerializer, CandidateDocumentSerializer
)
from .repositories import CandidateRepository, SelectionProcessRepository
from apps.core.utils import record_activity

class SelectionStageViewSet(viewsets.ModelViewSet):
    queryset = SelectionStage.objects.all()
    serializer_class = SelectionStageSerializer
    permission_classes = [permissions.IsAuthenticated]

class CandidateViewSet(viewsets.ModelViewSet):
    serializer_class = CandidateSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return CandidateRepository.get_active_candidates()
        
    def perform_create(self, serializer):
        """Register a system activity when a candidate is created."""
        candidate = serializer.save()
        record_activity(
            title="Nuevo candidato registrado",
            description=f"Se ha registrado al candidato {candidate.first_name} {candidate.last_name} para el proceso de selección",
            activity_type="candidate",
            user=self.request.user
        )
        
    def perform_update(self, serializer):
        """Register a system activity when a candidate is updated."""
        candidate = serializer.save()
        record_activity(
            title="Información de candidato actualizada",
            description=f"Se ha actualizado la información del candidato {candidate.first_name} {candidate.last_name}",
            activity_type="candidate",
            user=self.request.user
        )
    
    @action(detail=False, methods=['get'])
    def by_document(self, request):
        doc_type = request.query_params.get('type')
        doc_number = request.query_params.get('number')
        
        if not doc_type or not doc_number:
            return Response({"error": "Missing document type or number"}, status=400)
        
        candidate = CandidateRepository.get_by_document(doc_type, doc_number)
        if not candidate:
            return Response({"error": "Candidate not found"}, status=404)
        
        serializer = self.get_serializer(candidate)
        return Response(serializer.data)

class SelectionProcessViewSet(viewsets.ModelViewSet):
    serializer_class = SelectionProcessSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return SelectionProcessRepository.get_active_processes()
    
    @action(detail=True, methods=['get'])
    def candidates(self, request, pk=None):
        """Return all candidates in this selection process."""
        candidates = SelectionProcessRepository.get_candidates_by_process(pk)
        serializer = CandidateSerializer(candidates, many=True)
        return Response(serializer.data)

class ProcessCandidateViewSet(viewsets.ModelViewSet):
    queryset = ProcessCandidate.objects.all()
    serializer_class = ProcessCandidateSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def perform_update(self, serializer):
        """Register activity when a candidate's status in a process changes."""
        process_candidate = serializer.save()
        candidate = process_candidate.candidate
        process = process_candidate.process
        stage = process_candidate.stage
        
        record_activity(
            title="Actualización de estado de candidato",
            description=f"El candidato {candidate.first_name} {candidate.last_name} ha avanzado a la etapa '{stage.name}' en el proceso '{process.name}'",
            activity_type="candidate",
            user=self.request.user
        )

class CandidateDocumentViewSet(viewsets.ModelViewSet):
    queryset = CandidateDocument.objects.all()
    serializer_class = CandidateDocumentSerializer
    permission_classes = [permissions.IsAuthenticated]
