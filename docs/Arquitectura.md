# RH plus
## Guía de Arquitectura y Estructura de Proyecto: RH plus

**Contexto y Propósito**
Este documento sirve como guía principal para el desarrollo de la aplicación RH plus, una solución de gestión de Recursos Humanos construida con Django en el backend y Flutter en el frontend. Aquí se especifica la arquitectura general, los módulos necesarios, la relación entre ellos y la base de datos, además de los patrones de diseño MVC, Observador y Repositorio.

---

### 1. Objetivo y Alcance

* **Objetivo**: Determinar las disposiciones necesarias para gestionar la vinculación, desarrollo y permanencia del personal, conforme a las necesidades y requisitos de la empresa.
* **Alcance**: Desde la selección y contratación del personal hasta su capacitación continua y seguimiento de desempeño.

---

### 2. Visión General de la Arquitectura

1. **Frontend (Flutter)**

   * Presentación de datos, formularios y navegación.
   * Comunicación vía API REST/GraphQL con el backend.
2. **Backend (Django)**

   * Lógica de negocio, API y acceso a la base de datos.
   * Estructurado en múltiples apps (módulos) independientes.
3. **Base de Datos Relacional**

   * PostgreSQL (recomendado) con esquemas normalizados.
4. **Patrones de Diseño**

   * **MVC**: Separación clara entre Modelos (Django ORM / Flutter Providers), Vistas y Controladores.
   * **Observador**: Eventos en tiempo real para notificaciones y actualizaciones instantáneas.
   * **Repository**: Abstracción del acceso a datos en Django para desacoplar la lógica de negocio.

---

### 3. Estructura General del Proyecto

```
rh_plus/
├── backend/              # Proyecto Django
│   ├── manage.py
│   ├── config/           # Configuración global (settings, urls, wsgi)
│   ├── apps/             # Aplicaciones Django
│   │   ├── selection/    # Selección y contratación
│   │   ├── affiliation/  # Afiliaciones a seguridad social
│   │   ├── payroll/      # Nómina y liquidaciones
│   │   ├── performance/  # Evaluación de desempeño
│   │   ├── training/     # Inducción y capacitación
│   │   └── core/         # Usuarios, roles y autenticación
│   └── requirements.txt
├── frontend/             # Aplicación Flutter
│   ├── lib/
│   │   ├── main.dart      
│   │   ├── models/        # Clases de datos (DTOs)
│   │   ├── services/      # Repositorios y consumo de API
│   │   ├── providers/     # State management (Observer)
│   │   ├── views/         # Pantallas y widgets UI
│   │   └── utils/         # Constantes, helpers
│   └── pubspec.yaml
└── docs/
    └── arquitectura.md    # Esta guía
```

