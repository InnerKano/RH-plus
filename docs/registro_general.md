# Commit: Configuración de PostgreSQL en Render y eliminación del uso de SQLite

**Fecha:** 13 de mayo de 2025

## Resumen General

Se ha optimizado la configuración para el uso exclusivo de PostgreSQL como base de datos del proyecto, estableciendo la conexión con la base de datos alojada en Render mediante variables de entorno. Se eliminaron todas las referencias a SQLite y se estableció una estructura completa de migraciones para todas las aplicaciones, garantizando un despliegue correcto y consistente.

## 1. Cambios en la Configuración de Base de Datos

### 1.1 Configuración exclusiva para PostgreSQL
Se modificó settings.py para utilizar únicamente PostgreSQL, eliminando toda referencia a SQLite:

```python
# Database configuration
DATABASE_URL = os.environ.get('DATABASE_URL')

if DATABASE_URL:
    # Parse database URL
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
else:
    # Fallback configuration for local development
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': 'rhplus',
            'USER': 'postgres',
            'PASSWORD': 'postgres',
            'HOST': 'localhost',
            'PORT': '5432',
        }
    }
```

### 1.2 Carga dinámica de variables de entorno
Se actualizó la configuración para cargar dinámicamente las variables de entorno relacionadas con despliegue:

```python
SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-your-secret-key-here')
DEBUG = os.environ.get('DEBUG', 'True').lower() == 'true'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',') or []
```

## 2. Estructura de Migraciones

### 2.1 Creación de estructura de migraciones para todas las apps
Se crearon directorios de migraciones para todas las aplicaciones del proyecto:

- `core/migrations/`
- `affiliation/migrations/`
- `payroll/migrations/`
- `performance/migrations/`
- `selection/migrations/`
- `training/migrations/`

En cada directorio se incluyó un archivo `__init__.py` para garantizar la correcta detección de los paquetes de migración por Django.

## 3. Variables de Entorno

### 3.1 Extensión del archivo .env
Se ampliaron las variables de entorno en el archivo .env para incluir configuraciones necesarias para producción:

```
# Database configuration for Render
DATABASE_URL=postgresql://db_rhplus_user:jGOTbYCzw2NDfiBuhMFn1dxFj7pW6h4w@dpg-d0hbnoqdbo4c73dki3ag-a.oregon-postgres.render.com/db_rhplus

# Production environment variables
DEBUG=False
SECRET_KEY=django-insecure-replace-with-secure-secret-key-in-production
ALLOWED_HOSTS=.render.com,localhost,127.0.0.1
```

## 4. Documentación

### 4.1 Actualización de README.md
Se actualizó la documentación del proyecto para reflejar el uso exclusivo de PostgreSQL:

- Se eliminaron referencias a SQLite
- Se actualizó la sección de despliegue con instrucciones específicas para Render
- Se agregaron pasos para la correcta aplicación de migraciones

### 4.2 Actualización de la guía de resolución de problemas
Se actualizó la sección de resolución de problemas con soluciones específicas para problemas con el modelo de usuario personalizado y la base de datos PostgreSQL.

## 5. Estado Actual

### 5.1 Componentes implementados
- **Base de datos PostgreSQL**: ✅ Configuración completa para conexión a Render
- **Variables de entorno**: ✅ Configuración para entorno de desarrollo y producción
- **Migraciones**: ✅ Estructura completa para todas las aplicaciones
- **Despliegue**: ✅ Configuración para despliegue en Render

### 5.2 Próximos pasos
- Desplegar la aplicación en Render
- Completar la implementación de los endpoints API REST
- Configurar la autenticación JWT
- Conectar el frontend Flutter con la API desplegada

## 6. Decisiones Técnicas

### 6.1 Elección de PostgreSQL como única base de datos
Se optó por utilizar exclusivamente PostgreSQL debido a:
- Mejor rendimiento y escalabilidad para aplicaciones empresariales
- Soporte avanzado para relaciones complejas y consultas especializadas
- Compatibilidad con los servicios de Render para despliegue

### 6.2 Estructura de despliegue
Se configuró la aplicación para un despliegue optimizado en Render:
- Variables de entorno para configuración dinámica
- Estructura de migraciones compatible con el proceso de despliegue automático
- Fallback para desarrollo local sin necesidad de cambios en el código

Similar code found with 1 license type

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

#### 1.2 Configuración para desarrollo local
Se implementó un sistema de fallback para entornos de desarrollo local que no tienen acceso a la base de datos remota:

```python
# Configuración fallback para desarrollo local
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'rhplus',
        'USER': 'postgres',
        'PASSWORD': 'postgres',
        'HOST': 'localhost',
        'PORT': '5432',
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
Se creó la estructura necesaria para las migraciones en todas las aplicaciones:

- Creación del directorio `migrations` en todas las apps (`core`, `affiliation`, `payroll`, `performance`, `selection` y `training`)
- Creación de archivos `__init__.py` en cada directorio de migraciones
- Creación de una migración inicial para el modelo `User` personalizado
- Configuración adecuada de las dependencias de migración para asegurar el orden correcto

### 3. Estado Actual y Próximos Pasos

#### 3.1 Estado Actual
- **Conexión a base de datos**: ✅ Configurada para entorno de producción en Render
- **Modelo de usuario personalizado**: ✅ Configurado correctamente
- **Migraciones**: ✅ Estructura completa implementada en todas las aplicaciones
- **Despliegue**: ✅ Archivos de configuración y variables de entorno para Render configuradas

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
2. **Uso exclusivo de PostgreSQL**: Para aprovechar todas las características avanzadas necesarias para el sistema
3. **Configuración de related_name personalizados**: Para evitar conflictos entre el modelo de usuario personalizado y el predeterminado de Django

#### 4.2 Mejoras en Seguridad
- Separación de credenciales de base de datos en archivo `.env` fuera del control de versiones
- Uso de URL de conexión completa en lugar de componentes individuales para simplificar la configuración

### 5. Configuraciones adicionales para despliegue

#### 5.1 Archivos de configuración para despliegue
Se han creado los siguientes archivos para facilitar el despliegue en plataformas como Render:
ELIMINADO PROCFILE Y RUNTIME.TXT:
   1. **Procfile**: Configuración para servidores que siguen el estándar de Heroku/Render:
   ```
   web: gunicorn config.wsgi:application --log-file -
   ```

   2. **runtime.txt**: Especificación de la versión de Python requerida:
   ```
   python-3.13.0
   ```

3. **Variables de entorno**: Se han agregado variables adicionales al archivo `.env`:
   ```
   DEBUG=False
   SECRET_KEY=django-insecure-replace-with-secure-secret-key-in-production
   ALLOWED_HOSTS=.render.com,localhost,127.0.0.1
   ```

4. **Configuración de settings.py**: Se ha modificado para cargar dinámicamente las variables de entorno:
   ```python
   SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-your-secret-key-here')
   DEBUG = os.environ.get('DEBUG', 'True').lower() == 'true'
   ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',') or []
   ```

### 6. Conclusiones

Los cambios implementados han permitido solucionar los problemas iniciales en la configuración de la base de datos y el modelo de usuario personalizado, estableciendo una base sólida para continuar con el desarrollo del backend. La configuración específica para Render permitirá un despliegue sencillo y consistente, mientras que la estructura de migraciones completa facilitará la inicialización correcta de la base de datos en producción.

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


# Fix: Solución a Problema de Inicialización y Carga Después del Login
**Fecha:** 13 de mayo de 2025

## Problema
El sistema permitía la autenticación (se obtenía el token correctamente), pero después de iniciar sesión la aplicación se quedaba cargando indefinidamente sin mostrar el dashboard.

## Cambios Realizados

### 1. Corregido Tipo de Provider en main.dart
* **Ubicación**: main.dart
* **Problema**: Se estaban utilizando `ProxyProvider` para proveedores que extienden de `ChangeNotifier`
* **Solución**: Reemplazados por `ChangeNotifierProxyProvider` para mantener la funcionalidad de notificación
* **Detalle**: Esto garantiza que los providers puedan notificar cambios de estado correctamente, permitiendo que la interfaz se actualice cuando hay cambios en el modelo

```dart
// Antes
ProxyProvider<AuthProvider, EmployeeProvider>(
  update: (_, auth, __) => EmployeeProvider(token: auth.token ?? ''),
)

