# Sistema de Autenticación IoT Microgrid

## 🚀 Cómo Acceder a la Aplicación

Para iniciar sesión en la aplicación, usa las siguientes credenciales:

### Credenciales de Acceso
- **Device ID**: `dev-001`
- **InfluxDB Token**: `m9dZ53tgCda7obiBCJn4xFVloD8q9zbqckGPvMzlPxJ3Jwb2ur6gGp-sgWD-KjHH5tvJIqgCSvpuVKeOHj66rw==`

### 🟡 Modo Demo (Sin infraestructura)
Si no tienes InfluxDB funcionando, puedes usar estas credenciales de demo:
- **Device ID**: `dev-001` 
- **InfluxDB Token**: `demo123`

**El modo demo se activa automáticamente cuando no puede conectar con InfluxDB.**

### Pasos para Acceder
1. Abre la aplicación
2. En la pantalla de login, ingresa:
   - **Device ID**: `dev-001`
   - **InfluxDB Token**: Copia y pega el token de arriba
3. Presiona "Iniciar Sesión"
4. ¡Listo! Ya puedes acceder a todas las funcionalidades

---

## Descripción
Sistema de autenticación JWT implementado para la aplicación IoT Microgrid que permite a los usuarios acceder con credenciales específicas del proyecto IoT.

## Características

### 🔐 Autenticación
- **Device ID + InfluxDB Token**: Sistema de login contextual al proyecto IoT
- **Validación en tiempo real**: Verificación del token contra InfluxDB
- **Manejo de estados**: Loading, success, error states

### 💾 Almacenamiento Local
- **SharedPreferences** (datos no sensibles):
  - Device ID
  - Organización
  - Bucket
  - Fecha de login
- **FlutterSecureStorage** (datos sensibles):
  - Token de InfluxDB

### 📱 Interfaz de Usuario
- **Pantalla de Login**: Diseño moderno con validación
- **Splash Screen**: Verificación automática de sesión
- **Pantalla de Evidencia**: Visualización de datos almacenados
- **Integración en Configuraciones**: Acceso fácil desde el menú

## Arquitectura

### Clean Architecture
```
features/auth/
├── domain/
│   ├── entities/           # User, LoginCredentials
│   ├── repositories/       # Contratos abstractos
│   └── usecases/          # Lógica de negocio
├── data/
│   ├── models/            # Modelos de datos
│   ├── services/          # Servicios externos
│   └── repositories/      # Implementaciones
└── presentation/
    ├── providers/         # Estado de autenticación
    └── screens/           # Pantallas UI
```

## Uso

### 1. Credenciales de Login
- **Device ID**: Identificador del dispositivo IoT (ej: "dev-001", "microgrid-central")
- **InfluxDB Token**: Token de acceso a la base de datos InfluxDB

### 2. Flujo de Autenticación
1. Usuario ingresa credenciales
2. Sistema valida token contra InfluxDB
3. Si es válido, guarda datos localmente
4. Navega a la aplicación principal

### 3. Verificación de Sesión
- Al iniciar la app, verifica automáticamente si hay sesión activa
- Valida que el token siga siendo válido
- Si hay problemas, redirige al login

## Configuración

### Dependencias Requeridas
```yaml
dependencies:
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  http: ^1.1.0
  flutter_dotenv: ^5.1.0
```

### Variables de Entorno (.env)
```env
INFLUXDB_URL=http://10.0.2.2:8086
INFLUXDB_TOKEN=tu_token_aqui
INFLUXDB_ORG=microgrid
INFLUXDB_BUCKET=telemetry
```

## Pantallas

### 🏠 Splash Screen
- Verificación automática de autenticación
- Loading indicator mientras verifica
- Navegación automática según el estado

### 🔑 Login Screen
- Campos: Device ID + InfluxDB Token
- Validación en tiempo real
- Manejo de errores
- Diseño consistente con el tema de la app

### 📊 Evidence Screen
- Información del usuario (Device ID, Organización, Bucket)
- Estado de la sesión (duración, válido/inválido)
- Estado del token de seguridad
- Botón de logout

### ⚙️ Settings Integration
- Acceso a pantalla de evidencia
- Opción de logout
- Integrado en el menú de configuraciones

## Seguridad

### Almacenamiento Seguro
- **Token de InfluxDB**: Almacenado con `flutter_secure_storage`
- **Datos de usuario**: Almacenados con `shared_preferences`
- **Validación**: Token verificado contra InfluxDB en cada sesión

### Manejo de Errores
- Errores de red
- Tokens inválidos
- Problemas de conexión a InfluxDB
- Estados de carga y error en UI

## Casos de Uso

### Login
```dart
final authNotifier = AuthDependencyInjection.getAuthNotifier();
await authNotifier.login('dev-001', 'your_influxdb_token');
```

### Logout
```dart
await authNotifier.logout();
```

### Verificar Estado
```dart
await authNotifier.checkAuthStatus();
```

