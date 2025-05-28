# Workflow del Sistema RH-Plus

Basado en el análisis de todos los módulos del sistema RH-Plus, puedo explicarte el workflow que debería seguir un usuario administrador o cualquier usuario que gestione el sistema. El sistema está diseñado como una plataforma integral de Recursos Humanos con varios módulos interconectados.

## Usuarios y Roles del Sistema

RH Plus es un sistema de gestión de recursos humanos diseñado principalmente para el personal de RRHH, pero con diferentes roles y niveles de acceso:
0. Superuser(dev o dios)
1. **Administradores del sistema**: Tienen acceso completo a todas las funcionalidades.
2. **Personal de RRHH**: Usuarios principales que gestionan los procesos de selección, contratación, nómina, etc.
3. **Supervisores/Gerentes**: Pueden ver información de sus equipos, realizar evaluaciones de desempeño.
4. **Empleados**: Acceso limitado a sus propios datos, evaluaciones y capacitaciones.

## Flujo General del Sistema

### 1. Autenticación y Acceso

1. **Inicio de Sesión**: 
   - El usuario accede al sistema mediante la pantalla de login
   - Ingresa sus credenciales (email y contraseña)
   - El sistema valida las credenciales contra la base de datos
   - Si son válidas, genera un token JWT para la sesión

2. **Dashboard Principal**:
   - Tras la autenticación exitosa, el usuario accede al dashboard
   - El dashboard muestra resúmenes de los diferentes módulos:
     - Conteo de empleados activos
     - Candidatos en proceso
     - Sesiones de capacitación próximas
     - Período de nómina actual
     - Actividades recientes del sistema

## Flujos Específicos por Módulo

### 2. Módulo de Selección (Selection)

**Objetivo**: Gestionar el proceso de reclutamiento y selección de candidatos.

1. **Crear un Proceso de Selección**:
   - El usuario crea un nuevo proceso de selección para una posición específica
   - Define nombre, descripción, fechas de inicio/fin

2. **Configurar Etapas del Proceso**:
   - Define las etapas del proceso de selección (revisión de CV, entrevista inicial, prueba técnica, etc.)
   - Asigna un orden a cada etapa para establecer el flujo del proceso

3. **Registrar Candidatos**:
   - Registra nuevos candidatos con su información personal
   - Sube documentos relevantes como CV, certificaciones, etc.
   - Asigna los candidatos a un proceso de selección específico

4. **Gestionar el Avance de Candidatos**:
   - Actualiza el estado de los candidatos según avanzan en el proceso
   - Registra notas sobre cada candidato
   - Actualiza la etapa actual de cada candidato en el proceso

5. **Finalizar Proceso**:
   - Marca candidatos como HIRED (contratados), REJECTED (rechazados) o WITHDRAWN (retirados)
   - Los candidatos contratados pueden pasar al módulo de Afiliación

### 3. Módulo de Afiliación (Affiliation)

**Objetivo**: Gestionar empleados y sus afiliaciones a servicios de seguridad social.

1. **Crear Empleados**:
   - Crea un nuevo empleado a partir de un candidato contratado
   - Completa información adicional como posición, departamento, fecha de contratación

2. **Gestionar Tipos de Afiliación**:
   - Define los tipos de afiliación (EPS, ARL, Pensión, etc.)
   - Configura los proveedores disponibles para cada tipo

3. **Registrar Afiliaciones**:
   - Asigna a cada empleado sus afiliaciones específicas
   - Registra fechas de inicio, números de afiliación y proveedores

4. **Actualizar Estado de Empleados**:
   - Mantiene actualizado el estado de los empleados (ACTIVE, INACTIVE, ON_LEAVE, TERMINATED)
   - Registra fechas de terminación cuando corresponda

### 4. Módulo de Nómina (Payroll)

**Objetivo**: Gestionar contratos, períodos de nómina y pagos a empleados.

1. **Crear Contratos**:
   - Registra contratos para los empleados
   - Especifica tipo de contrato, salario, posición, departamento, horario

