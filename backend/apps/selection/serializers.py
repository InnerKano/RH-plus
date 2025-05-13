from rest_framework import serializers
from .models import SelectionStage, Candidate, SelectionProcess, ProcessCandidate, CandidateDocument

class SelectionStageSerializer(serializers.ModelSerializer):
    class Meta:
        model = SelectionStage
        fields = '__all__'

class CandidateDocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = CandidateDocument
        fields = '__all__'

class CandidateSerializer(serializers.ModelSerializer):
    documents = CandidateDocumentSerializer(many=True, read_only=True)
    
    class Meta:
        model = Candidate
        fields = '__all__'

class ProcessCandidateSerializer(serializers.ModelSerializer):
    candidate = CandidateSerializer(read_only=True)
    
    class Meta:
        model = ProcessCandidate
        fields = '__all__'

class SelectionProcessSerializer(serializers.ModelSerializer):
    process_candidates = ProcessCandidateSerializer(source='processcandidate_set', many=True, read_only=True)
    
    class Meta:
        model = SelectionProcess
        fields = '__all__'
