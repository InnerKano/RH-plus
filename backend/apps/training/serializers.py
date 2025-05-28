from rest_framework import serializers
from django.utils import timezone
from .models import TrainingType, TrainingProgram, TrainingSession, TrainingAttendance, TrainingEvaluation
from .logging import logger

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
    
    def validate(self, data):
        logger.info("Validating training session data")
        
        # Validar que la fecha de sesión no sea en el pasado
        if 'session_date' in data and data['session_date'] < timezone.now().date():
            logger.warning(f"Invalid session date: {data['session_date']} is in the past")
            raise serializers.ValidationError({
                "session_date": "La fecha de la sesión no puede ser en el pasado"
            })
        
        # Validar que la hora de fin sea posterior a la de inicio
        if 'start_time' in data and 'end_time' in data:
            if data['start_time'] >= data['end_time']:
                logger.warning(f"Invalid session times: start {data['start_time']} is not before end {data['end_time']}")
                raise serializers.ValidationError({
                    "end_time": "La hora de finalización debe ser posterior a la hora de inicio"
                })
        
        # Validar número de participantes
        if 'max_participants' in data and data['max_participants'] <= 0:
            logger.warning(f"Invalid max participants: {data['max_participants']}")
            raise serializers.ValidationError({
                "max_participants": "El número máximo de participantes debe ser mayor a 0"
            })
        
        logger.info("Session data validation successful")
        return data

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
