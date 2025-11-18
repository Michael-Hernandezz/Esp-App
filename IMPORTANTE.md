# 📋 INFORMACIÓN IMPORTANTE - IoT Microgrid BMS App

## 🌐 Servidor de Producción
- **IP**: `104.131.178.99`
- **Plataforma**: DigitalOcean Droplet (Ubuntu 22.04, 1GB RAM)
- **Fecha de Despliegue**: 18 de noviembre de 2025

---

## 📊 Variables del Sistema (Sensores BMS)

El sistema monitorea **8 variables principales**:

| # | Variable | Descripción | Rango Adecuado | Rango Anormal | Rango Máximo | Unidades |
|---|----------|-------------|----------------|---------------|--------------|----------|
| 1 | `v_bat_conv` | Voltaje convertidor entrada | 8.7 - 12.3 | < 8.7 o > 12.3 | 0 - 12.6 | V |
| 2 | `v_out_conv` | Voltaje convertidor salida | 11.5 - 12.5 | < 11.5 o > 12.5 | 0 - 30 | V |
| 3 | `v_cell1` | Voltaje celda 1 | 3.6 - 4.2 | < 3.6 | 0 - 4.2 | V |
| 4 | `v_cell2` | Voltaje celda 2 | 3.6 - 4.2 | < 3.6 | 0 - 4.2 | V |
| 5 | `v_cell3` | Voltaje celda 3 | 3.6 - 4.2 | < 3.6 | 0 - 4.2 | V |
| 6 | `i_circuit` | Corriente del circuito | < 3 | > 4 | 0 - 4 | A |
| 7 | `soh_percent` | Salud de batería (SOH) | > 70 | < 70 | 0 - 100 | % |
| 8 | `soc_percent` | Estado de carga (SOC) | Calculado | - | 0 - 100 | % |

### Cálculo de SOC
El SOC se calcula basado en el voltaje de entrada:
- **12.6V** = 100% de carga
- **0V** = 0% de carga

---

## 🎛️ Actuadores

**Actualmente**: El sistema está configurado para **monitoreo únicamente**.
- No hay actuadores implementados en esta versión.
- El enfoque principal es la visualización de datos del BMS en tiempo real.

---

## 🖥️ Servicios y Puertos

| Servicio | Puerto | URL de Acceso | Descripción |
|----------|--------|---------------|-------------|
| **InfluxDB** | 8086 | `http://104.131.178.99:8086` | Base de datos de series temporales |
| **Mosquitto MQTT** | 1883 | `104.131.178.99:1883` | Broker MQTT para telemetría |
| **FastAPI** | 8000 | `http://104.131.178.99:8000` | API REST del sistema |
| **Telegraf** | - | (interno) | Conecta MQTT → InfluxDB |

---

## 🔐 Acceso a InfluxDB

### Credenciales de Acceso
```
URL: http://104.131.178.99:8086
Usuario: admin
Contraseña: admin12345
Organización: microgrid
Bucket: telemetry
Token: m9dZ53tgCda7obiBCJn4xFVloD8q9zbqckGPvMzlPxJ3Jwb2ur6gGp-sgWD-KjHH5tvJIqgCSvpuVKeOHj66rw==
```

### Pasos para Acceder
1. Abre tu navegador web
2. Navega a `http://104.131.178.99:8086`
3. Inicia sesión con:
   - Usuario: `admin`
   - Contraseña: `admin12345`
4. En la interfaz de InfluxDB:
   - Ve a **Data Explorer** para consultar datos
   - Selecciona el bucket `telemetry`
   - Filtra por measurement `telemetry`
   - Selecciona los campos deseados (v_bat_conv, v_cell1, etc.)

---

## 📱 Páginas de la Aplicación Flutter

La aplicación tiene **5 pantallas principales** accesibles desde la barra de navegación inferior:

| # | Pantalla | Icono | Descripción |
|---|----------|-------|-------------|
| 1 | **Home** | 🏠 | Pantalla principal con información general |
| 2 | **Dashboard** | 📊 | Dashboard completo con gráficos y notificaciones del BMS |
| 3 | **History** | 📜 | Historial de eventos y datos |
| 4 | **Notifications** | 🔔 | Centro de notificaciones del sistema |
| 5 | **Settings** | ⚙️ | Configuración de la aplicación |

### Pantalla Principal: Dashboard
La pantalla de Dashboard incluye:
- **Widget de Notificaciones**: Alertas en tiempo real basadas en rangos de sensores
- **System Overview**: Resumen del estado del sistema
- **BMS Widget**: Información detallada del Battery Management System
- **Gráficos en Tiempo Real**:
  - Voltaje de Batería (v_bat_conv)
  - Voltaje de Salida (v_out_conv)
  - Voltaje de Celdas (v_cell1, v_cell2, v_cell3)
  - Corriente del Circuito (i_circuit)
  - SOC y SOH

**Auto-refresh**: Todos los datos se actualizan automáticamente cada **3 segundos**.

---

## 🔔 Sistema de Notificaciones

Las notificaciones se generan automáticamente cuando los sensores salen de sus rangos normales:

