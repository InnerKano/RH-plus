# RH Plus

Sistema de Gestión de Recursos Humanos con backend en Django y frontend en Flutter.

![RH Plus Logo](docs/images/logo.png)

## Descripción

RH Plus es una solución integral para la gestión de Recursos Humanos que permite administrar los procesos de:
- Selección y contratación de personal
- Afiliación a seguridad social
- Gestión de nómina y liquidaciones
- Evaluación de desempeño
- Capacitación del personal

El sistema está desarrollado con una arquitectura modular y patrones de diseño MVC, Observador y Repositorio.

## Estructura del Proyecto

```
rh_plus/
├── backend/              # Proyecto Django
│   ├── manage.py
│   ├── config/           # Configuración global
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
    └── arquitectura.md    # Documentación técnica
```

## Requisitos Previos

### Backend (Django)
- Python 3.8 o superior
- PostgreSQL 12 o superior
- pip (gestor de paquetes de Python)
- virtualenv (recomendado)

### Frontend (Flutter)
- Flutter SDK 2.10 o superior
- Dart 2.16 o superior
- Android Studio / VS Code con extensiones Flutter y Dart
- Android SDK (para desarrollo para Android)
- Xcode (para desarrollo para iOS, solo en macOS)

## Instalación y Configuración

### Clonar el Repositorio

```powershell
git clone https://github.com/username/RH-plus.git
cd RH-plus
```

### Configurar el Backend (Django)

1. Crear y activar un entorno virtual:

```powershell
cd backend
python -m venv env
env\Scripts\activate
```

2. Instalar dependencias:

```powershell
pip install -r requirements.txt
```

3. Configurar la base de datos:

#### Opción A: Usar una base de datos remota (recomendado para producción)
- Cree un archivo `.env` en el directorio `backend/` con la URL de conexión:

```
DATABASE_URL=postgresql://username:password@host:port/database_name
```

#### Opción B: Usar una base de datos PostgreSQL local
- Cree una base de datos PostgreSQL 
- Actualice el archivo `.env` en el directorio `backend/`:

```
DATABASE_URL=postgresql://username:password@localhost:5432/rhplus
```

#### Opción C: Usar SQLite para desarrollo
- La configuración por defecto usará SQLite si no se proporciona una URL de base de datos
- No requiere configuración adicional, pero es menos potente que PostgreSQL

4. Migrar la base de datos:

```powershell
python manage.py migrate
```

5. Crear un superusuario:

```powershell
python manage.py createsuperuser
```

6. Cargar datos iniciales (opcional):

```powershell
python manage.py loaddata initial_data
```

7. Ejecutar el servidor de desarrollo:

```powershell
python manage.py runserver
```

El backend estará disponible en `http://localhost:8000/`.

### Configurar el Frontend (Flutter)

1. Instalar dependencias:

```powershell
cd frontend
flutter pub get
```

2. Actualizar la configuración de la API:

Edite el archivo `frontend/lib/utils/constants.dart` para apuntar a su servidor de API:

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:8000';
  // ...
}
```

3. Ejecutar la aplicación:

```powershell
flutter run -d chrome  # Para ejecutar en navegador web
# o
flutter run            # Para dispositivos conectados o emuladores
```

## Uso del Sistema

### Acceso al Sistema

1. **Backend Admin Panel**: Acceda al panel de administración en `http://localhost:8000/admin/` utilizando las credenciales del superusuario creado anteriormente.

2. **Aplicación Frontend**: Inicie sesión en la aplicación utilizando las mismas credenciales o un usuario creado específicamente para pruebas.

### Principales Módulos

- **Core**: Gestión de usuarios y autenticación
- **Selection**: Flujo de selección de candidatos
- **Affiliation**: Gestión de afiliaciones de empleados
- **Payroll**: Administración de contratos y nómina
- **Performance**: Evaluaciones de desempeño
- **Training**: Programas y sesiones de capacitación

## Despliegue en Producción

