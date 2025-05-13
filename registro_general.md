# Registro General de Cambios - RH Plus

## Commit: Configuración del entorno de base de datos y modelo de usuario personalizado
**Fecha:** 12 de mayo de 2025

### Resumen General

Se ha implementado la configuración necesaria para conectar la aplicación Django a la base de datos alojada en Render y se ha solucionado el problema de conflictos en el modelo de usuario personalizado. Se han realizado modificaciones en la estructura de archivos, configuración de Django y migraciones, permitiendo el correcto despliegue del backend.

### 1. Configuración de Base de Datos

#### 1.1 Conexión con Base de Datos Remota
Se ha implementado la configuración para conectar la aplicación a la base de datos PostgreSQL alojada en Render:

- Se agregó la carga de variables de entorno desde el archivo `.env` utilizando `python-dotenv`
- Se configuró el parseo de la URL de conexión para obtener los parámetros de la base de datos
- Se implementó un sistema de fallback para desarrollo local cuando no existe la variable de entorno

```python
# Ejemplo de configuración implementada en settings.py
import dotenv
from urllib.parse import urlparse

# Cargar variables de entorno desde el archivo .env
dotenv.load_dotenv(os.path.join(BASE_DIR, '.env'))

# Obtener la URL de la base de datos desde las variables de entorno
DATABASE_URL = os.environ.get('DATABASE_URL')

if DATABASE_URL:
    # Parse la URL de la base de datos
    db_url = urlparse(DATABASE_URL)
    
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': db_url.path[1:],
            'USER': db_url.username,
            'PASSWORD': db_url.password,
            'HOST': db_url.hostname,
            'PORT': db_url.port,
        }
    }
```

#### 1.2 Solución temporal para desarrollo
Se implementó una solución temporal utilizando SQLite para facilitar el desarrollo y solucionar problemas de migración:

```python
# Configuración temporal para desarrollo con SQLite
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}
```

### 2. Solución de conflictos con el modelo de Usuario personalizado

#### 2.1 Configuración del modelo de usuario personalizado
Se configuró correctamente el modelo de usuario personalizado, solucionando los conflictos de accesores inversos:

- Se agregó la configuración `AUTH_USER_MODEL = 'core.User'` en `settings.py`
- Se modificó el orden de las aplicaciones en `INSTALLED_APPS` para cargar primero la app `core`
- Se agregaron `related_name` personalizados a los campos `groups` y `user_permissions` del modelo `User`

```python
# Modificación del modelo User en core/models.py
class User(AbstractUser):
    # ...existing code...
    groups = models.ManyToManyField(
        'auth.Group',
        verbose_name='groups',
        blank=True,
        help_text='The groups this user belongs to.',
        related_name='core_user_set',  # Nombre personalizado para evitar conflictos
        related_query_name='core_user',
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        verbose_name='user permissions',
        blank=True,
        help_text='Specific permissions for this user.',
        related_name='core_user_set',  # Nombre personalizado para evitar conflictos
        related_query_name='core_user',
    )
```

#### 2.2 Estructura de migraciones
Se creó la estructura necesaria para las migraciones:

- Creación del directorio `migrations` en la app `core`
- Creación de una migración inicial para el modelo `User` personalizado
- Configuración adecuada de las dependencias de migración

### 3. Estado Actual y Próximos Pasos

#### 3.1 Estado Actual
- **Conexión a base de datos**: ✅ Configurada para entorno de desarrollo y producción
- **Modelo de usuario personalizado**: ✅ Configurado correctamente
- **Migraciones**: ✅ Estructura básica implementada

#### 3.2 Próximos Pasos
1. **Backend**:
   - Completar las migraciones para todos los módulos
   - Implementar endpoints REST completos
   - Añadir validaciones de datos
   - Implementar autenticación JWT

2. **Integración**:
   - Configurar las conexiones del frontend al backend
   - Realizar pruebas de integración

### 4. Aspectos Técnicos Destacados

#### 4.1 Decisiones Técnicas
1. **Uso de python-dotenv**: Para gestionar variables de entorno sensibles como credenciales de base de datos
2. **Uso temporal de SQLite**: Para facilitar el desarrollo y resolución de problemas de migración
3. **Configuración de related_name personalizados**: Para evitar conflictos entre el modelo de usuario personalizado y el predeterminado de Django