```
backend/apps/
├── affiliation/
│   │   __init__.py
│   │   admin.py
│   │   apps.py
│   │   models.py
│   │   repositories.py
│   │   serializers.py
│   │   signals.py
│   │   urls.py
│   │   views.py
│   │
│   └── migrations/
│           __init__.py
│           0001_initial.py
│           0002_alter_affiliation_employee.py
│
├── core/
│   │   __init__.py
│   │   admin.py
│   │   apps.py
│   │   models.py
│   │   repositories.py
│   │   serializers.py
│   │   signals.py
│   │   urls.py
│   │   utils.py
│   │   views.py
│   │
│   ├── management/
│   │   └── commands/
│   │
│   ├── migrations/
│   │       __init__.py
│   │       0001_initial.py
│   │       0002_alter_user_username_alter_userrole_unique_together.py
│   │       0003_alter_user_username.py
│   │       0004_systemactivity.py
│   │       0005_user_department_user_manager_user_role.py
│   │
│   ├── models/
│   │       activity.py
│   │
│   ├── serializers/
│   │
│   └── views/
│
├── payroll/
│   │   __init__.py
│   │   admin.py
│   │   apps.py
│   │   models.py
│   │   repositories.py
│   │   serializers.py
│   │   signals.py
│   │   urls.py
│   │   views.py
│   │
│   └── migrations/
│           __init__.py
│           0001_initial.py
│
├── performance/
│   │   __init__.py
│   │   admin.py
│   │   apps.py
│   │   models.py
│   │   repositories.py
│   │   serializers.py
│   │   signals.py
│   │   urls.py
│   │   views.py
│   │
│   └── migrations/
│           __init__.py
│           0001_initial.py
│
├── selection/
│   │   __init__.py
│   │   admin.py
│   │   apps.py
│   │   models.py
│   │   repositories.py
│   │   serializers.py
│   │   signals.py
│   │   urls.py
│   │   views.py
│   │
│   └── migrations/
│           __init__.py
│           0001_initial.py
│           0002_alter_candidate_current_stage.py
│
└── training/
    │   __init__.py
    │   admin.py
    │   apps.py
    │   logging.py
    │   models.py
    │   repositories.py
    │   serializers.py
    │   signals.py
    │   urls.py
    │   views.py
    │
    └── migrations/
            __init__.py
            0001_initial.py
```


```
lib/
│   main.dart
│
├── models/
│   │   affiliation_models.dart
│   │   candidate_model.dart
│   │   employee_model.dart
│   │   payroll_models.dart
│   │   selection_models.dart
│   │   training_models.dart
│   │   user_model.dart
│   │
│   ├── affiliation/
│   └── payroll/
│
├── providers/
│       activity_provider.dart
│       affiliation_provider.dart
│       auth_provider.dart
│       candidate_provider.dart
│       dashboard_provider.dart
│       employee_provider.dart
│       payroll_provider.dart
│       selection_provider.dart
│       training_provider.dart
│       user_management_provider.dart
│
├── routes/
│       app_routes.dart
│
├── services/
│       activity_service.dart
│       affiliation_service.dart
│       candidate_service.dart
│       employee_service.dart
│       payroll_service.dart
│       selection_service.dart
│       training_service.dart
│       user_service.dart
│
├── utils/
│       constants.dart
│
├── views/
│   │   dashboard_screen.dart
│   │   login_screen.dart
│   │   register_screen.dart
│   │   user_management_screen.dart
│   │
│   ├── affiliation/
│   │       affiliation_form_screen.dart
│   │       affiliation_main_screen.dart
│   │       employee_affiliations_screen.dart
│   │       index.dart
│   │
│   ├── debug/
│   │       token_debug_screen.dart
│   │
│   ├── payroll/
│   │   │   payroll_dashboard_screen.dart
│   │   │   payroll_entry_detail_screen.dart
│   │   │
│   │   └── widgets/
│   │
│   ├── selection/
│   │       candidate_detail_view.dart
│   │       candidate_form.dart
│   │       candidate_list_view.dart
│   │       stage_list_view.dart
│   │
│   ├── training/
│   │   │   training_dashboard_screen.dart
│   │   │   training_main_screen.dart
│   │   │   training_session_detail_screen.dart
│   │   │
│   │   ├── forms/
│   │   │       program_form_screen.dart
│   │   │       session_form_screen.dart
│   │   │
│   │   ├── management/
│   │   │       attendance_management_screen.dart
│   │   │
│   │   ├── reports/
│   │   │       training_reports_screen.dart
│   │   │
│   │   └── widgets/
│   │           admin_training_view.dart
│   │           employee_training_view.dart
│   │           hr_training_view.dart
│   │           program_card.dart
│   │           session_card.dart
│   │           supervisor_training_view.dart
│   │           training_stats_card.dart
│   │           user_training_view.dart
│   │
│   └── user_management/
│
└── widgets/
        error_dialog.dart
        loading_state_widget.dart
```

---

### 4. Módulos del Backend y Funciones