// Después
ChangeNotifierProxyProvider<AuthProvider, EmployeeProvider>(
  create: (_) => EmployeeProvider(token: ''),
  update: (_, auth, previousProvider) => 
    EmployeeProvider(token: auth.token ?? ''),
)
```

### 2. Mejorado Sistema de Logging
* **Ubicación**: auth_provider.dart
* **Problema**: Faltaba información de depuración para diagnosticar problemas en el flujo de autenticación
* **Solución**: Agregado logging detallado en los métodos `login()`, `loadUserFromToken()` y `_fetchUserData()`
* **Detalle**: Se agregaron logs para rastrear todo el proceso de autenticación, mostrando información sobre:
  - Intentos de inicio de sesión
  - Respuestas del servidor
  - Estado de los tokens
  - Éxito/fallo en la carga de datos del usuario

### 3. Verificación de Configuración de URL
* **Ubicación**: constants.dart
* **Problema**: Posibles discrepancias entre URLs esperadas y configuradas
* **Solución**: Confirmada la configuración correcta de `userProfileUrl` como `$baseUrl/api/core/users/me/`
* **Detalle**: Asegura que el frontend esté apuntando al endpoint correcto en el backend para obtener los datos del usuario

### 4. Implementación de Navegación después del Logout
* **Ubicación**: dashboard_screen.dart
* **Problema**: No se redirigía al usuario a la pantalla de login después de cerrar sesión
* **Solución**: Agregada navegación explícita y logging al cerrar sesión
* **Detalle**: Ahora después de cerrar sesión, la aplicación redirecciona automáticamente al usuario a la pantalla de login

```dart
onPressed: () async {
  await authProvider.logout();
  if (mounted) {
    Navigator.pushReplacementNamed(context, RouteNames.login);
    if (kDebugMode) {
      print('Sesión cerrada, navegando al login');
    }
  }
}
```

## Estructura de Datos Verificada
* **UserModel**: Confirmado que el modelo `UserModel` tiene correctamente implementado el getter `fullName` para mostrar el nombre completo del usuario
* **Serializers**: Verificada la estructura del serializador en el backend para asegurar compatibilidad con el modelo del frontend

## Beneficios
- **Mayor Fiabilidad**: La aplicación ahora maneja correctamente el estado de autenticación
- **Mejor Experiencia**: Flujo completo de inicio y cierre de sesión sin problemas
- **Facilidad de Diagnóstico**: Logs detallados que facilitan la identificación de problemas futuros
- **Coherencia de Datos**: Garantía de que el modelo de usuario se carga correctamente después del login

## Pruebas Realizadas
- Verificado el proceso completo de inicio de sesión
- Confirmado que el usuario es redirigido correctamente al dashboard
- Comprobado que el cierre de sesión funciona y redirige al login

Voy a analizar el módulo `affiliation` para documentar su estructura y funcionalidades en formato de commit, lo que nos ayudará a entender su lógica actual, identificar posibles bugs y planificar mejoras futuras.

Primero, vamos a examinar los archivos principales del módulo para entender su estructura y funcionalidad. 

Ahora veamos las vistas para entender cómo se manejan las operaciones CRUD: 

Revisemos los serializadores para entender cómo se transforman los datos: 


Veamos también los repositorios para entender la lógica de negocio: 

Por último, revisemos las URLs para entender cómo se accede a las diferentes funcionalidades: 

Con base en el análisis de los archivos del módulo `affiliation`, he preparado la siguiente documentación en formato commit:

# Módulo de Afiliación (Affiliation)

## Estructura y Funcionalidades

El módulo de Afiliación gestiona los empleados, sus tipos de afiliación (salud, pensión, etc.), los proveedores de estos servicios y las afiliaciones específicas de cada empleado.

### Modelos

1. **Employee**: 
   - Representa a un empleado contratado después de ser candidato
   - Estados posibles: ACTIVE, INACTIVE, ON_LEAVE, TERMINATED
   - Almacena información personal y laboral: nombres, documentos, contacto, posición, departamento
   - Se vincula opcionalmente con un usuario del sistema (User) y con un candidato (Candidate)

2. **AffiliationType**:
   - Define los tipos de afiliación (EPS, ARL, Pensión, etc.)
   - Contiene nombre y descripción

3. **Provider**:
   - Representa proveedores de servicios de afiliación (entidades de salud, fondos de pensión, etc.)
   - Está vinculado a un tipo de afiliación específico
   - Almacena información de contacto del proveedor (NIT, dirección, teléfono, email)
   - Puede marcarse como activo/inactivo

4. **Affiliation**:
   - Representa la afiliación específica de un empleado a un proveedor
   - Contiene fechas de inicio y fin, número de afiliación
   - Registra quién creó la afiliación y cuándo se actualizó
   - Se puede marcar como activa/inactiva

### Vistas (ViewSets)

1. **EmployeeViewSet**:
   - CRUD completo para empleados
   - Método adicional para buscar empleados por número de documento
   - Registra actividad del sistema al crear o actualizar empleados
   - Solo muestra empleados activos por defecto

2. **AffiliationTypeViewSet**:
   - CRUD completo para tipos de afiliación
   - Muestra todos los tipos de afiliación

3. **ProviderViewSet**:
   - CRUD completo para proveedores
   - Solo muestra proveedores activos por defecto
   - Método adicional para filtrar proveedores por tipo de afiliación

4. **AffiliationViewSet**:
   - CRUD completo para afiliaciones
   - Solo muestra afiliaciones activas por defecto
   - Método adicional para filtrar afiliaciones por empleado

### Serializadores

Los serializadores son simples y exponen todos los campos de los modelos, con algunos campos de sólo lectura adicionales para mejorar la presentación de datos:

- **EmployeeSerializer**: Expone todos los campos del modelo Employee
- **AffiliationTypeSerializer**: Expone todos los campos del modelo AffiliationType
- **ProviderSerializer**: Expone todos los campos y añade el nombre del tipo de afiliación
- **AffiliationSerializer**: Expone todos los campos y añade nombres de provider, affiliation_type y employee

### Repositorios

Implementan el patrón repositorio para separar la lógica de negocio del acceso a datos:

1. **EmployeeRepository**:
   - Métodos para obtener empleados activos
   - Buscar empleados por número de documento o ID de empleado

2. **AffiliationRepository**:
   - Métodos para obtener afiliaciones activas
   - Filtrar afiliaciones por empleado
   - Buscar afiliaciones específicas por empleado y tipo de afiliación

## Observaciones y Posibles Mejoras

### Posibles Bugs o Problemas Lógicos:

1. En el `EmployeeViewSet`, la consulta `get_by_document` retorna None si no encuentra el empleado, pero el método HTTP devuelve un error 404. Esto está bien, pero podría mejorarse con mensajes más descriptivos.

2. No hay validación para verificar que un empleado no tenga múltiples afiliaciones activas para el mismo tipo de afiliación (por ejemplo, dos EPS activas simultáneamente).

3. No existe lógica para manejar correctamente el histórico de afiliaciones cuando se inactiva una afiliación y se crea otra nueva del mismo tipo.

4. Los serializadores no tienen validaciones personalizadas, lo que podría permitir datos inconsistentes.

### Posibles Mejoras:

1. **Validaciones adicionales**:
   - Verificar que un empleado no tenga múltiples afiliaciones activas del mismo tipo
   - Validar que las fechas de fin sean posteriores a las de inicio

2. **Mejoras en los repositorios**:
   - Agregar métodos para reportes de afiliaciones por tipo o departamento
   - Implementar métodos para consultar el histórico de afiliaciones de un empleado

3. **Funcionalidad de reportes**:
   - Añadir endpoints para generar reportes de afiliación
   - Implementar filtros más avanzados (por departamento, por fecha, etc.)

4. **Notificaciones**:
   - Implementar notificaciones para afiliaciones próximas a vencer
   - Alertas sobre empleados sin afiliaciones obligatorias

5. **Automatizaciones**:
   - Proceso para inactivar automáticamente afiliaciones al terminar el contrato de un empleado
   - Generación automática de afiliaciones al contratar a un candidato

6. **Mejora de seguridad**:
   - Implementar permisos más granulares para las diferentes acciones
   - Registrar qué usuario realiza cada cambio en las afiliaciones

Esta documentación proporciona una base para entender la estructura actual del módulo `affiliation`, identificar posibles problemas y planificar mejoras futuras.

Voy a analizar el módulo `core` para documentar su estructura y funcionalidades en formato de commit, lo que nos ayudará a entender su lógica actual, identificar posibles bugs y planificar mejoras futuras.

Primero, examinemos los archivos principales del módulo para entender su estructura y funcionalidad. 

Vamos a seguir revisando los modelos en los subdirectorios: 

Basado en el análisis de los archivos del módulo `core`, he preparado la siguiente documentación en formato commit:

# Módulo Core

## Estructura y Funcionalidades

El módulo `core` proporciona la base fundamental del sistema RH-plus, manejando la autenticación, autorización, usuarios, roles y registro de actividades del sistema.

### Modelos

1. **User**:
   - Personalización del modelo de usuario de Django usando `AbstractUser`
   - Utiliza el email como identificador único para autenticación
   - Permite usernames opcionales (generados automáticamente si no se proporcionan)
   - Incluye campos estándar: is_active, is_staff, first_name, last_name
   - Implementa `UserManager` personalizado para la creación de usuarios y superusuarios

2. **Role**:
   - Define roles que pueden ser asignados a los usuarios (ej. Admin, HR Manager, etc.)
   - Contiene nombre y descripción

3. **UserRole**:
   - Relación muchos a muchos entre usuarios y roles
   - Permite asignar múltiples roles a un usuario

4. **SystemActivity**:
   - Registro de actividades del sistema para auditoría y seguimiento
   - Categoriza actividades por tipos: employee, candidate, payroll, training, performance
   - Almacena título, descripción, tipo, fecha/hora y usuario que realizó la acción

### Vistas (ViewSets)

1. **UserViewSet**:
   - CRUD completo para usuarios
   - Endpoint adicional `/me` para obtener los datos del usuario autenticado
   - Solo muestra usuarios activos por defecto

2. **RoleViewSet**:
   - CRUD completo para roles

3. **UserRoleViewSet**:
   - CRUD completo para asignaciones de roles a usuarios

4. **ActivityViewSet**:
   - CRUD para registros de actividad del sistema
   - Asigna automáticamente el usuario actual como creador de la actividad
   - Endpoint `/recent` para obtener las actividades más recientes
   - Endpoint `/dashboard_summary` para obtener resumen de datos del dashboard:
     - Conteo de empleados activos
     - Conteo de candidatos en proceso
     - Período de nómina actual
     - Conteo de capacitaciones próximas
     - Actividades recientes

5. **CustomTokenObtainPairView**:
   - Personalización de JWT (JSON Web Token) para autenticación
   - Utiliza email en lugar de username
   - Incluye name y email del usuario en el token

### Serializadores

1. **UserSerializer**:
   - Expone campos básicos del usuario (id, email, nombres, etc.)
   - Incluye método para obtener los roles del usuario

2. **RoleSerializer**:
   - Expone campos id, name y description

3. **UserRoleSerializer**:
   - Expone campos id, user y role

4. **SystemActivitySerializer**:
   - Expone campos de la actividad
   - Incluye método para obtener el nombre del usuario creador

### Repositorios

1. **UserRepository**:
   - Métodos para obtener usuarios activos
   - Búsqueda de usuarios por email e id

2. **RoleRepository**:
   - Métodos para obtener todos los roles
   - Búsqueda de roles por nombre

### Utilidades

- **record_activity**:
  - Función para registrar actividades del sistema
  - Usa transacciones para garantizar la integridad
  - Maneja errores sin interrumpir el flujo de la aplicación

### Señales (Signals)

- **handle_user_post_save**:
  - Se activa después de guardar un usuario
  - Actualmente está implementado como un placeholder para futuras funcionalidades (ej. enviar email de bienvenida)

### Admin

- **UserAdmin**:
  - Personalización del admin de Django para el modelo User
  - Asegura que los usernames sean únicos al guardar
  - Configuración de campos y filtros específicos

- **RoleAdmin** y **UserRoleAdmin**:
  - Interfaces administrativas para roles y asignación de roles

## Observaciones y Posibles Mejoras

### Posibles Bugs o Problemas Lógicos:

1. En `dashboard_summary` se usan bloques `try/except` sin logging específico para manejar casos donde los modelos de otras apps no estén disponibles. Esto puede ocultar errores reales.

2. En el `UserManager`, se genera un username único usando UUID, pero no se verifica si ese username ya existe en la base de datos, lo que podría causar problemas en casos muy raros.

3. En la vista `ActivityViewSet`, el método `recent` limita a 10 registros pero no aplica paginación, lo que podría causar problemas de rendimiento si los registros son grandes.

4. La función `record_activity` imprime errores a la consola en lugar de usar un logger apropiado, lo que dificulta el monitoreo en producción.

5. En el manejo de autenticación, no hay límites para intentos fallidos de login, lo que podría permitir ataques de fuerza bruta.

### Posibles Mejoras:

1. **Seguridad mejorada**:
   - Implementar bloqueo temporal de cuentas después de múltiples intentos fallidos
   - Añadir autenticación de dos factores (2FA)
   - Implementar políticas de contraseñas más robustas

2. **Mejor manejo de errores**:
   - Reemplazar los bloques try/except genéricos con manejo de excepciones específicas
   - Utilizar un sistema de logging adecuado en lugar de print statements

3. **Permisos más granulares**:
   - Implementar permisos basados en roles para acciones específicas
   - Usar decoradores personalizados para verificar permisos

4. **Mejoras en el modelo de usuario**:
   - Añadir más campos (como información de contacto, preferencias, etc.)
   - Implementar historial de cambios para auditoría

5. **Dashboard más completo**:
   - Añadir más métricas y estadísticas relevantes para RH
   - Implementar filtros para el dashboard (por fecha, departamento, etc.)

6. **Ampliación del sistema de actividades**:
   - Implementar notificaciones basadas en actividades importantes
   - Añadir niveles de importancia para las actividades (informativo, advertencia, crítico)
   - Implementar filtros y búsqueda avanzada de actividades

7. **Optimización de consultas**:
   - Revisar y optimizar consultas en los repositorios para mejorar el rendimiento
   - Implementar caché para consultas frecuentes

8. **Completar la implementación de signals**:
   - Utilizar los signals para implementar funcionalidades como notificaciones, emails, etc.
   - Añadir signals para otros eventos importantes del sistema

Esta documentación proporciona una visión general del módulo `core`, sus funcionalidades actuales, posibles problemas y áreas de mejora. El módulo parece estar bien estructurado siguiendo patrones de diseño como Repository y Observer (signals), pero tiene áreas que podrían optimizarse para una mejor seguridad, rendimiento y experiencia de usuario.

Voy a analizar el módulo `payroll` para documentar su estructura y funcionalidades en formato de commit, lo que nos ayudará a entender su lógica actual, identificar posibles bugs y planificar mejoras futuras.

Primero, examinemos los archivos principales del módulo para entender su estructura y funcionalidad. 

Basado en el análisis de los archivos del módulo `payroll`, he preparado la siguiente documentación en formato commit:

# Módulo de Nómina (Payroll)

## Estructura y Funcionalidades

El módulo de Nómina gestiona los contratos de los empleados, los períodos de nómina, los conceptos de pago (ingresos y deducciones), así como el cálculo y aprobación de los pagos.

### Modelos

1. **Contract**:
   - Representa el contrato laboral de un empleado
   - Tipos de contrato: Indefinido, Término Fijo, Temporal, Pasantía
   - Jornadas laborales: Tiempo Completo, Tiempo Parcial, Tiempo Flexible, Turnos
   - Almacena información sobre salario, moneda, posición, departamento
   - Incluye validación para asegurar que las fechas de inicio y fin sean coherentes
   - Garantiza que un empleado solo tenga un contrato activo a la vez

2. **PayrollPeriod**:
   - Define los períodos de nómina (quincenal, mensual, semanal, personalizado)
   - Controla el estado del período (abierto/cerrado)
   - Registra quién cerró el período y cuándo
   - Incluye método para cerrar el período

3. **PayrollItem**:
   - Define los conceptos de pago (devengos y deducciones)
   - Cada concepto tiene un código único, nombre, descripción, y tipo
   - Puede tener un monto predeterminado y ser porcentual o fijo
   - Permite activar o desactivar conceptos

4. **PayrollEntry**:
   - Representa la entrada de nómina de un empleado para un período específico
   - Almacena salario base, total de ingresos, deducciones y pago neto
   - Control de estado (aprobado/no aprobado)
   - Incluye métodos para aprobar la entrada y recalcular totales
   - Garantiza que un contrato solo tenga una entrada por período

5. **PayrollEntryDetail**:
   - Detalle específico de una entrada de nómina (un concepto específico)
   - Almacena el monto, cantidad y notas opcionales
   - Se relaciona con un concepto de pago (PayrollItem)

### Vistas (ViewSets)

1. **ContractViewSet**:
   - CRUD completo para contratos
   - Endpoint adicional para filtrar contratos por empleado
   - Solo muestra contratos activos por defecto

2. **PayrollPeriodViewSet**:
   - CRUD completo para períodos de nómina
   - Endpoint adicional para obtener períodos abiertos
   - Endpoint adicional para cerrar un período

3. **PayrollItemViewSet**:
   - CRUD completo para conceptos de pago
   - Endpoint adicional para filtrar conceptos por tipo (devengo/deducción)
   - Solo muestra conceptos activos por defecto

4. **PayrollEntryViewSet**:
   - CRUD completo para entradas de nómina
   - Endpoints adicionales para filtrar por período o empleado
   - Endpoint adicional para aprobar una entrada de nómina

5. **PayrollEntryDetailViewSet**:
   - CRUD completo para detalles de entradas de nómina

### Serializadores

Los serializadores son sencillos y exponen todos los campos de los modelos, con algunos campos de solo lectura adicionales:

- **ContractSerializer**: Añade campo employee_name para facilitar la visualización
- **PayrollPeriodSerializer**: Expone todos los campos del modelo
- **PayrollItemSerializer**: Expone todos los campos del modelo
- **PayrollEntrySerializer**: Incluye los detalles asociados y campos adicionales para employee_name y period_name
- **PayrollEntryDetailSerializer**: Añade campos item_name e item_type para mejorar la presentación

### Repositorios

Implementan el patrón repositorio para separar la lógica de negocio del acceso a datos:

1. **ContractRepository**:
   - Métodos para obtener contratos activos
   - Filtrar por empleado
   - Obtener contrato actual de un empleado

2. **PayrollPeriodRepository**:
   - Métodos para obtener períodos abiertos
   - Obtener el período actual

3. **PayrollEntryRepository**:
   - Métodos para filtrar entradas por período o empleado
   - Obtener entradas pendientes de aprobación

4. **PayrollItemRepository**:
   - Métodos para obtener conceptos activos
   - Filtrar por tipo (devengo/deducción)

### Señales (Signals)

1. **update_payroll_entry_totals**:
   - Se activa cuando se guarda un detalle de entrada de nómina
   - Recalcula los totales de la entrada (ingresos, deducciones, pago neto)

2. **set_base_salary**:
   - Se activa antes de guardar una entrada de nómina
   - Establece el salario base desde el contrato si no está definido

## Observaciones y Posibles Mejoras

### Posibles Bugs o Problemas Lógicos:

1. **Inconsistencia en los signals**: Hay duplicación de señales entre el archivo signals.py y las señales definidas directamente en models.py. La señal `update_payroll_entry_totals` está definida en ambos lugares, lo que podría causar cálculos duplicados.

2. **Validación insuficiente en PayrollEntryDetail**: No hay validación para asegurar que los montos porcentuales se apliquen correctamente cuando `is_percentage=True` en los conceptos de pago.

3. **Falta de transaccionalidad**: La actualización de totales en `PayrollEntry` no está dentro de una transacción, lo que podría llevar a estados inconsistentes si hay errores durante el proceso.

4. **Gestión de monedas**: El modelo `Contract` permite diferentes monedas, pero no hay una lógica clara para manejar conversiones o validar que todas las entradas de nómina usen la misma moneda.

5. **Validación débil de fechas en PayrollPeriod**: No hay validación para evitar superposición de períodos, lo que podría permitir múltiples períodos activos para las mismas fechas.

### Posibles Mejoras:

1. **Unificación de signals**: Eliminar la duplicación de señales y centralizar la lógica en un solo lugar.

2. **Mejora en la validación de conceptos porcentuales**:
   - Implementar lógica para calcular correctamente los montos cuando se usan porcentajes
   - Validar que los porcentajes estén en un rango válido (0-100%)

3. **Implementación de transacciones atomicas**:
   - Asegurar que las operaciones críticas (como el cálculo de totales) estén dentro de transacciones

4. **Gestión avanzada de monedas**:
   - Añadir soporte para conversión de monedas
   - Validar consistencia de monedas en una nómina

5. **Validación mejorada de períodos**:
   - Prevenir superposición de períodos
   - Añadir validación para garantizar continuidad entre períodos

6. **Funcionalidades adicionales**:
   - Generación de reportes de nómina (individuales, departamentales, globales)
   - Cálculo automático de conceptos comunes (horas extra, vacaciones, etc.)
   - Historial de cambios en los contratos
   - Integración con sistemas contables o bancarios

7. **Mejoras de rendimiento**:
   - Optimizar consultas en los repositorios para casos con gran volumen de datos
   - Implementar paginación en las vistas que pueden devolver muchos registros

8. **Seguridad mejorada**:
   - Implementar permisos más granulares (quién puede crear, ver o aprobar nóminas)
   - Registrar un historial de auditoría para cambios sensibles

9. **Mejora en la interfaz de usuario**:
   - Añadir endpoints para proporcionar resúmenes y estadísticas
   - Facilitar la comparación entre períodos

Esta documentación proporciona una base sólida para entender la estructura actual del módulo `payroll`, identificar problemas potenciales y planificar mejoras futuras. El módulo sigue una buena arquitectura con separación de responsabilidades, pero tiene áreas específicas que pueden optimizarse para mayor robustez y funcionalidad.

Voy a analizar el módulo `performance` para documentar su estructura y funcionalidades en formato de commit, lo que nos ayudará a entender su lógica actual, identificar posibles bugs y planificar mejoras futuras.

Primero, examinemos los archivos principales del módulo para entender su estructura y funcionalidad. 



Basado en el análisis de los archivos del módulo `performance`, he preparado la siguiente documentación en formato commit:

# Módulo de Desempeño (Performance)

## Estructura y Funcionalidades

El módulo de Desempeño gestiona las evaluaciones de rendimiento de los empleados, incluyendo los tipos de evaluación, criterios, períodos, resultados detallados y planes de mejora.

### Modelos

1. **EvaluationType**:
   - Define los tipos de evaluaciones de desempeño disponibles en el sistema
   - Almacena nombre, descripción y frecuencia de las evaluaciones
   - Puede marcarse como activo/inactivo

2. **EvaluationCriteria**:
   - Define los criterios específicos para cada tipo de evaluación
   - Incluye un peso porcentual para ponderar la importancia de cada criterio
   - Se relaciona con un tipo de evaluación específico
   - Puede marcarse como activo/inactivo

3. **EvaluationPeriod**:
   - Define los períodos de tiempo para las evaluaciones
   - Se vincula a un tipo de evaluación específico
   - Almacena fechas de inicio y fin del período
   - Registra quién creó el período y cuándo
   - Puede marcarse como activo/inactivo

4. **Evaluation**:
   - Representa la evaluación de desempeño de un empleado específico
   - Estados posibles: DRAFT, IN_PROGRESS, WAITING_FEEDBACK, COMPLETED
   - Almacena la puntuación general (calculada automáticamente)
   - Incluye comentarios tanto del evaluador como del empleado
   - Garantiza que un empleado solo tenga una evaluación por período

5. **EvaluationDetail**:
   - Almacena las puntuaciones específicas para cada criterio en una evaluación
   - Incluye comentarios para cada criterio evaluado
   - Se garantiza la unicidad de criterio por evaluación

6. **ImprovementPlan**:
   - Define planes de mejora para empleados basados en las evaluaciones
   - Estados posibles: ACTIVE, COMPLETED, CANCELLED
   - Se relaciona opcionalmente con una evaluación específica
   - Registra quién creó el plan y quién supervisa su implementación

7. **ImprovementGoal**:
   - Define objetivos específicos dentro de un plan de mejora
   - Estados posibles: PENDING, IN_PROGRESS, COMPLETED, OVERDUE
   - Permite seguimiento del progreso mediante un porcentaje de completitud

### Vistas (ViewSets)

1. **EvaluationTypeViewSet**:
   - CRUD completo para tipos de evaluación
   - Solo muestra tipos activos por defecto

2. **EvaluationCriteriaViewSet**:
   - CRUD completo para criterios de evaluación
   - Solo muestra criterios activos por defecto
   - Endpoint adicional para filtrar criterios por tipo de evaluación

3. **EvaluationPeriodViewSet**:
   - CRUD completo para períodos de evaluación
   - Solo muestra períodos activos por defecto
   - Endpoint adicional para filtrar períodos por tipo de evaluación

4. **EvaluationViewSet**:
   - CRUD completo para evaluaciones de desempeño
   - Endpoints adicionales para:
     - Filtrar evaluaciones por empleado
     - Obtener evaluaciones realizadas por el usuario actual como evaluador
     - Marcar una evaluación como completada
     - Solicitar retroalimentación del empleado

5. **EvaluationDetailViewSet**:
   - CRUD completo para los detalles de las evaluaciones

6. **ImprovementPlanViewSet**:
   - CRUD completo para planes de mejora
   - Solo muestra planes activos por defecto
   - Endpoints adicionales para:
     - Filtrar planes por empleado
     - Obtener planes supervisados por el usuario actual

7. **ImprovementGoalViewSet**:
   - CRUD completo para objetivos de mejora

### Serializadores

Los serializadores incluyen campos adicionales de solo lectura para mejorar la presentación de datos:

- **EvaluationTypeSerializer**: Incluye los criterios asociados
- **EvaluationPeriodSerializer**: Añade el nombre del tipo de evaluación
- **EvaluationDetailSerializer**: Añade nombre y peso del criterio
- **EvaluationSerializer**: Incluye detalles asociados, nombres del empleado, evaluador y período
- **ImprovementPlanSerializer**: Incluye objetivos asociados, nombres del empleado y supervisor
- **ImprovementGoalSerializer**: Expone todos los campos del modelo

### Repositorios

Implementan el patrón repositorio para separar la lógica de negocio del acceso a datos:

1. **EvaluationTypeRepository**:
   - Métodos para obtener tipos de evaluación activos

2. **EvaluationCriteriaRepository**:
   - Métodos para filtrar criterios por tipo de evaluación

3. **EvaluationPeriodRepository**:
   - Métodos para obtener períodos activos
   - Filtrar períodos por tipo de evaluación

4. **EvaluationRepository**:
   - Métodos para filtrar evaluaciones por empleado, evaluador o período
   - Obtener evaluaciones pendientes de retroalimentación

5. **ImprovementPlanRepository**:
   - Métodos para obtener planes activos
   - Filtrar planes por empleado o supervisor

### Señales (Signals)

- **update_evaluation_score**:
  - Se activa cuando se guarda un detalle de evaluación
  - Calcula la puntuación general de la evaluación como una media ponderada basada en los pesos de los criterios

## Observaciones y Posibles Mejoras

### Posibles Bugs o Problemas Lógicos:

1. **Cálculo de puntuación global**: El signal `update_evaluation_score` recalcula la puntuación general cada vez que se guarda un detalle, pero no verifica si todos los criterios necesarios han sido evaluados. Podrían generarse puntuaciones parciales que no reflejen correctamente el desempeño.

2. **Faltan validaciones de fechas**: No hay validación para asegurar que las fechas de inicio y fin de los períodos de evaluación y planes de mejora sean coherentes (que la fecha de fin sea posterior a la de inicio).

3. **Falta verificación de pesos de criterios**: No hay validación para asegurar que la suma de los pesos de todos los criterios de un tipo de evaluación sumen 100%.

4. **Actualización de estado de objetivos**: No hay un mecanismo automático para actualizar el estado de los objetivos a "OVERDUE" cuando se pasa la fecha límite.

5. **Inconsistencia en el manejo de evaluaciones completadas**: El método `complete` en `EvaluationViewSet` establece directamente el estado sin verificar si todos los criterios han sido evaluados.

### Posibles Mejoras:

1. **Validaciones mejoradas**:
   - Implementar validación de fechas para períodos y planes de mejora
   - Verificar que la suma de pesos de criterios para un tipo de evaluación sea 100%
   - Validar que todos los criterios requeridos estén evaluados antes de permitir completar una evaluación

2. **Automatización de estados**:
   - Implementar un sistema de tareas programadas para actualizar automáticamente el estado de los objetivos vencidos
   - Añadir validaciones para la transición entre estados de evaluación (ej. no permitir pasar a COMPLETED sin haber pasado por WAITING_FEEDBACK)

3. **Mejora en la gestión de evaluaciones**:
   - Implementar un sistema de notificaciones para informar a los empleados cuando tienen evaluaciones pendientes de retroalimentación
   - Añadir capacidad para comparar evaluaciones del mismo empleado en diferentes períodos

4. **Extensión funcional**:
   - Implementar autoevaluaciones para que los empleados puedan evaluarse a sí mismos
   - Añadir evaluaciones de 360° que incluyan feedback de compañeros y subordinados
   - Implementar un sistema de calibración para normalizar evaluaciones entre diferentes evaluadores

5. **Reportes y análisis**:
   - Añadir funcionalidades para generar reportes de desempeño por departamento o equipo
   - Implementar visualizaciones gráficas de la evolución del desempeño
   - Añadir análisis predictivo para identificar tendencias en el desempeño

6. **Integración con otros módulos**:
   - Vincular el desempeño con el módulo de compensaciones y beneficios
   - Integrar el desempeño con el módulo de capacitación para sugerir cursos basados en áreas de mejora identificadas

7. **Seguridad y auditoría**:
   - Implementar permisos más granulares para el acceso a evaluaciones
   - Añadir registro de auditoría para cambios en evaluaciones y planes

8. **Mejoras en la interfaz de usuario**:
   - Simplificar el proceso de evaluación con formularios más intuitivos
   - Implementar dashboards para visualizar el desempeño global y por departamentos

Esta documentación proporciona una base para entender la estructura actual del módulo `performance`, identificar posibles problemas y planificar mejoras futuras. El módulo está bien estructurado siguiendo el patrón repositorio, pero tiene áreas específicas que pueden optimizarse para mayor robustez y funcionalidad.

Voy a analizar el módulo `selection` para documentar su estructura y funcionalidades en formato de commit, lo que nos ayudará a entender su lógica actual, identificar posibles bugs y planificar mejoras futuras.

Primero, examinemos los archivos principales del módulo para entender su estructura y funcionalidad. 

Basado en el análisis de los archivos del módulo `selection`, he preparado la siguiente documentación en formato commit:

# Módulo de Selección (Selection)

## Estructura y Funcionalidades

El módulo de Selección gestiona el proceso de reclutamiento y selección de candidatos, incluyendo las etapas del proceso, los candidatos, documentos y la relación entre procesos y candidatos.

### Modelos

1. **SelectionStage**:
   - Define las etapas del proceso de selección (ej. CV Review, Entrevista inicial, Prueba técnica, etc.)
   - Cada etapa tiene un nombre, descripción y un orden numérico
   - Las etapas se ordenan automáticamente por el campo 'order'

2. **Candidate**:
   - Almacena la información básica de los candidatos
   - Incluye datos personales: nombres, documento de identidad, contacto, género, fecha de nacimiento, dirección
   - Estados posibles: ACTIVE, HIRED, REJECTED, WITHDRAWN
   - Se relaciona opcionalmente con la etapa actual del proceso de selección
   - Registra fechas de creación y actualización

3. **SelectionProcess**:
   - Representa un proceso de selección para una posición laboral
   - Contiene nombre, descripción, fechas de inicio/fin y estado de actividad
   - Registra quién creó el proceso
   - Se relaciona con múltiples candidatos a través de ProcessCandidate

4. **ProcessCandidate**:
   - Implementa la relación muchos a muchos entre procesos y candidatos
   - Almacena la etapa actual del candidato en el proceso específico
   - Incluye notas y fechas de creación/actualización
   - Garantiza que un candidato solo esté una vez en cada proceso

5. **CandidateDocument**:
   - Almacena los documentos subidos por o para los candidatos
   - Se relaciona con un candidato específico
   - Registra el tipo de documento y la fecha de carga

### Vistas (ViewSets)

1. **SelectionStageViewSet**:
   - CRUD completo para etapas de selección

2. **CandidateViewSet**:
   - CRUD completo para candidatos
   - Solo muestra candidatos activos por defecto
   - Registra actividad del sistema al crear o actualizar candidatos
   - Endpoint adicional para buscar candidatos por número y tipo de documento

3. **SelectionProcessViewSet**:
   - CRUD completo para procesos de selección
   - Solo muestra procesos activos por defecto
   - Endpoint adicional para obtener todos los candidatos en un proceso específico

4. **ProcessCandidateViewSet**:
   - CRUD completo para la relación entre procesos y candidatos
   - Registra actividad del sistema cuando un candidato avanza de etapa

5. **CandidateDocumentViewSet**:
   - CRUD completo para documentos de candidatos

### Serializadores

1. **SelectionStageSerializer**:
   - Expone todos los campos del modelo SelectionStage

2. **CandidateDocumentSerializer**:
   - Expone todos los campos del modelo CandidateDocument

3. **CandidateSerializer**:
   - Expone todos los campos del modelo Candidate
   - Incluye documentos asociados como campo de solo lectura

4. **ProcessCandidateSerializer**:
   - Expone todos los campos del modelo ProcessCandidate
   - Incluye información completa del candidato como campo de solo lectura

5. **SelectionProcessSerializer**:
   - Expone todos los campos del modelo SelectionProcess
   - Incluye información de todos los candidatos asociados como campo de solo lectura

### Repositorios

1. **CandidateRepository**:
   - Métodos para obtener candidatos activos
   - Método para buscar candidatos por documento

2. **SelectionProcessRepository**:
   - Métodos para obtener procesos activos
   - Método para obtener todos los candidatos de un proceso específico

### Señales (Signals)

1. **update_candidate_stage**:
   - Se activa cuando se actualiza una relación ProcessCandidate
   - Actualiza automáticamente la etapa actual del candidato para mantener coherencia

### Admin

- Interfaces administrativas personalizadas para todos los modelos
- Incluyen filtros, búsquedas y jerarquías de fechas para facilitar la gestión

## Observaciones y Posibles Mejoras

### Posibles Bugs o Problemas Lógicos:

1. **Inconsistencia en la actualización de etapas**: En el `ProcessCandidateViewSet`, el método `perform_update` hace referencia a un campo `stage` que debería ser `current_stage` según la definición del modelo.

2. **Falta de validación de documentos**: No hay validación para el tipo de archivo que se sube como documento de candidato, lo que podría permitir la carga de archivos no deseados.

3. **Limitación en la búsqueda de candidatos**: El método `by_document` solo busca por tipo y número exacto, sin considerar posibles variaciones en el formato (espacios, guiones, etc.).

4. **Inconsistencia de estados**: No hay una lógica clara para la transición entre los estados de un candidato (ACTIVE, HIRED, REJECTED, WITHDRAWN), lo que podría permitir cambios ilógicos.

5. **Ausencia de validación de fechas**: No hay validación para asegurar que la fecha de fin de un proceso de selección sea posterior a la de inicio.

### Posibles Mejoras:

1. **Automatización de transiciones de estado**:
   - Implementar reglas para la transición automática entre estados de candidato basadas en eventos específicos
   - Añadir validación para prevenir transiciones inválidas

2. **Mejora en la búsqueda de candidatos**:
   - Implementar búsqueda más flexible por documento, normalizando el formato
   - Añadir búsqueda por nombres, correo electrónico u otros campos relevantes

3. **Validación mejorada de documentos**:
   - Restringir los tipos de archivo permitidos
   - Implementar escaneo de virus para documentos subidos
   - Validar el tamaño de los archivos

4. **Seguimiento y métricas**:
   - Añadir funcionalidades para medir la eficiencia del proceso de selección
   - Implementar KPIs como tiempo promedio en cada etapa, tasa de conversión, etc.

5. **Expansión funcional**:
   - Añadir gestión de entrevistas con agenda
   - Implementar sistema de evaluación para cada etapa del proceso
   - Añadir capacidad para generar reportes sobre los procesos de selección

6. **Notificaciones**:
   - Implementar notificaciones para informar sobre cambios de estado o etapa
   - Añadir recordatorios para entrevistas o pruebas pendientes

7. **Integración con correo electrónico**:
   - Añadir capacidad para enviar comunicaciones automáticas a los candidatos
   - Implementar plantillas para diferentes tipos de comunicación

8. **Mejora de seguridad**:
   - Implementar permisos más granulares para diferentes roles en el proceso de selección
   - Añadir registro de auditoría para cambios sensibles

9. **Enlace con el módulo de afiliación**:
   - Mejorar el proceso de transición de un candidato contratado a empleado
   - Asegurar la transferencia correcta de toda la información relevante

Esta documentación proporciona una base para entender la estructura actual del módulo `selection`, identificar posibles problemas y planificar mejoras futuras. El módulo está bien estructurado siguiendo el patrón repositorio, pero tiene áreas específicas que pueden optimizarse para mayor robustez y funcionalidad.

Voy a analizar el módulo `training` para documentar su estructura y funcionalidades en formato de commit, lo que nos ayudará a entender su lógica actual, identificar posibles bugs y planificar mejoras futuras.

Primero, examinemos los archivos principales del módulo para entender su estructura y funcionalidad. 



Basado en el análisis de los archivos del módulo `training`, he preparado la siguiente documentación en formato commit:

# Módulo de Capacitación (Training)

## Estructura y Funcionalidades

El módulo de Capacitación gestiona los programas de formación, sesiones de capacitación, asistencia y evaluación de empleados en los procesos de entrenamiento.

### Modelos

1. **TrainingType**:
   - Define los tipos de capacitación (inducción, reinducción, desarrollo de habilidades, etc.)
   - Contiene nombre, descripción y estado de activación
   - Permite organizar los programas por categorías

2. **TrainingProgram**:
   - Representa un programa de capacitación específico
   - Se asocia a un tipo de capacitación
   - Almacena información detallada: nombre, descripción, duración, materiales, objetivos
   - Registra quién creó el programa y cuándo
   - Puede marcarse como activo/inactivo

3. **TrainingSession**:
   - Representa una sesión específica de un programa de capacitación
   - Estados posibles: SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED
   - Almacena información logística: fecha, horario, ubicación, instructor, capacidad máxima
   - Incluye notas y quién creó la sesión
   - Las sesiones se ordenan automáticamente por fecha y hora

4. **TrainingAttendance**:
   - Registra la asistencia de un empleado a una sesión de capacitación
   - Estados posibles: REGISTERED, ATTENDED, MISSED, EXCUSED
   - Almacena puntuación de evaluación y comentarios
   - Registra quién registró la asistencia y cuándo
   - Garantiza que un empleado solo tenga un registro de asistencia por sesión

5. **TrainingEvaluation**:
   - Permite a los empleados evaluar una capacitación recibida
   - Incluye calificación de diferentes aspectos: contenido, instructor, materiales, utilidad
   - Utiliza una escala del 1 al 5 (muy insatisfecho a muy satisfecho)
   - Permite feedback textual
   - Se vincula a un registro de asistencia específico

### Vistas (ViewSets)

1. **TrainingTypeViewSet**:
   - CRUD completo para tipos de capacitación
   - Solo muestra tipos activos por defecto

2. **TrainingProgramViewSet**:
   - CRUD completo para programas de capacitación
   - Solo muestra programas activos por defecto
   - Endpoint adicional para filtrar programas por tipo

3. **TrainingSessionViewSet**:
   - CRUD completo para sesiones de capacitación
   - Registra automáticamente al usuario actual como creador
   - Registra actividad del sistema al crear una sesión
   - Endpoints adicionales para:
     - Obtener sesiones próximas
     - Filtrar sesiones por programa
     - Marcar una sesión como completada
     - Obtener estadísticas de asistencia

4. **TrainingAttendanceViewSet**:
   - CRUD completo para registros de asistencia
   - Registra automáticamente al usuario actual como registrador
   - Endpoints adicionales para:
     - Filtrar asistencias por empleado
     - Filtrar asistencias por sesión
     - Marcar un registro como "asistido"

5. **TrainingEvaluationViewSet**:
   - CRUD completo para evaluaciones de capacitación

### Serializadores

Todos los serializadores incluyen campos de solo lectura adicionales para mejorar la presentación de datos:

1. **TrainingTypeSerializer**:
   - Expone todos los campos del modelo TrainingType

2. **TrainingProgramSerializer**:
   - Expone todos los campos del modelo TrainingProgram
   - Incluye el nombre del tipo de capacitación

3. **TrainingSessionSerializer**:
   - Expone todos los campos del modelo TrainingSession
   - Incluye el nombre del programa y del instructor

4. **TrainingAttendanceSerializer**:
   - Expone todos los campos del modelo TrainingAttendance
   - Incluye nombre del empleado, fecha de la sesión y nombre del programa

5. **TrainingEvaluationSerializer**:
   - Expone todos los campos del modelo TrainingEvaluation
   - Incluye nombre del empleado y nombre del programa

### Repositorios

1. **TrainingProgramRepository**:
   - Métodos para obtener programas activos
   - Filtrar programas por tipo de capacitación

2. **TrainingSessionRepository**:
   - Métodos para obtener sesiones próximas
   - Filtrar sesiones por programa o instructor

3. **TrainingAttendanceRepository**:
   - Métodos para filtrar asistencias por empleado o sesión
   - Método para obtener estadísticas de asistencia y puntuaciones medias

### Señales (Signals)

1. **update_attendance_score**:
   - Se activa cuando se guarda una evaluación
   - Calcula automáticamente la puntuación media (promedio de las 5 calificaciones diferentes)
   - Actualiza el campo evaluation_score en el registro de asistencia correspondiente

### Admin

- Interfaces administrativas personalizadas para todos los modelos
- Incluyen filtros, búsquedas y jerarquías de fechas para facilitar la gestión

## Observaciones y Posibles Mejoras

### Posibles Bugs o Problemas Lógicos:

1. **Inconsistencia en TrainingSessionViewSet.perform_create**: El método accede a `session.date` pero en el modelo se llama `session_date`.

2. **Falta validación de horarios**: No hay validación para asegurar que `end_time` sea posterior a `start_time` en una sesión de capacitación.

3. **Limitación en el cálculo de calificaciones**: La fórmula para calcular el promedio de calificaciones es un simple promedio aritmético, sin considerar ponderaciones diferentes para cada aspecto evaluado.

4. **Falta de control de capacidad**: No hay validación para asegurar que el número de asistentes no exceda `max_participants` de una sesión.

5. **Documentación inconsistente**: En `TrainingSession`, el comentario dice "session of a program" pero la relación está definida como 'sessions', lo que puede llevar a confusiones.

### Posibles Mejoras:

1. **Validaciones mejoradas**:
   - Implementar validación para asegurar que end_time > start_time
   - Verificar que el número de participantes no exceda max_participants
   - Validar que las fechas de sesiones estén dentro de rangos lógicos

2. **Capacidades de planificación**:
   - Implementar funcionalidad para programar sesiones recurrentes
   - Añadir capacidad para clonar programas y sesiones existentes
   - Implementar sistema de detección de conflictos de horario

3. **Notificaciones**:
   - Añadir notificaciones automáticas para recordar a los empleados sobre sesiones próximas
   - Implementar alertas para instructores sobre sus próximas sesiones
   - Notificar cuando una sesión está cerca de alcanzar su capacidad máxima

4. **Mejora del sistema de evaluación**:
   - Permitir la personalización de los aspectos a evaluar por tipo de programa
   - Implementar ponderaciones diferentes para cada aspecto evaluado
   - Añadir evaluaciones previas y posteriores para medir el impacto de la capacitación

5. **Gestión de recursos**:
   - Añadir gestión de recursos físicos necesarios para cada sesión (salas, equipos, etc.)
   - Implementar sistema de reserva de recursos
   - Añadir control de costos asociados a cada capacitación

6. **Reportes y análisis**:
   - Implementar reportes para medir la efectividad de los programas
   - Añadir análisis comparativo entre diferentes sesiones del mismo programa
   - Implementar visualizaciones gráficas del progreso de los empleados

7. **Integración con otros módulos**:
   - Mejorar la integración con el módulo de Desempeño para vincular capacitaciones con mejoras en rendimiento
   - Integrar con calendarios corporativos para mejor programación

8. **Mejora de UX/UI**:
   - Implementar vistas de calendario para visualizar sesiones
   - Añadir capacidad de registro masivo de asistentes
   - Implementar formularios de evaluación más intuitivos

Esta documentación proporciona una base para entender la estructura actual del módulo `training`, identificar posibles problemas y planificar mejoras futuras. El módulo está bien estructurado siguiendo el patrón repositorio, pero tiene áreas específicas que pueden optimizarse para mayor robustez y funcionalidad.

# Documentación de Cambios - Sistema de Roles y Permisos RH-Plus

## Commit: Implementación completa de sistema de roles jerárquicos y mejoras de UI

### 📋 Resumen General

Se implementó un sistema completo de roles y permisos jerárquicos para RH-Plus, incluyendo mejoras significativas en la interfaz de usuario y corrección de errores críticos en la gestión de superusuarios.

---

## 🔧 Backend Changes

### **Archivos Modificados:**

#### `apps/core/models.py`
**Cambios principales:**
- **Agregado sistema de roles jerárquicos:**
  - Nuevas constantes `USER_ROLES` y `ROLE_HIERARCHY`
  - 6 niveles de roles: SUPERUSER, ADMIN, HR_MANAGER, SUPERVISOR, EMPLOYEE, USER
  
- **Nuevos campos en modelo User:**
  ```python
  role = models.CharField(max_length=20, choices=USER_ROLES, default='USER')
  department = models.CharField(max_length=100, blank=True, null=True)
  manager = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True)
  ```

- **Métodos de permisos implementados:**
  - `can_manage_user()`: Valida jerarquía de roles para gestión de usuarios
  - `can_access_module()`: Define acceso a módulos por rol
  - `get_managed_users()`: Retorna usuarios que puede gestionar según rol

- **Corrección crítica en UserManager:**
  ```python
  def create_superuser(self, email, password, **extra_fields):
      extra_fields.setdefault('role', 'SUPERUSER')  # FIX: Asigna rol correcto
  ```

**Funcionalidades afectadas:**
- Autenticación y autorización
- Gestión de usuarios
- Control de acceso a módulos
- Creación de superusuarios

#### `apps/core/views.py`
**Nuevos endpoints implementados:**
- `user_permissions/`: Retorna permisos y módulos accesibles del usuario actual
- `role_options/`: Retorna roles que el usuario actual puede asignar
- `update_role/`: Permite actualizar roles de otros usuarios con validaciones

**Mejoras en seguridad:**
- Validación de permisos en cada endpoint
- Logging extensivo para debugging
- Manejo de errores robusto con try-catch

**ViewSets afectados:**
- `UserViewSet`: Filtrado de usuarios por permisos, nuevas acciones
- Todos los ViewSets: Aplicación consistente de permisos

#### `apps/core/serializers.py`
**Nuevos serializers:**
- `UserRoleUpdateSerializer`: Para actualización segura de roles
- `UserListSerializer`: Para listado optimizado con información de roles
- Validaciones de permisos en serializers

#### `requirements.txt`
**Dependencia agregada:**
- `django-filter==23.5`: Para filtrado avanzado en APIs

---

## 🎨 Frontend Changes

### **Archivos Modificados:**

#### `lib/utils/constants.dart`
**Cambios en paleta de colores:**
- **Antes:** Colores azul brillante (`Color(0xFF2196F3)`)
- **Después:** Paleta neutra y moderna:
  ```dart
  primaryColor = Color(0xFF1A1A1A)      // Negro elegante
  backgroundColor = Color(0xFFF8F9FA)   // Gris muy claro
  secondaryColor = Color(0xFF6C7293)    // Gris azulado
  ```

**Nuevas constantes:**
- URLs para endpoints de roles y permisos
- Constantes de roles con mapeo a nombres en español
- Colores adicionales: success, warning, info, error

#### `lib/models/user_model.dart`
**Nuevos modelos:**
- `UserPermissions`: Maneja permisos y módulos accesibles
- Campos extendidos en `User`: role, department, manager
- Métodos helper para validación de permisos

#### `lib/providers/auth_provider.dart`
**Funcionalidades nuevas:**
- `loadUserPermissions()`: Carga permisos del usuario actual
- `register()`: Implementación completa de registro
- `loadUserFromToken()`: Validación de tokens almacenados
- Logging extensivo para debugging

**Getters agregados:**
- `userPermissions`: Acceso a permisos del usuario
- `canAccessModule()`: Validación de acceso a módulos
- `canManageUsers`: Validación de permisos de gestión

#### `lib/views/login_screen.dart`
**Rediseño completo:**
- **Estilo anterior:** Pantalla simple con fondo plano
- **Estilo nuevo:** 
  - Card elevada con sombras suaves
  - Campos de entrada con bordes redondeados
  - Iconos outlined para mejor estética
  - Colores neutros y profesionales
  - Mejor feedback visual (loading states)

#### `lib/views/dashboard_screen.dart`
**Rediseño y funcionalidad:**
- **Dashboard dinámico:** Se adapta a permisos del usuario
- **Nuevos elementos:**
  - Card de bienvenida con información del rol
  - Grid de módulos basado en permisos
  - Indicadores visuales para módulos no disponibles
  - Íconos outlined consistentes

**Lógica de permisos:**
- Módulos se muestran/ocultan según rol
- Gestión de usuarios solo para roles autorizados
- Estados de carga mejorados

#### `lib/views/user_management_screen.dart` (Nuevo)
**Funcionalidad completa:**
- Lista de usuarios gestionables según permisos
- Modal para actualización de roles
- Validación de permisos en tiempo real
- Feedback visual con colores por rol

#### `lib/main.dart`
**Mejoras:**
- `debugShowCheckedModeBanner: false`: Eliminado banner de debug
- `AuthWrapper`: Manejo inteligente del estado de autenticación
- Navegación mejorada entre pantallas

---

## 🔄 Funcionalidades Nuevas

### **Sistema de Roles Jerárquicos:**
1. **SUPERUSER**: Acceso total al sistema
2. **ADMIN**: Puede gestionar HR_MANAGER, SUPERVISOR, EMPLOYEE, USER
3. **HR_MANAGER**: Puede gestionar SUPERVISOR, EMPLOYEE, USER
4. **SUPERVISOR**: Puede gestionar EMPLOYEE, USER en su departamento
5. **EMPLOYEE**: Acceso limitado a sus datos
6. **USER**: Rol por defecto para nuevos registros

### **Control de Acceso por Módulos:**
- **Selection**: SUPERUSER, ADMIN, HR_MANAGER, SUPERVISOR
- **Affiliation**: SUPERUSER, ADMIN, HR_MANAGER, SUPERVISOR, EMPLOYEE
- **Payroll**: SUPERUSER, ADMIN, HR_MANAGER
- **Performance**: SUPERUSER, ADMIN, HR_MANAGER, SUPERVISOR, EMPLOYEE
- **Training**: SUPERUSER, ADMIN, HR_MANAGER, SUPERVISOR, EMPLOYEE
- **Core**: SUPERUSER, ADMIN, HR_MANAGER, SUPERVISOR

### **Gestión de Usuarios:**
- Interface para cambiar roles de usuarios
- Validaciones de permisos en backend y frontend
- Auditoría de cambios en SystemActivity

---

## 🐛 Errores Corregidos

### **Backend:**
1. **Superuser role assignment**: `create_superuser` ahora asigna correctamente `role='SUPERUSER'`
2. **Missing imports**: Agregado `TokenObtainPairSerializer` import
3. **Missing dependency**: Agregado `django-filter` a requirements
4. **Circular imports**: Imports locales en funciones para evitar conflictos

### **Frontend:**
1. **Missing UserPermissions model**: Implementado modelo completo
2. **Missing register method**: Agregado método de registro en AuthProvider
3. **AppColors undefined**: Definida paleta completa de colores
4. **Type errors**: Corregidos errores de tipos en login flow

---

## 🎯 Migraciones Requeridas

```bash
# Crear migraciones para nuevos campos
python manage.py makemigrations

