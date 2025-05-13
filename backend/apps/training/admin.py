from django.contrib import admin
from .models import TrainingType, TrainingProgram, TrainingSession, TrainingAttendance, TrainingEvaluation

@admin.register(TrainingType)
class TrainingTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'is_active')
    search_fields = ('name',)
    list_filter = ('is_active',)

@admin.register(TrainingProgram)
class TrainingProgramAdmin(admin.ModelAdmin):
    list_display = ('name', 'training_type', 'duration_hours', 'is_active', 'created_at')
    search_fields = ('name',)
    list_filter = ('training_type', 'is_active')
    date_hierarchy = 'created_at'

@admin.register(TrainingSession)
class TrainingSessionAdmin(admin.ModelAdmin):
    list_display = ('program', 'session_date', 'start_time', 'end_time', 'instructor', 'status')
    search_fields = ('program__name', 'instructor__first_name', 'instructor__last_name')
    list_filter = ('program', 'status', 'session_date')
    date_hierarchy = 'session_date'

@admin.register(TrainingAttendance)
class TrainingAttendanceAdmin(admin.ModelAdmin):
    list_display = ('employee', 'session', 'status', 'evaluation_score', 'registered_at')
    search_fields = ('employee__first_name', 'employee__last_name', 'session__program__name')
    list_filter = ('status', 'session__program')
    date_hierarchy = 'registered_at'

@admin.register(TrainingEvaluation)
class TrainingEvaluationAdmin(admin.ModelAdmin):
    list_display = (
        'attendance', 'content_rating', 'instructor_rating', 
        'materials_rating', 'usefulness_rating', 'overall_rating'
    )
    search_fields = ('attendance__employee__first_name', 'attendance__employee__last_name')
    list_filter = ('overall_rating', 'attendance__session__program')
    date_hierarchy = 'submitted_at'
