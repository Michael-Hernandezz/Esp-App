# Esp-App

Sistema IoT de monitoreo y control de un **Sistema de Gestión de Baterías (BMS)** desarrollado como proyecto de la materia de Móviles. Integra hardware ESP32, una API REST, una aplicación móvil Flutter y una infraestructura cloud completa al estilo **IIoT (Industrial Internet of Things)**.

## ¿Para qué sirve?

Esp-App permite **monitorear en tiempo real** y **controlar de forma remota** dispositivos ESP32 que recolectan métricas de energía (voltaje, corriente, estado de carga/salud de batería). El flujo de datos es:

```
ESP32 (sensores)
      │  MQTT
      ▼
Mosquitto (broker MQTT)
      │  suscripción
      ▼
Telegraf  ──▶  InfluxDB (base de datos de series de tiempo)
                    │
              API FastAPI  ◀──  App Flutter (móvil)
              (REST/MQTT)         (visualización y control)
```

### Componentes principales

| Directorio | Tecnología | Descripción |
|------------|-----------|-------------|
| `firmware/` | C++ / Arduino / PlatformIO | Firmware para ESP32: conecta por WiFi, publica telemetría por MQTT y recibe comandos |
| `api/` | Python 3.11 / FastAPI | API REST que consulta InfluxDB y envía comandos MQTT a los dispositivos |
| `iot/` | Dart / Flutter | App móvil multiplataforma (iOS, Android, Web) con dashboard, gráficas, automatizaciones y notificaciones |
| `infra/` | Docker Compose | Stack local: Mosquitto, InfluxDB 2.7, Telegraf y la API |
| `DigitalOcean/` | Bash / Docker | Scripts de despliegue automatizado en producción (DigitalOcean) |
| `tools/` | Python | Scripts para simular dispositivos y probar la conexión MQTT/API/InfluxDB |

### Campos de telemetría monitoreados

- Voltaje de batería, voltaje de salida, voltaje de 3 celdas individuales
- Corriente del circuito
- SOC % (State of Charge) y SOH % (State of Health)
- Estado de actuadores: cargador, descargador, protector de celdas, monitor de potencia

### Endpoints principales de la API (puerto 8000)

| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/health` | Estado del servicio |
| `GET` | `/telemetry` | Consulta un campo de telemetría |
| `GET` | `/telemetry/multi` | Consulta múltiples campos |
| `POST` | `/commands/send` | Envía un comando MQTT al dispositivo |
| `POST` | `/actuators/control` | Controla un actuador (cargador, descargador, etc.) |
| `GET` | `/actuators/status/{device_id}` | Estado actual de los actuadores |

## Inicio rápido (desarrollo local)

```bash
# 1. Levantar la infraestructura
cd infra
docker compose up -d

# 2. Simular un dispositivo ESP32
cd tools
pip install -r requirements.txt
python simulate_device.py

# 3. Ejecutar la app Flutter
cd iot
flutter pub get
flutter run
```

## Reglas de Colaboración

**Flujo**: GitHub Flow
- Ramas de feature: `feat/<nombre>`, fixes `fix/<issue>`, chores `chore/<tarea>`
- Se crea un PR desde la rama de feature hacia `main`
- PR requiere: CI en verde + mínimo 1 aprobación

**Commits**
- Usar Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`

**Pull Requests**
- Incluir resumen, cómo probar, tests añadidos y checklist aplicado.
- Etiquetar reviewers con @usuario o usar CODEOWNERS.

**Protecciones**
- `main` protegida; no push directo; merge por PR.