# Aplicar migraciones
python manage.py migrate

# Actualizar superuser existente (si es necesario)
python manage.py shell
# En shell: User.objects.filter(is_superuser=True).update(role='SUPERUSER')
```

---

## 📊 Métricas de Cambios

- **Archivos backend modificados**: 4
- **Archivos frontend modificados**: 7
- **Nuevos endpoints**: 3
- **Nuevos modelos/clases**: 3
- **Líneas de código agregadas**: ~800
- **Funcionalidades nuevas**: 5 principales
- **Errores críticos corregidos**: 6

---

## 🔜 Próximos Pasos Sugeridos

1. **Implementar módulos específicos** (Selection, Payroll, etc.)
2. **Agregar notificaciones** para cambios de roles
3. **Implementar recuperación de contraseña**
4. **Agregar tests unitarios** para sistema de permisos
5. **Optimizar queries** con select_related/prefetch_related
6. **Implementar rate limiting** para seguridad

---

Este commit establece las bases sólidas para un sistema de gestión de recursos humanos escalable con control granular de permisos y una interfaz moderna y profesional.


# Corrección de Errores en el Módulo de Capacitación

## 🔍 Problema
Se identificaron múltiples errores en el módulo de capacitación relacionados con:
1. Inicialización incorrecta del TrainingProvider
2. Discrepancia entre los nombres de propiedades del modelo y su uso
3. Colores faltantes en AppColors
4. Métodos no definidos en el TrainingProvider
5. Tipos de datos incompatibles en casting

## 💡 Solución
### 1. Corrección del TrainingProvider
- Actualizado el constructor para obtener el token del context
- Implementación correcta de los métodos faltantes:
  - loadTrainingPrograms()
  - loadTrainingSessions()
  - loadAttendanceForSession()

### 2. Actualización de Modelos
Alineación de propiedades en los modelos:
- TrainingProgramModel:
  - Añadido: status, duration, startDate, endDate, type, department
- TrainingSessionModel:
  - Añadido: title, description, startDate, attendees

### 3. Constantes de Color
Añadidas constantes faltantes en AppColors:
- textPrimaryColor
- textSecondaryColor
- borderColor

### 4. Corrección de Tipos
- Corregido el casting de Object a String en session_form_screen.dart
- Ajustado el tipo de retorno en el cálculo de totalParticipants

## 📁 Archivos Modificados
1. lib/views/training/reports/training_reports_screen.dart
   - Corregida inicialización del provider
   - Actualizados métodos de carga
   - Corregidos getters de modelos

2. lib/views/training/forms/program_form_screen.dart
   - Actualizada inicialización del provider
   - Corregidos nombres de propiedades del modelo
   - Actualizadas referencias de color

3. lib/views/training/forms/session_form_screen.dart
   - Corregido manejo de tipos en controladores
   - Actualizadas propiedades del modelo
   - Corregidas referencias de color

4. lib/views/training/management/attendance_management_screen.dart
   - Implementada carga de asistencia
   - Corregidas referencias de color

5. lib/models/training_models.dart
   - Añadidas propiedades faltantes
   - Actualizada estructura de modelos

6. lib/providers/training_provider.dart
   - Implementados métodos faltantes
   - Mejorado manejo de token

7. lib/utils/constants/colors.dart
   - Añadidas constantes de color faltantes

## 🔧 Detalles Técnicos
### TrainingProvider
```dart
class TrainingProvider extends ChangeNotifier {
  final String token;
  