#### 4.2 Mejoras en Seguridad
- Separación de credenciales de base de datos en archivo `.env` fuera del control de versiones
- Uso de URL de conexión completa en lugar de componentes individuales para simplificar la configuración

### 5. Conclusiones

Los cambios implementados han permitido solucionar los problemas iniciales en la configuración de la base de datos y el modelo de usuario personalizado, estableciendo una base sólida para continuar con el desarrollo del backend. La separación de configuración para entornos de desarrollo y producción facilitará el despliegue y la escalabilidad del proyecto.

## Commit Inicial: Creación de la Estructura Base del Proyecto
**Fecha:** 12 de mayo de 2025

### Resumen General

Se ha implementado la estructura base del proyecto RH Plus, un sistema completo de gestión de Recursos Humanos con arquitectura modular. El proyecto sigue un diseño backend con Django y frontend con Flutter, implementando patrones de diseño MVC, Observador y Repositorio para lograr un código mantenible y escalable.

### 1. Estructura del Proyecto

#### 1.1 Organización de Carpetas
La estructura general del proyecto quedó organizada de la siguiente manera:

```
rh_plus/
├── backend/              # Proyecto Django
│   ├── manage.py
│   ├── config/           # Configuración global
│   ├── apps/             # Aplicaciones Django modulares
│   └── requirements.txt
├── frontend/             # Aplicación Flutter
│   ├── lib/
│   │   ├── main.dart      
│   │   ├── models/        
│   │   ├── services/      
│   │   ├── providers/     
│   │   ├── views/         
│   │   └── utils/         
│   └── pubspec.yaml
└── docs/
    └── arquitectura.md    
```

Esta estructura separa claramente las responsabilidades: backend para la lógica de negocio y API, y frontend para la presentación y experiencia de usuario.

### 2. Backend (Django)

#### 2.1 Aplicaciones Django
Se crearon seis aplicaciones modulares, cada una encapsulando una funcionalidad específica del sistema de RRHH:

1. **core**: Gestión de usuarios, roles, permisos y autenticación
   - `models.py`: Definición del modelo User y Role
   - `views.py`: Endpoints para autenticación y gestión de usuarios
   - `serializers.py`: Serializadores para conversión de datos
   - `repositories.py`: Implementación del patrón Repositorio para abstracción de datos

2. **selection**: Flujo de selección de candidatos
   - `models.py`: Modelos para Candidate, InterviewPhase, EvaluationForm
   - `views.py`: Endpoints para gestión de procesos de selección
   - `signals.py`: Implementación del patrón Observador para notificaciones

3. **affiliation**: Afiliaciones y gestión de empleados
   - `models.py`: Modelos para Employee, HealthProvider, PensionFund
   - `views.py`: Endpoints para gestión de afiliaciones
   - `serializers.py`: Conversión de datos de empleados y afiliaciones

4. **payroll**: Nómina y liquidaciones
   - `models.py`: Modelos para Contract, PayrollPeriod, PayrollEntry
   - `views.py`: Endpoints para gestión de nómina
   - `signals.py`: Cálculos automáticos de nómina mediante observadores
   
   Se implementó una estructura robusta con clases clave:
   - `Contract`: Contratos laborales con tipos, fechas y salario
   - `PayrollPeriod`: Períodos de nómina con fechas y estado
   - `PayrollItem`: Conceptos de nómina (ingresos o deducciones)
   - `PayrollEntry`: Registro de nómina para un empleado en un período
   - `PayrollEntryDetail`: Detalles de cada concepto en una nómina
   
   Se añadieron señales (signals) para implementar cálculos automáticos siguiendo el patrón Observador.

5. **performance**: Evaluación de desempeño
   - `models.py`: Modelos para Performance, Goal, Evaluation
   - `views.py`: Endpoints para gestión de evaluaciones

