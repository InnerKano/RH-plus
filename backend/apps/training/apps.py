from django.apps import AppConfig

class TrainingConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.training'
    
    def ready(self):
        import apps.training.signals