### Severidades
- **🔴 Crítico (Critical)**: Valores en rango anormal peligroso
  - `v_bat_conv < 8.7V`
  - `i_circuit > 4A`
  - Campo `alert = 1`

- **⚠️ Advertencia (Warning)**: Valores fuera de rango adecuado
  - `v_out_conv` fuera de 11.5-12.5V
  - Cualquier celda `< 3.6V`

- **ℹ️ Información (Info)**: Notificaciones informativas
  - `SOC ≥ 95%` (batería completamente cargada)
  - `SOH` si está degradado pero funcional

---

## 🐳 Docker Compose Stack

Los servicios están orquestados con Docker Compose:

```yaml
servicios:
  - mosquitto (MQTT Broker)
  - influxdb (Base de datos)
  - telegraf (Recolector de métricas)
  - api (FastAPI backend)
```

### Comandos Útiles
```bash
# Ver estado de contenedores
docker ps

# Ver logs de un servicio
docker logs mosquitto
docker logs influxdb
docker logs telegraf

# Reiniciar servicios
cd infra
docker-compose restart

# Detener servicios
docker-compose down

# Iniciar servicios
docker-compose up -d
```

---

## 📂 Estructura del Proyecto

```
Esp-App/
├── api/               # FastAPI backend
├── firmware/          # Código ESP32 (PlatformIO)
├── infra/             # Infraestructura Docker
│   ├── docker-compose.yml
│   ├── mosquitto/     # Config MQTT
│   └── telegraf/      # Config Telegraf
├── iot/               # Aplicación Flutter
│   ├── lib/
│   │   ├── features/
│   │   │   ├── dashboard/  # Pantalla principal
│   │   │   ├── home/
│   │   │   ├── history/
│   │   │   ├── notifications/
│   │   │   └── settings/
│   │   └── core/
│   └── .env           # Variables de entorno
└── tools/             # Scripts de prueba
```

---

## 🔧 Configuración de la App Flutter

### Archivo `.env`
```env
INFLUXDB_URL=http://104.131.178.99:8086
INFLUXDB_TOKEN=m9dZ53tgCda7obiBCJn4xFVloD8q9zbqckGPvMzlPxJ3Jwb2ur6gGp-sgWD-KjHH5tvJIqgCSvpuVKeOHj66rw==
INFLUXDB_ORG=microgrid
INFLUXDB_BUCKET=telemetry
```

---

## 🧪 Scripts de Simulación

### `simulate_device.py`
Simula un dispositivo BMS enviando datos MQTT:
```bash
cd tools
python simulate_device.py
```

Configuración:
- **BROKER**: `104.131.178.99`
- **PORT**: `1883`
- **TOPIC**: `microgrid/telemetry`
- **Intervalo**: 2 segundos

---

## 📊 Flujo de Datos

```
ESP32/Simulador → MQTT (1883) → Telegraf → InfluxDB (8086) → Flutter App
                                                    ↓
                                            FastAPI (8000)
```

---

## ⚡ Características Clave

1. **Monitoreo en Tiempo Real**: Actualización cada 3 segundos
2. **Notificaciones Inteligentes**: Basadas en rangos de sensores
3. **Gráficos Interactivos**: Visualización de datos históricos con 30 puntos
4. **Sistema de Alertas**: 3 niveles de severidad (Crítico, Advertencia, Info)
5. **Multi-plataforma**: Flutter soporta Android, iOS, Web
6. **Arquitectura Escalable**: Docker Compose para fácil despliegue

---

## 🚀 Cómo Ejecutar la App

### Requisitos
- Flutter SDK ^3.9.0
- Dart SDK
- Android Studio / Xcode (para móvil)
- Acceso a internet (para conectar al servidor de producción)

### Comandos
```bash
cd iot

# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Compilar APK (Android)
flutter build apk --release

# Compilar para iOS
flutter build ios --release
```

---

## 📝 Notas Adicionales

- **Rama Actual**: `recuperacion-emergency`
- **Repositorio**: `Michael-Hernandezz/Esp-App`
- **Fecha de Última Actualización**: 18 de noviembre de 2025
- **Estado**: ✅ Producción - Completamente funcional

---

## 🆘 Solución de Problemas

### La app no muestra datos
1. Verifica que `simulate_device.py` esté corriendo
2. Comprueba la conexión a `104.131.178.99:8086`
3. Revisa los logs de InfluxDB: `docker logs influxdb`

### Notificaciones no aparecen
1. Verifica que los sensores estén enviando datos fuera de rango
2. Comprueba que el auto-refresh esté activo (cada 3 segundos)
3. Revisa la consola de Flutter para errores

### No puedo acceder a InfluxDB
1. Verifica que el puerto 8086 esté abierto en el firewall
2. Confirma que el contenedor esté corriendo: `docker ps | grep influxdb`
3. Prueba la conexión: `curl http://104.131.178.99:8086/ping`

---

**Desarrollado por**: Michael Hernández  
**Institución**: Proyecto IoT Microgrid BMS  
**Tecnologías**: Flutter, InfluxDB, MQTT, Docker, FastAPI