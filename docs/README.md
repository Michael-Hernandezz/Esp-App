# Documentación del Sistema Microgrid IoT

## Descripción General

Este sistema IoT está diseñado para el monitoreo y control de microgrids, utilizando ESP32 como dispositivo de campo, MQTT para comunicación, InfluxDB para almacenamiento de series temporales, y múltiples interfaces de visualización incluyendo Grafana y una aplicación móvil Flutter.

## Arquitectura del Sistema

![Diagrama de Arquitectura](./architecture-diagram.svg)

## Componentes Principales

### 1. Dispositivos IoT

#### ESP32 (Dispositivo Principal)
- **Función**: Recolección de datos de sensores y envío vía MQTT
- **Conectividad**: WiFi
- **Sensores**: Voltaje, Corriente, Temperatura
- **Firmware**: C++ con PlatformIO
- **Device ID**: `dev-001` (configurable)

#### Simulador Python
- **Archivo**: `tools/simulate_device.py`
- **Función**: Simular dispositivos ESP32 para desarrollo y pruebas
- **Configuración**: Variables de entorno

### 2. Comunicación

#### Eclipse Mosquitto (MQTT Broker)
- **Puerto**: 1883
- **Autenticación**: Usuario/contraseña
- **Topics**:
  - `microgrid/{device_id}/telemetry` - Datos de telemetría
  - `microgrid/{device_id}/cmd` - Comandos
  - `microgrid/{device_id}/cfg` - Configuración
  - `microgrid/{device_id}/status` - Estado del dispositivo

### 3. Procesamiento de Datos

#### Telegraf
- **Función**: Recolector de datos MQTT → InfluxDB
- **Versión**: 1.30
- **Configuración**: `/telegraf/telegraf.conf`

#### FastAPI
- **Puerto**: 8000
- **Función**: API REST para aplicación móvil
- **Framework**: Python FastAPI con Uvicorn

### 4. Almacenamiento

#### InfluxDB
- **Puerto**: 8086
- **Versión**: 2.7
- **Organización**: microgrid
- **Bucket**: telemetry
- **Token**: my-super-secret-token

### 5. Visualización

#### Grafana
- **Puerto**: 3000
- **Usuario**: admin
- **Contraseña**: admin12345
- **Función**: Dashboards web para análisis de datos

#### Aplicación Flutter
- **Plataformas**: Android/iOS
- **Conexión**: REST API
- **Función**: Monitoreo móvil y control remoto

## Formato de Datos

### Mensaje de Telemetría
```json
{
  "v": 24.05,           // Voltaje (V)
  "i": 4.98,            // Corriente (A)
  "p": 119.85,          // Potencia (W)
  "temp": 35.2,         // Temperatura (°C)
  "status": "ok",       // Estado del dispositivo
  "timestamp": "2025-09-18T10:30:45Z"
}
```

### Mensaje de Comando
```json
{
  "setpoint_v": 24.0,   // Voltaje objetivo
  "setpoint_i": 5.0,    // Corriente objetivo
  "enable": true        // Habilitar/deshabilitar
}
```

### Mensaje de Configuración
```json
{
  "report_period_ms": 1000  // Período de reporte en ms
}
```

## Instalación y Configuración

### Prerrequisitos
- Docker y Docker Compose
- Python 3.8+ (para simulador)
- PlatformIO (para ESP32)
- Flutter SDK (para app móvil)

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/Michael-Hernandezz/Esp-App.git
   cd Esp-App
   ```

2. **Configurar variables de entorno**
   ```bash
   cd infra
   cp .env.example .env
   # Editar .env con los valores apropiados
   ```

3. **Iniciar servicios de infraestructura**
   ```bash
   cd infra
   docker-compose up -d
   ```

4. **Verificar estado de servicios**
   ```bash
   docker-compose ps
   ```

### Configuración de Credenciales

Todos los servicios usan las siguientes credenciales:
- **Usuario**: admin
- **Contraseña**: admin12345

#### InfluxDB
- **Token**: my-super-secret-token
- **Organización**: microgrid
- **Bucket**: telemetry

## Uso del Sistema

### Simular Dispositivo
```bash
cd tools
python simulate_device.py
```

### Acceso a Interfaces

- **Grafana**: http://localhost:3000
- **InfluxDB UI**: http://localhost:8086
- **API Docs**: http://localhost:8000/docs

### Monitoreo de Logs
```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs específicos
docker-compose logs -f telegraf
docker-compose logs -f influxdb
```

## Desarrollo

### ESP32
- **Framework**: Arduino/ESP-IDF
- **IDE**: PlatformIO
- **Configuración**: `firmware/platformio.ini`
- **Código fuente**: `firmware/src/main.cpp`

### Aplicación Flutter
- **Estructura**: Pendiente de implementación
- **Conexión**: HTTP REST API (puerto 8000)
- **Funcionalidades**:
  - Visualización de datos en tiempo real
  - Gráficos históricos
  - Control remoto de dispositivos
  - Configuración de alertas

## Solución de Problemas

### Problemas Comunes

1. **InfluxDB no inicia**
   - Verificar que la contraseña tenga al menos 8 caracteres
   - Revisar logs: `docker-compose logs influxdb`

2. **Telegraf no se conecta a MQTT**
   - Verificar credenciales en variables de entorno
   - Comprobar configuración de Mosquitto

3. **Datos no aparecen en Grafana**
   - Verificar conexión a InfluxDB
   - Revisar configuración de datasource
   - Comprobar que Telegraf esté enviando datos

### Comandos de Diagnóstico

```bash
# Reiniciar servicios específicos
docker-compose restart telegraf
docker-compose restart mosquitto

# Limpiar volúmenes y reiniciar
docker-compose down -v
docker-compose up -d

# Verificar conectividad MQTT
mosquitto_sub -h localhost -p 1883 -u admin -P admin12345 -t "microgrid/+/telemetry"
```

## Próximos Pasos

1. **Desarrollo del firmware ESP32**
   - Implementar lectura de sensores reales
   - Configuración WiFi via web portal
   - OTA (Over-The-Air) updates

2. **Aplicación Flutter**
   - Diseño de UI/UX
   - Implementación de gráficos en tiempo real
   - Sistema de notificaciones push

3. **Mejoras del Sistema**
   - Implementar SSL/TLS para MQTT
   - Añadir sistema de alertas
   - Backup automático de datos
   - Escalabilidad para múltiples dispositivos

## Estructura del Proyecto

```
Esp-App/
├── api/                    # FastAPI REST API
├── docs/                   # Documentación
│   ├── architecture-diagram.svg
│   └── README.md
├── firmware/               # Código ESP32
│   ├── platformio.ini
│   └── src/
│       └── main.cpp
├── infra/                  # Infraestructura Docker
│   ├── docker-compose.yml
│   ├── .env
│   ├── grafana/
│   ├── mosquitto/
│   └── telegraf/
└── tools/                  # Herramientas de desarrollo
    └── simulate_device.py
```

## Licencia

[Especificar licencia del proyecto]

## Contribuciones

[Instrucciones para contribuir al proyecto]

## Contacto

- **Desarrollador**: Michael Hernandez
- **GitHub**: [@Michael-Hernandezz](https://github.com/Michael-Hernandezz)
- **Proyecto**: [Esp-App](https://github.com/Michael-Hernandezz/Esp-App)