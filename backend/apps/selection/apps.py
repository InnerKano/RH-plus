from django.apps import AppConfig

class SelectionConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.selection'
    
    def ready(self):
        import apps.selection.signals