2. **Definir Períodos de Nómina**:
   - Crea períodos de nómina (mensuales, quincenales, etc.)
   - Establece fechas de inicio y fin

3. **Configurar Conceptos de Pago**:
   - Define conceptos de ingresos (salario base, bonificaciones, etc.)
   - Define conceptos de deducciones (impuestos, seguridad social, etc.)

4. **Generar Entradas de Nómina**:
   - Crea entradas de nómina para cada empleado y período
   - Agrega los detalles específicos (ingresos y deducciones)
   - El sistema calcula automáticamente los totales

5. **Aprobar Nómina**:
   - Revisa y aprueba las entradas de nómina
   - Cierra períodos de nómina cuando todos los pagos están completos

### 5. Módulo de Desempeño (Performance)

**Objetivo**: Gestionar evaluaciones de desempeño y planes de mejora.

1. **Configurar Tipos de Evaluación**:
   - Define los tipos de evaluación (anual, semestral, trimestral)
   - Establece los criterios de evaluación con sus pesos correspondientes

2. **Crear Períodos de Evaluación**:
   - Programa períodos específicos para cada tipo de evaluación
   - Define fechas de inicio y fin

3. **Realizar Evaluaciones**:
   - Asigna evaluaciones específicas a los empleados
   - Los evaluadores completan los puntajes para cada criterio
   - El sistema calcula automáticamente la puntuación general ponderada

4. **Solicitar Retroalimentación**:
   - Solicita comentarios del empleado sobre su evaluación
   - Completa la evaluación con los comentarios recibidos

5. **Crear Planes de Mejora**:
   - Para empleados que requieren desarrollo adicional
   - Define objetivos específicos, plazos y responsables
   - Hace seguimiento del progreso de cada objetivo

### 6. Módulo de Capacitación (Training)

**Objetivo**: Gestionar programas de capacitación, sesiones y asistencias.

1. **Definir Tipos de Capacitación**:
   - Configura diferentes tipos (inducción, desarrollo de habilidades, etc.)
   - Establece descripciones y propósitos

2. **Crear Programas de Capacitación**:
   - Define programas específicos con objetivos y materiales
   - Asigna un tipo de capacitación a cada programa
   - Especifica duración y contenido

3. **Programar Sesiones**:
   - Crea sesiones específicas para cada programa
   - Define fechas, horarios, ubicación e instructor
   - Establece el número máximo de participantes

4. **Gestionar Asistencia**:
   - Registra empleados para cada sesión
   - Marca asistencias (ATTENDED, MISSED, EXCUSED)
   - Actualiza el estado de las sesiones (SCHEDULED, IN_PROGRESS, COMPLETED)

5. **Recopilar Evaluaciones**:
   - Los asistentes evalúan diferentes aspectos de la capacitación
   - El sistema calcula automáticamente puntuaciones medias
   - Registra comentarios y sugerencias de mejora

### 7. Módulo Core (Usuarios y Seguridad)

**Objetivo**: Gestionar usuarios, roles y seguridad del sistema.

1. **Administrar Usuarios**:
   - Crear nuevos usuarios del sistema
   - Asignar roles y permisos específicos

2. **Gestionar Roles**:
   - Define roles personalizados (Administrador, RRHH, Supervisor, etc.)
   - Configura permisos específicos para cada rol

3. **Monitorear Actividades**:
   - Revisa el registro de actividades del sistema
   - Supervisa acciones críticas realizadas por los usuarios

## Workflow Típico para un Nuevo Empleado

Para ilustrar cómo se integran todos los módulos, aquí está el flujo típico de un nuevo empleado:

1. **Selección**:
   - Se registra como candidato en un proceso de selección
   - Avanza por las diferentes etapas del proceso
   - Es marcado como HIRED (contratado)

2. **Afiliación**:
   - Se crea un nuevo empleado basado en el candidato
   - Se registran sus afiliaciones a seguridad social
   - Se completa su información personal y laboral

3. **Nómina**:
   - Se registra un contrato para el empleado
   - Se incluye en los períodos de nómina activos
   - Se generan sus pagos regularmente

