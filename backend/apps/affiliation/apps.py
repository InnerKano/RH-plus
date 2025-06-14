from django.apps import AppConfig

class AffiliationConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.affiliation'
    
    def ready(self):
        import apps.affiliation.signals
