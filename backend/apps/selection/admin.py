from django.contrib import admin
from .models import SelectionStage, Candidate, SelectionProcess, ProcessCandidate, CandidateDocument

@admin.register(SelectionStage)
class SelectionStageAdmin(admin.ModelAdmin):
    list_display = ('name', 'order')
    search_fields = ('name',)
    ordering = ('order', 'name')

@admin.register(Candidate)
class CandidateAdmin(admin.ModelAdmin):
    list_display = ('first_name', 'last_name', 'email', 'document_number', 'status', 'current_stage')
    search_fields = ('first_name', 'last_name', 'email', 'document_number')
    list_filter = ('status', 'current_stage', 'gender')
    date_hierarchy = 'created_at'

@admin.register(SelectionProcess)
class SelectionProcessAdmin(admin.ModelAdmin):
    list_display = ('name', 'start_date', 'end_date', 'is_active')
    search_fields = ('name',)
    list_filter = ('is_active',)
    date_hierarchy = 'start_date'

@admin.register(ProcessCandidate)
class ProcessCandidateAdmin(admin.ModelAdmin):
    list_display = ('process', 'candidate', 'current_stage', 'updated_at')
    search_fields = ('candidate__first_name', 'candidate__last_name', 'process__name')
    list_filter = ('current_stage', 'process')
    date_hierarchy = 'updated_at'

@admin.register(CandidateDocument)
class CandidateDocumentAdmin(admin.ModelAdmin):
    list_display = ('candidate', 'document_type', 'uploaded_at')
    search_fields = ('candidate__first_name', 'candidate__last_name', 'document_type')
    list_filter = ('document_type',)
    date_hierarchy = 'uploaded_at'