### Backend (Django)

1. Configuración de entorno de producción:

Cree un archivo `.env` en la raíz del proyecto backend con las variables de entorno:

```
DEBUG=False
SECRET_KEY=your-secure-secret-key
DATABASE_URL=postgres://user:password@host:port/database
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
```

2. Configuración del servidor web (ejemplo con Gunicorn y Nginx):

- Instalar Gunicorn:

```powershell
pip install gunicorn
```

- Configurar Nginx para servir el proyecto:

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /ruta/al/proyecto/backend;
    }

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://unix:/run/gunicorn.sock;
    }
}
```

- Crear un servicio systemd para Gunicorn:

```
[Unit]
Description=gunicorn daemon for RH Plus
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/ruta/al/proyecto/backend
ExecStart=/ruta/al/env/bin/gunicorn --access-logfile - --workers 3 --bind unix:/run/gunicorn.sock config.wsgi:application

[Install]
WantedBy=multi-user.target
```

3. Recolectar archivos estáticos:

```powershell
python manage.py collectstatic --noinput
```

### Frontend (Flutter)

1. Generar una versión de producción:

Para aplicación web:
```powershell
cd frontend
flutter build web --release
```

Para Android:
```powershell
flutter build apk --release
```

Para iOS (solo en macOS):
```powershell
flutter build ios --release
```

2. Desplegar:
   - **Web**: Copie los archivos generados en `build/web` a su servidor web o servicio de hosting.
   - **Android**: Use el archivo APK generado en `build/app/outputs/flutter-apk/app-release.apk` para distribuirlo o publicarlo en Google Play.
   - **iOS**: Utilice Xcode para subir la aplicación a la App Store.

## Seguridad y Respaldo

### Respaldo de la Base de Datos

Programe respaldos periódicos de la base de datos PostgreSQL:

```powershell
pg_dump -U username -d rhplus > backup_$(Get-Date -Format "yyyyMMdd").sql
```

### Actualizaciones

1. Actualizar el código:

```powershell
git pull origin main
```

2. Actualizar dependencias:

```powershell
# Backend
cd backend
.\env\Scripts\Activate
pip install -r requirements.txt
python manage.py migrate

# Frontend
cd frontend
flutter pub get
```

## Resolución de Problemas

### Problemas Comunes

1. **Error de conexión al Backend**:
   - Verificar que el servidor Django esté corriendo
   - Comprobar la URL en ApiConstants.baseUrl
   - Verificar el estado de la red

2. **Problemas de Autenticación**:
   - Verificar credenciales de usuario
   - Comprobar token JWT y su expiración

3. **Error en migraciones**:
   - Problemas con el modelo de usuario personalizado:
   ```
   Error: Reverse accessor 'Group.user_set' for 'auth.User.groups' clashes with reverse accessor for 'core.User.groups'
   ```
   Solución: Asegúrese de que `AUTH_USER_MODEL = 'core.User'` esté configurado en settings.py y que los campos `groups` y `user_permissions` tengan un `related_name` personalizado.
   
   - Realizar reset de migraciones si es necesario:
   ```powershell
   python manage.py migrate app_name zero
   python manage.py makemigrations app_name
   python manage.py migrate app_name
   ```
   
   - Si está usando un modelo de usuario personalizado y encuentra problemas, pruebe usar SQLite durante el desarrollo inicial:

## Contribuciones

Para contribuir al proyecto:

1. Haga un fork del repositorio
2. Cree una rama para su característica (`git checkout -b feature/amazing-feature`)
3. Haga commit de sus cambios (`git commit -m 'Add some amazing feature'`)
4. Haga push a la rama (`git push origin feature/amazing-feature`)
5. Abra un Pull Request

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - vea el archivo LICENSE para más detalles.

## Contacto

Equipo de Desarrollo - email@ejemplo.com

Link del Proyecto: [https://github.com/username/RH-plus](https://github.com/username/RH-plus)
