"""Repository pattern for Selection app."""
from .models import Candidate, SelectionProcess, SelectionStage

class CandidateRepository:
    """Repository for Candidate model."""
    
    @staticmethod
    def get_active_candidates():
        """Return all active candidates."""
        return Candidate.objects.filter(status='ACTIVE')
    
    @staticmethod
    def get_by_document(document_type, document_number):
        """Return candidate by document."""
        return Candidate.objects.filter(
            document_type=document_type, 
            document_number=document_number
        ).first()

class SelectionProcessRepository:
    """Repository for SelectionProcess model."""
    
    @staticmethod
    def get_active_processes():
        """Return all active selection processes."""
        return SelectionProcess.objects.filter(is_active=True)
    
    @staticmethod
    def get_candidates_by_process(process_id):
        """Return all candidates in a specific selection process."""
        return Candidate.objects.filter(
            processcandidate__process_id=process_id
        )
