from rest_framework import serializers
from .models import TrainingType, TrainingProgram, TrainingSession, TrainingAttendance, TrainingEvaluation

class TrainingTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainingType
        fields = '__all__'

class TrainingProgramSerializer(serializers.ModelSerializer):
    training_type_name = serializers.ReadOnlyField(source='training_type.name')
    
    class Meta:
        model = TrainingProgram
        fields = '__all__'

class TrainingSessionSerializer(serializers.ModelSerializer):
    program_name = serializers.ReadOnlyField(source='program.name')
    instructor_name = serializers.ReadOnlyField(source='instructor.__str__')
    
    class Meta:
        model = TrainingSession
        fields = '__all__'

class TrainingAttendanceSerializer(serializers.ModelSerializer):
    employee_name = serializers.ReadOnlyField(source='employee.__str__')
    session_date = serializers.ReadOnlyField(source='session.session_date')
    program_name = serializers.ReadOnlyField(source='session.program.name')
    
    class Meta:
        model = TrainingAttendance
        fields = '__all__'

class TrainingEvaluationSerializer(serializers.ModelSerializer):
    employee_name = serializers.ReadOnlyField(source='attendance.employee.__str__')
    program_name = serializers.ReadOnlyField(source='attendance.session.program.name')
    
    class Meta:
        model = TrainingEvaluation
        fields = '__all__'
