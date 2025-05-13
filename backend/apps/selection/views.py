from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import SelectionStage, Candidate, SelectionProcess, ProcessCandidate, CandidateDocument
from .serializers import (
    SelectionStageSerializer, CandidateSerializer, SelectionProcessSerializer,
    ProcessCandidateSerializer, CandidateDocumentSerializer
)
from .repositories import CandidateRepository, SelectionProcessRepository

class SelectionStageViewSet(viewsets.ModelViewSet):
    queryset = SelectionStage.objects.all()
    serializer_class = SelectionStageSerializer
    permission_classes = [permissions.IsAuthenticated]

class CandidateViewSet(viewsets.ModelViewSet):
    serializer_class = CandidateSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return CandidateRepository.get_active_candidates()
    
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

class CandidateDocumentViewSet(viewsets.ModelViewSet):
    queryset = CandidateDocument.objects.all()
    serializer_class = CandidateDocumentSerializer
    permission_classes = [permissions.IsAuthenticated]