4. **Capacitación**:
   - Se asigna a programas de inducción
   - Asiste a sesiones de capacitación
   - Evalúa las capacitaciones recibidas

5. **Desempeño**:
   - Se incluye en los ciclos de evaluación
   - Recibe evaluaciones periódicas
   - Si es necesario, se implementan planes de mejora

## Consideraciones Importantes y Mejoras Potenciales

Basado en el análisis de código, hay algunas áreas donde el workflow podría optimizarse:

1. **Integración entre módulos**: Reforzar la conexión entre Selección y Afiliación para facilitar la transición de candidatos a empleados.

2. **Automatización de procesos**: Implementar más triggers automáticos, como notificaciones cuando un empleado debe ser evaluado o cuando se aproxima una sesión de capacitación.

3. **Reportes y análisis**: Agregar dashboards específicos por módulo para facilitar la toma de decisiones.

4. **Validaciones**: Implementar validaciones más robustas para evitar inconsistencias de datos entre módulos.

El sistema RH-Plus ya cuenta con una estructura sólida que cubre todo el ciclo de vida de un empleado, desde su contratación hasta su eventual salida, con capacidades para gestionar su desarrollo, evaluación y compensación durante su permanencia en la empresa.


# Implementación de la Funcionalidad de Registro de Usuarios en RH-Plus

**Fecha:** 26 de mayo de 2025

## Resumen General

Se ha implementado una funcionalidad completa de registro de usuarios en el sistema RH-Plus, permitiendo a nuevos usuarios crear sus cuentas de manera autónoma. Esta implementación abarca tanto el backend (Django) como el frontend (Flutter), aprovechando la estructura modular existente y manteniendo la coherencia visual con el resto de la aplicación.

## Cambios Realizados

### 1. Backend (Django)

#### 1.1 Serializer para Registro de Usuarios
- **Ubicación**: serializers.py
- **Funcionalidad**: Se creó un nuevo serializer `UserRegistrationSerializer` que:
  - Valida las contraseñas utilizando validadores de Django
  - Verifica que las contraseñas coincidan
  - Utiliza el `create_user` del modelo personalizado para el registro
  - Maneja los campos email, password, password_confirm, first_name y last_name

```python
class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration."""
    
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True, required=True)
    
    class Meta:
        model = User
        fields = ('email', 'password', 'password_confirm', 'first_name', 'last_name')
        
    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({"password_confirm": "Las contraseñas no coinciden"})
        return attrs
    
    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
        )
        return user
```

#### 1.2 Endpoint para Registro de Usuarios
- **Ubicación**: views.py
- **Funcionalidad**: Se agregó una acción `register` al `UserViewSet` que:
  - Permite acceso sin autenticación (permission_classes=[permissions.AllowAny])
  - Utiliza el serializer de registro para validar y crear el usuario
  - Registra una actividad del sistema cuando se crea un nuevo usuario
  - Retorna una respuesta adecuada indicando éxito o error

```python
@action(detail=False, methods=['post'], permission_classes=[permissions.AllowAny])
def register(self, request):
    """Register a new user."""
    serializer = UserRegistrationSerializer(data=request.data)
    
    if serializer.is_valid():
        user = serializer.save()
        
        # Create a system activity for the registration
        SystemActivity.objects.create(
            title="Nuevo usuario registrado",
            description=f"Se ha registrado el usuario {user.email}",
            type="employee"
        )
        
        # Return success response
        return Response(
            {"message": "Usuario registrado exitosamente"},
            status=status.HTTP_201_CREATED
        )
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
```

### 2. Frontend (Flutter)

#### 2.1 Actualización de Constantes API y Rutas
- **Ubicación**: constants.dart
- **Funcionalidad**:
  - Se agregó la URL del endpoint de registro en `ApiConstants`
  - Se añadió la ruta de registro en `RouteNames`
  - Se incorporaron textos necesarios para la pantalla de registro en `AppStrings`