  TrainingProvider({required this.token});
  
  Future<void> loadTrainingPrograms() async {
    // Implementación
  }
  
  Future<void> loadTrainingSessions() async {
    // Implementación
  }
  
  Future<void> loadAttendanceForSession(String sessionId) async {
    // Implementación
  }
}
```

### Modelos Actualizados
```dart
class TrainingProgramModel {
  final String status;
  final double duration;
  final String startDate;
  final String endDate;
  final String type;
  final String department;
  
  // Constructor
}

class TrainingSessionModel {
  final String title;
  final String description;
  final String startDate;
  final List<String> attendees;
  
  // Constructor
}
```

## ✅ Beneficios
1. Mayor estabilidad en el módulo de capacitación
2. Consistencia en el manejo de datos
3. UI coherente con el diseño del sistema
4. Mejor manejo de estados y datos
5. Código más mantenible

## 🧪 Testing
- Verificada la carga de programas y sesiones
- Probado el manejo de asistencia
- Validada la generación de reportes
- Comprobada la consistencia de la UI

## 📌 Notas
- Se mantiene la estructura existente del proyecto
- Se respeta la arquitectura de providers
- Se mantiene la coherencia con el diseño existente

Historial resumido de conversaciones. Basándome en el código y el contexto proporcionados, crearé una documentación detallada de los cambios en el formato de confirmación:

Corrección: Mejoras del módulo de entrenamiento en el frontend/backend

CAMBIOS IMPORTANTES:
- Se modificó la inicialización de TrainingProvider para que requiera token
- Se actualizaron los modelos de entrenamiento para alinear las propiedades
- Se añadieron nuevas rutas y mejoras de navegación

🔧 Cambios técnicos:

Backend:
- views.py (training):
- TrainingSessionViewSet optimizado para la gestión de próximas sesiones
- Se añadieron paginación y filtros en los listados
- Se mejoró la gestión de errores en las operaciones CRUD
- Se implementó la nueva funcionalidad attendance_stats

Frontend:
1. Proveedores:
- training_provider.dart:
- El constructor ahora requiere token para la autenticación
- Se renombraron los métodos para mayor consistencia (fetch* en lugar de load*)
- Implementación de métodos de estadísticas y filtros

2. Modelos:
- training_models.dart:
- TrainingProgramModel: Nuevos campos: duración, tipo y estado
- TrainingSessionModel: Campos actualizados programName, sessionDate
- TrainingAttendanceModel: Nuevo modelo para la gestión de asistencia

3. Vistas:
- Múltiples archivos en lib/views/training/:
- Inicialización del proveedor corregida
- Gestión correcta de tokens implementada
- Mejoras en la navegación y la gestión de estados

4. Widgets:
- Nueva estructura de carpetas para una mejor organización
- Componentes reutilizables para sesiones y programas
- Implementación de tarjetas de estadísticas y filtros

🎯 Objetivo:
1. Mejorar la seguridad con una gestión correcta de tokens
2. Optimizar el rendimiento de las consultas y la carga de datos
3. Unificar la estructura del modelo frontend/backend
4. Facilitar el mantenimiento con una mejor organización del código

💡 Motivación:
- Errores de compilación debido a inconsistencias del modelo
- Problemas de seguridad en la autenticación
- Dificultades en el mantenimiento del código debido a la desorganización
- Necesidad de una mejor experiencia de usuario en la navegación

📝 Pruebas:
- Permisos y roles verificados en rutas protegidas
- Paginación y filtros probados en listados
- Navegación por pantalla validada
- Token confirmado Persistencia entre sesiones


Basado en nuestra conversación y los cambios realizados, aquí está la documentación completa del commit:

```
feat(training): Conectar módulo de capacitación frontend con backend

