from django.apps import AppConfig

class PayrollConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.payroll'
    
    def ready(self):
        import apps.payroll.signals