```dart
// API Constants
static const String registerUrl = '$baseUrl/api/core/users/register/';

// Route Names
static const String register = '/register';

// App Strings
static const String register = 'Registrarse';
static const String firstName = 'Nombre';
static const String lastName = 'Apellido';
static const String confirmPassword = 'Confirmar Contraseña';
```

#### 2.2 Implementación del Método de Registro en AuthProvider
- **Ubicación**: auth_provider.dart
- **Funcionalidad**: Se creó un método `register` que:
  - Envía los datos de registro al backend
  - Maneja tanto los casos de éxito como los errores
  - Proporciona información detallada sobre los errores específicos por campo
  - Mantiene la consistencia con la implementación existente de login

```dart
Future<Map<String, dynamic>> register(String email, String password, String passwordConfirm, String firstName, String lastName) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    // Implementación de la solicitud HTTP
    // Manejo de respuestas y errores
    // Retorno de resultado estructurado
  } catch (e) {
    // Manejo de excepciones
  }
}
```

#### 2.3 Creación de la Pantalla de Registro
- **Ubicación**: register_screen.dart
- **Funcionalidad**: Se implementó una pantalla completa de registro que:
  - Mantiene coherencia visual con la pantalla de login
  - Incluye campos para email, nombre, apellido, contraseña y confirmación
  - Implementa validaciones en el frontend para todos los campos
  - Muestra errores específicos retornados por el backend
  - Proporciona navegación entre pantallas de login y registro

#### 2.4 Actualización de la Pantalla de Login
- **Ubicación**: login_screen.dart
- **Funcionalidad**: Se agregó un enlace a la pantalla de registro
  - Permite a los usuarios navegar fácilmente a la pantalla de registro
  - Mantiene una experiencia de usuario coherente

```dart
// Register link
TextButton(
  onPressed: () {
    Navigator.pushReplacementNamed(context, RouteNames.register);
  },
  child: const Text('¿No tienes cuenta? Regístrate'),
)
```

#### 2.5 Actualización de Rutas de la Aplicación
- **Ubicación**: main.dart
- **Funcionalidad**: Se agregó la ruta de registro al mapa de rutas de la aplicación
  - Permite la navegación correcta entre pantallas
  - Integra la nueva pantalla con el sistema de navegación existente

## Beneficios Implementados

1. **Autoservicio de Usuarios**: Los usuarios pueden registrarse de forma autónoma sin necesidad de un administrador
2. **Validación Robusta**: Implementación de validaciones tanto en frontend como en backend
3. **Experiencia de Usuario Mejorada**: Diseño coherente con el resto de la aplicación
4. **Feedback Claro**: Mensajes de error específicos y claros para los usuarios
5. **Auditabilidad**: Registro de nuevos usuarios en el sistema de actividades para seguimiento

## Consideraciones de Seguridad

1. **Validación de Contraseñas**: Uso de los validadores de Django para garantizar contraseñas seguras
2. **Protección de Datos**: Las contraseñas se almacenan hasheadas utilizando los mecanismos de Django
3. **Acceso Controlado**: El endpoint de registro está abierto, pero todas las demás funcionalidades requieren autenticación

## Pruebas Realizadas

- Registro exitoso de usuario con datos válidos
- Manejo adecuado de errores (contraseñas que no coinciden, email duplicado, campos faltantes)
- Navegación correcta entre pantallas de login y registro
- Verificación de la creación de actividad del sistema al registrar un usuario

## Próximos Pasos

1. **Confirmación de Email**: Implementar verificación de correo electrónico para nuevos usuarios
2. **Roles Predeterminados**: Asignar automáticamente roles básicos a nuevos usuarios
3. **Protección contra Spam**: Agregar medidas como CAPTCHA o rate limiting para prevenir registros automatizados
4. **Recuperación de Contraseña**: Implementar funcionalidad de recuperación de contraseña

Esta implementación representa un paso importante hacia un sistema más accesible y autónomo, manteniendo al mismo tiempo los estándares de seguridad y la coherencia con la arquitectura existente.