Se implementó la conexión completa del módulo de capacitación entre frontend y 
backend, corrigiendo problemas de formato de datos y manejo de tipos.

CAMBIOS PRINCIPALES:

1. Corrección del modelo TrainingProgramModel:
- Se mejoró el manejo de duration_hours para evitar errores de conversión null
- Se agregó manejo seguro de parseo de string a double
- Se implementó lógica de fallback para valores inválidos

2. Corrección en program_form_screen.dart:
- Se actualizó el dropdown de tipos para usar IDs numéricos
- Se modificó _saveProgram() para enviar datos en formato correcto
- Se inicializó _selectedType con ID válido ('1')
- Se actualizó _populateForm() para manejar type IDs

3. Formato de datos alineado con el backend:
Backend espera:
{
    "name": string,
    "description": string,
    "training_type": number,
    "duration_hours": string/number,
    "objectives": string,
    "is_active": boolean
}

ARCHIVOS MODIFICADOS:

frontend/lib/models/training_models.dart:
- Actualizado TrainingProgramModel.fromJson()
- Agregada función parseDuration() para manejo seguro
- Mejorado manejo de tipos nullables

frontend/lib/views/training/forms/program_form_screen.dart:
- Modificado _saveProgram()
- Actualizado dropdown de tipos
- Corregida inicialización de variables
- Mejorado manejo de edición

