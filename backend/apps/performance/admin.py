from django.contrib import admin
from .models import (
    EvaluationType, EvaluationCriteria, EvaluationPeriod, Evaluation,
    EvaluationDetail, ImprovementPlan, ImprovementGoal
)

class EvaluationCriteriaInline(admin.TabularInline):
    model = EvaluationCriteria
    extra = 1

@admin.register(EvaluationType)
class EvaluationTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'frequency', 'is_active')
    search_fields = ('name',)
    list_filter = ('is_active', 'frequency')
    inlines = [EvaluationCriteriaInline]

@admin.register(EvaluationCriteria)
class EvaluationCriteriaAdmin(admin.ModelAdmin):
    list_display = ('name', 'evaluation_type', 'weight', 'is_active')
    search_fields = ('name',)
    list_filter = ('evaluation_type', 'is_active')

@admin.register(EvaluationPeriod)
class EvaluationPeriodAdmin(admin.ModelAdmin):
    list_display = ('name', 'evaluation_type', 'start_date', 'end_date', 'is_active')
    search_fields = ('name',)
    list_filter = ('evaluation_type', 'is_active')
    date_hierarchy = 'start_date'

class EvaluationDetailInline(admin.TabularInline):
    model = EvaluationDetail
    extra = 0

@admin.register(Evaluation)
class EvaluationAdmin(admin.ModelAdmin):
    list_display = ('employee', 'evaluator', 'evaluation_period', 'status', 'overall_score', 'created_at')
    search_fields = ('employee__first_name', 'employee__last_name', 'evaluator__email')
    list_filter = ('status', 'evaluation_period')
    date_hierarchy = 'created_at'
    inlines = [EvaluationDetailInline]

@admin.register(EvaluationDetail)
class EvaluationDetailAdmin(admin.ModelAdmin):
    list_display = ('evaluation', 'criteria', 'score')
    search_fields = ('evaluation__employee__first_name', 'evaluation__employee__last_name')
    list_filter = ('criteria',)

class ImprovementGoalInline(admin.TabularInline):
    model = ImprovementGoal
    extra = 1

@admin.register(ImprovementPlan)
class ImprovementPlanAdmin(admin.ModelAdmin):
    list_display = ('title', 'employee', 'supervisor', 'start_date', 'end_date', 'status')
    search_fields = ('title', 'employee__first_name', 'employee__last_name')
    list_filter = ('status',)
    date_hierarchy = 'start_date'
    inlines = [ImprovementGoalInline]

@admin.register(ImprovementGoal)
class ImprovementGoalAdmin(admin.ModelAdmin):
    list_display = ('plan', 'due_date', 'status', 'progress')
    search_fields = ('plan__title', 'plan__employee__first_name', 'plan__employee__last_name')
    list_filter = ('status',)
    date_hierarchy = 'due_date'
