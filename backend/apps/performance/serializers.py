from rest_framework import serializers
from .models import (
    EvaluationType, EvaluationCriteria, EvaluationPeriod, Evaluation,
    EvaluationDetail, ImprovementPlan, ImprovementGoal
)

class EvaluationCriteriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = EvaluationCriteria
        fields = '__all__'

class EvaluationTypeSerializer(serializers.ModelSerializer):
    criteria = EvaluationCriteriaSerializer(many=True, read_only=True)
    
    class Meta:
        model = EvaluationType
        fields = '__all__'

class EvaluationPeriodSerializer(serializers.ModelSerializer):
    evaluation_type_name = serializers.ReadOnlyField(source='evaluation_type.name')
    
    class Meta:
        model = EvaluationPeriod
        fields = '__all__'

class EvaluationDetailSerializer(serializers.ModelSerializer):
    criteria_name = serializers.ReadOnlyField(source='criteria.name')
    criteria_weight = serializers.ReadOnlyField(source='criteria.weight')
    
    class Meta:
        model = EvaluationDetail
        fields = '__all__'

class EvaluationSerializer(serializers.ModelSerializer):
    details = EvaluationDetailSerializer(many=True, read_only=True)
    employee_name = serializers.ReadOnlyField(source='employee.__str__')
    evaluator_name = serializers.ReadOnlyField(source='evaluator.__str__')
    period_name = serializers.ReadOnlyField(source='evaluation_period.name')
    
    class Meta:
        model = Evaluation
        fields = '__all__'

class ImprovementGoalSerializer(serializers.ModelSerializer):
    class Meta:
        model = ImprovementGoal
        fields = '__all__'

class ImprovementPlanSerializer(serializers.ModelSerializer):
    goals = ImprovementGoalSerializer(many=True, read_only=True)
    employee_name = serializers.ReadOnlyField(source='employee.__str__')
    supervisor_name = serializers.ReadOnlyField(source='supervisor.__str__')
    
    class Meta:
        model = ImprovementPlan
        fields = '__all__'