| Módulo (App)    | Responsabilidad principal                                          |
| --------------- | ------------------------------------------------------------------ |
| **core**        | Gestión de usuarios, roles, permisos y autenticación.              |
| **selection**   | Flujo de selección: requisitos, preselección, entrevistas, pruebas |
| **affiliation** | Afiliaciones ARL, EPS, pensión, cajas de compensación.             |
| **payroll**     | Novedades, liquidación de nómina, contratos, aportes sociales.     |
| **performance** | Evaluaciones de desempeño, reportes y planes de mejora.            |
| **training**    | Inducción, reinducción, planes de capacitación y seguimiento.      |

Cada app sigue la estructura MVC:

```
apps/<app>/
├── models.py       # Definición de entidades y relaciones (Django ORM)
├── repositories.py # Clases Repository para acceso a datos
├── serializers.py  # Convertidores Model <-> JSON
├── views.py        # Controladores (API endpoints)
├── urls.py         # Rutas específicas del módulo
└── signals.py      # Observador: listeners de eventos
```

---

### 5. Modelos y Relaciones en la Base de Datos

* **Usuario** ― Role (N:1)
* **Empleado** ― Usuario (1:1)
* **Candidato** ― Etapas de selección (1\:N)
* **Contrato** ― Empleado (1\:N)
* **MovimientoNómina** ― Contrato (N:1)
* **Evaluación** ― Empleado (N:1)
* **Capacitación** ― Empleado (N\:M)

> **Tip**: Definir llaves foráneas con `on_delete=PROTECT` o `on_delete=CASCADE` según la regla de negocio.

---

### 6. Implementación de Patrones de Diseño

#### 6.1 MVC

* **Model**: `models.py`, ORM.
* **View/Controller**: `views.py` exponen API REST con Django REST Framework.
* **Template (UI)**: Flutter widgets consumiendo la API.

#### 6.2 Observador (Observer)

* Utilizar Django Signals:

```python
# signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Evaluacion

@receiver(post_save, sender=Evaluacion)
def notificar_evaluacion(sender, instance, created, **kwargs):
    if created:
        # Lógica notificación en tiempo real via WebSocket o push
        pass
```

* En Flutter, usar `ChangeNotifier` y `Provider` para actualizar vistas.

#### 6.3 Repositorio (Repository)

* Encapsular consultas en clases:

```python
# repositories.py
from .models import Empleado

class EmpleadoRepository:
    @staticmethod
    def get_activos():
        return Empleado.objects.filter(estado='ACTIVO')
    
    @staticmethod
    def by_id(emp_id):
        return Empleado.objects.get(id=emp_id)
```

* En servicios Flutter, llamar a endpoints que exponen repositorios.

---

### 7. Integración Frontend-Backend

1. **Autenticación**: JWT con Django REST Framework + `flutter_secure_storage`.
2. **Comunicación**: `http` o `dio` en Flutter para consumir APIs.
3. **Estado y Eventos**: `Provider` + `StreamControllers` para observar cambios.
4. **Repositorios Flutter**:

```dart
class EmpleadoRepository {
  final ApiClient api;
  EmpleadoRepository(this.api);

  Future<List<Empleado>> fetchActivos() async {
    final resp = await api.get('/empleados/activos/');
    return resp.map((j) => Empleado.fromJson(j)).toList();
  }
}
```

---

### 8. Conclusiones y Pasos Siguientes

1. Crear repositorios Git monorepo con carpetas `backend/` y `frontend/`.
2. Configurar entornos virtuales y CI/CD (GitHub Actions).
3. Implementar primer módulo: `core` (autenticación y usuarios).
4. Definir esquemas de la base de datos y migraciones iniciales.
5. Comenzar desarrollo iterativo con sprints de 2 semanas.

> *Con esta guía, el equipo cuenta con una visión clara de los componentes, flujos y patrones para construir RH plus de forma organizada y escalable.*
