# Generated by Django 4.2.10 on 2025-05-18 20:52

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('core', '0003_alter_user_username'),
    ]

    operations = [
        migrations.CreateModel(
            name='SystemActivity',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=200, verbose_name='Título')),
                ('description', models.TextField(verbose_name='Descripción')),
                ('type', models.CharField(choices=[('employee', 'Empleado'), ('candidate', 'Candidato'), ('payroll', 'Nómina'), ('training', 'Capacitación'), ('performance', 'Desempeño')], max_length=20, verbose_name='Tipo')),
                ('timestamp', models.DateTimeField(auto_now_add=True, verbose_name='Fecha y hora')),
                ('created_by', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='activities_created', to=settings.AUTH_USER_MODEL, verbose_name='Creado por')),
            ],
            options={
                'verbose_name': 'Actividad del sistema',
                'verbose_name_plural': 'Actividades del sistema',
                'ordering': ['-timestamp'],
            },
        ),
    ]