RAZÓN DE LOS CAMBIOS:

1. Error al crear programas:
- El backend esperaba training_type como número pero recibía string
- Los valores de duration_hours causaban errores de conversión
- Faltaba manejo de tipos nullables en el modelo

2. Problemas de display:
- Los programas no se mostraban por errores de conversión
- El dropdown de tipos no funcionaba por formato incorrecto
- Las sesiones no cargaban por errores en cascada

MEJORAS IMPLEMENTADAS:

1. Manejo de Datos:
- Conversión segura de tipos
- Validación de datos antes de envío
- Manejo consistente de IDs numéricos

2. UX:
- Dropdowns funcionando correctamente
- Visualización correcta de programas existentes
- Creación exitosa de nuevos programas

3. Estabilidad:
- Manejo de errores mejorado
- Prevención de crashes por datos nulos
- Formato de datos consistente

NOTAS TÉCNICAS:

1. Formato de duration_hours:
- Backend acepta tanto string como número
- Frontend convierte todo a double internamente
- Se mantiene precisión decimal

2. IDs de Tipos:
- Se usan IDs numéricos internamente
- UI muestra nombres amigables
- Conversión automática en forms

3. Validaciones:
- Agregadas validaciones de formato
- Verificación de campos requeridos
- Conversión segura de tipos

TESTING REALIZADO:

1. Creación de programas ✓
2. Listado de programas ✓
3. Edición de programas ✓
4. Creación de sesiones ✓
5. Listado de sesiones ✓

La conexión ahora funciona correctamente y mantiene la integridad de datos
entre frontend y backend.
```

Este commit documenta todos los cambios necesarios que se realizaron para hacer funcionar correctamente la conexión entre el frontend y backend del módulo de capacitación, incluyendo las correcciones de errores y mejoras implementadas.