6. **training**: Inducción y capacitación
   - `models.py`: Modelos para TrainingProgram, TrainingSession, TrainingAttendance
   - `views.py`: Endpoints para gestión de programas de capacitación
   
   Se implementaron clases clave:
   - `TrainingType`: Tipos de capacitación (inducción, desarrollo de habilidades)
   - `TrainingProgram`: Programas de capacitación con objetivos y materiales
   - `TrainingSession`: Sesiones individuales con ubicación, instructor y participantes
   - `TrainingAttendance`: Registro de asistencia de empleados a sesiones
   - `TrainingEvaluation`: Evaluaciones de las capacitaciones recibidas

#### 2.2 Configuración 
En la carpeta `config/`:
- `settings.py`: Configuración general del proyecto Django
- `urls.py`: Configuración de rutas principales
- `wsgi.py`: Configuración para despliegue

#### 2.3 Implementación de Patrones de Diseño
1. **MVC**: 
   - Modelos en `models.py` 
   - Vistas/controladores en `views.py`
   - Plantillas (frontend separado)

2. **Repositorio**: 
   - Implementado en `repositories.py` de cada app
   - Abstracción del acceso a datos para facilitar pruebas y mantenimiento

3. **Observador**:
   - Implementado con Django signals en `signals.py`
   - Permite reaccionar a cambios en modelos (ej: cálculo automático de totales en nómina)

### 3. Frontend (Flutter)

#### 3.1 Estructura de Carpetas
Se estableció una arquitectura organizada por características:

- `models/`: Clases de datos para comunicación con API
- `services/`: Servicios para consumo de API REST
- `providers/`: Gestión de estado (State Management)
- `views/`: Interfaces de usuario
- `utils/`: Utilidades y constantes

#### 3.2 Modelos de Datos
Se crearon modelos para cada entidad principal:

1. **Módulo de Usuarios**:
   - `user_model.dart`: Modelo de usuario para autenticación

2. **Módulo de Candidatos**:
   - `candidate_model.dart`: Modelo de candidatos para procesos de selección

3. **Módulo de Empleados**:
   - `employee_model.dart`: Modelo de empleados activos

4. **Módulo de Nómina**:
   - `payroll_models.dart`: Modelos para contratos, períodos y entradas de nómina
   
   Incluye:
   - `ContractModel`: Para gestión de contratos laborales
   - `PayrollPeriodModel`: Para períodos de nómina
   - `PayrollEntryModel`: Para registros de nómina
   - `PayrollEntryDetailModel`: Para detalles de cada concepto de nómina

5. **Módulo de Capacitación**:
   - `training_models.dart`: Modelos para programas, sesiones y asistencias
   
   Incluye:
   - `TrainingProgramModel`: Para programas de capacitación
   - `TrainingSessionModel`: Para sesiones programadas
   - `TrainingAttendanceModel`: Para registros de asistencia

#### 3.3 Servicios
Se implementaron servicios para comunicación con el backend:

1. **Servicios de Autenticación**:
   - `auth_service.dart`: No implementado en este commit

2. **Servicios de Empleados y Candidatos**:
   - `employee_service.dart`: Servicios para gestión de empleados
   - `candidate_service.dart`: Servicios para gestión de candidatos

3. **Servicios de Nómina**:
   - `payroll_service.dart`: Implementación completa de servicios para:
     - Obtener contratos
     - Obtener períodos de nómina
     - Obtener entradas de nómina por período o empleado

4. **Servicios de Capacitación**:
   - `training_service.dart`: Implementación completa de servicios para:
     - Obtener programas de capacitación
     - Obtener sesiones programadas o por programa
     - Obtener registros de asistencia por sesión o empleado

#### 3.4 Providers (Gestión de Estado)
Se implementaron providers utilizando el patrón Provider:

1. **Auth Provider**:
   - `auth_provider.dart`: Para gestión de autenticación

2. **Employee y Candidate Providers**:
   - `employee_provider.dart`: Para gestión del estado de empleados
   - `candidate_provider.dart`: Para gestión del estado de candidatos

3. **Payroll Provider**:
   - `payroll_provider.dart`: Implementación completa para gestión de:
     - Lista de contratos
     - Períodos de nómina
     - Entradas de nómina
     - Selección de contratos, períodos y entradas

4. **Training Provider**:
   - `training_provider.dart`: Implementación completa para gestión de:
     - Programas de capacitación
     - Sesiones programadas
     - Asistencias
     - Estadísticas de asistencia

#### 3.5 Vistas (UI)
Se implementaron las siguientes pantallas:

1. **Autenticación**:
   - `login_screen.dart`: Pantalla de inicio de sesión

2. **Dashboard**:
   - `dashboard_screen.dart`: Panel principal con navegación y resumen

3. **Módulo de Nómina**:
   - `payroll_dashboard_screen.dart`: Dashboard de nómina con:
     - Selector de períodos
     - Lista de entradas de nómina
     - Resumen de totales
   - `payroll_entry_detail_screen.dart`: Detalles de una entrada de nómina con:
     - Información del empleado
     - Sección de devengos
     - Sección de deducciones
     - Resumen de totales
     - Funcionalidad de aprobación

4. **Módulo de Capacitación**:
   - `training_dashboard_screen.dart`: Dashboard de capacitación con:
     - Pestaña de sesiones programadas
     - Pestaña de programas de capacitación
   - `training_session_detail_screen.dart`: Detalles de una sesión con:
     - Información general
     - Estadísticas de asistencia
     - Lista de asistentes

#### 3.6 Configuración y Navegación
- `constants.dart`: Definición de URLs de API, rutas y strings
- `main.dart`: Configuración de la aplicación, providers y rutas

### 4. Documentación

#### 4.1 Documentación de Arquitectura
- `docs/arquitectura.md`: Documento explicando la arquitectura, módulos y patrones de diseño

#### 4.2 README
- `README.md`: Documentación completa de instalación, configuración y despliegue

### 5. Estado Actual y Próximos Pasos

#### 5.1 Estado Actual
- **Backend**: Estructura completa con modelos definidos. Pendiente implementar más lógica de negocio y endpoints.
- **Frontend**: Estructura completa con modelos, servicios, providers y pantallas principales.

#### 5.2 Módulos Completados
- **Estructura General**: ✅ Completa
- **Core (Usuarios)**: ⚠️ Parcial - Modelos básicos
- **Selection (Candidatos)**: ⚠️ Parcial - Modelos básicos
- **Affiliation (Empleados)**: ⚠️ Parcial - Modelos básicos
- **Payroll (Nómina)**: ✅ Modelos y UI implementados
- **Performance (Desempeño)**: ⚠️ Parcial - Solo estructura
- **Training (Capacitación)**: ✅ Modelos y UI implementados

#### 5.3 Próximos Pasos
1. **Backend**:
   - Implementar endpoints REST completos
   - Añadir validaciones de datos
   - Implementar autenticación JWT
   - Crear migraciones iniciales
   - Configurar tests

2. **Frontend**:
   - Completar la implementación de autenticación
   - Desarrollar pantallas para módulos de candidatos y empleados
   - Añadir validaciones de formularios
   - Implementar manejo de errores

3. **Integración y Pruebas**:
   - Configurar entorno de pruebas
   - Implementar pruebas unitarias e integración
   - Realizar pruebas end-to-end

### 6. Aspectos Técnicos Destacados

#### 6.1 Patrones Implementados
- **MVC**: Separación clara de responsabilidades en backend y frontend
- **Repository**: Abstracción del acceso a datos en backend
- **Observer**: Uso de signals en Django y ChangeNotifier en Flutter
- **Provider**: Gestión de estado en Flutter

#### 6.2 Decisiones Técnicas
1. **Django REST Framework**: Elegido para API por su robustez y facilidad de uso
2. **Flutter**: Elegido para frontend por permitir desarrollo multiplataforma
3. **PostgreSQL**: Base de datos recomendada por su soporte para transacciones y relaciones complejas

### 7. Conclusiones

Este commit inicial establece una base sólida para el desarrollo del sistema RH Plus con una estructura modular y escalable. La arquitectura implementada permite:

1. **Mantenibilidad**: Separación clara de responsabilidades
2. **Escalabilidad**: Estructura modular por funcionalidades
3. **Testabilidad**: Patrones que facilitan las pruebas unitarias
4. **Reutilización**: Componentes genéricos compartidos

Los próximos pasos se centrarán en completar la implementación de cada módulo y añadir funcionalidades específicas, manteniendo los principios arquitectónicos establecidos.