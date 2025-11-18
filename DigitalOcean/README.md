# ESP-APP - Despliegue en DigitalOcean

Esta carpeta contiene todos los archivos necesarios para desplegar ESP-APP en DigitalOcean de forma automatica y segura.

## Estructura de Archivos

```
DigitalOcean/
├── docker-compose.prod.yml  # Configuracion Docker para produccion
├── deploy.sh               # Script de despliegue automatico
├── monitor.sh              # Script de monitoreo
├── backup.sh               # Script de respaldo
├── update-config.sh        # Actualizacion de configuraciones
├── .env.example           # Ejemplo de variables de entorno
└── README.md              # Esta documentacion
```

## Requisitos Previos

1. **Cuenta de DigitalOcean** con credito estudiantil activado
2. **Droplet Ubuntu 22.04** (minimo 1GB RAM, recomendado 2GB)
3. **SSH Key** configurada en DigitalOcean
4. **Repositorio** subido a GitHub

## Proceso de Despliegue

### Paso 1: Crear Droplet

1. En DigitalOcean Dashboard:
   - Create > Droplets
   - Ubuntu 22.04 LTS
   - Plan: Regular Intel $6/month (o $12 para mejor rendimiento)
   - Datacenter: New York (mas cercano)
   - Authentication: SSH Key
   - Hostname: esp-app-server

### Paso 2: Conectar via SSH

```bash
ssh root@YOUR_DROPLET_IP
```

### Paso 3: Despliegue Automatico

```bash
# Descargar y ejecutar script de despliegue
curl -sSL https://raw.githubusercontent.com/Michael-Hernandezz/Esp-App/main/DigitalOcean/deploy.sh | bash
```

### Paso 4: Verificar Despliegue

```bash
# Ir al directorio de la aplicacion
cd /opt/esp-app/DigitalOcean

# Verificar estado de servicios
./monitor.sh status

# Ver logs en tiempo real
./monitor.sh logs
```

## URLs de Acceso

Una vez desplegado, tus servicios estaran disponibles en:

- **API REST**: `http://YOUR_DROPLET_IP:8000`
- **Documentacion API**: `http://YOUR_DROPLET_IP:8000/docs`
- **InfluxDB UI**: `http://YOUR_DROPLET_IP:8086`
- **MQTT Broker**: `YOUR_DROPLET_IP:1883`

## Credenciales por Defecto

### InfluxDB
- **URL**: `http://YOUR_DROPLET_IP:8086`
- **Usuario**: `admin`
- **Password**: `microgrid123`
- **Organizacion**: `microgrid`
- **Bucket**: `telemetry`
- **Token**: `m9dZ53tgCda7obiBCJn4xFVloD8q9zbqckGPvMzlPxJ3Jwb2ur6gGp-sgWD-KjHH5tvJIqgCSvpuVKeOHj66rw==`

### MQTT Broker
- **Host**: `YOUR_DROPLET_IP`
- **Puerto**: `1883`
- **Usuario**: Sin autenticacion (configurable)
- **Password**: Sin autenticacion (configurable)

## Comandos de Administracion

### Monitoreo
```bash
# Estado general
./monitor.sh status

# Logs de todos los servicios
./monitor.sh logs

# Logs de un servicio especifico
./monitor.sh logs microgrid-api-prod

# Verificar salud de servicios
./monitor.sh health
```

### Actualizaciones
```bash
# Actualizar aplicacion desde GitHub
./monitor.sh update

# Reiniciar servicios
./monitor.sh restart
```

### Respaldos
```bash
# Crear backup
./backup.sh

# Ver backups disponibles
ls -la /opt/backups/esp-app/
```

## Configuracion de la App Flutter

Una vez desplegado, actualiza tu app Flutter con la IP del droplet:

```dart
// En lib/core/app/app_config.dart
class AppConfig {
  static const String baseUrl = 'http://YOUR_DROPLET_IP:8000';
  static const String influxDBUrl = 'http://YOUR_DROPLET_IP:8086';
  static const String mqttBroker = 'YOUR_DROPLET_IP';
  static const int mqttPort = 1883;
}
```

## Configuracion del ESP32

```cpp
// En firmware/src/main.cpp
const char* mqtt_server = "YOUR_DROPLET_IP";
const int mqtt_port = 1883;
```

## Solución de Problemas

### Servicios no inician
```bash
# Ver logs detallados
docker-compose -f docker-compose.prod.yml logs

# Reiniciar servicios
docker-compose -f docker-compose.prod.yml restart

# Reconstruir contenedores
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build
```

### Problemas de conectividad
```bash
# Verificar firewall
sudo ufw status

# Verificar puertos abiertos
ss -tulpn | grep -E ':8000|:8086|:1883'

# Probar conectividad local
curl http://localhost:8000/health
```

### Falta de espacio en disco
```bash
# Limpiar contenedores huerfanos
docker system prune -a

# Ver uso de espacio
df -h
du -sh /var/lib/docker
```

## Seguridad

### Configuraciones aplicadas automaticamente:
- Firewall UFW configurado
- Fail2Ban para proteccion SSH
- Contenedores con healthchecks
- Logs centralizados
- Backups automaticos

### Recomendaciones adicionales:
1. Cambiar passwords por defecto
2. Configurar SSL/TLS certificates
3. Implementar autenticacion MQTT
4. Configurar monitoring externo

## Costos Estimados

- **Droplet $6/mes**: 33+ meses con credito estudiantil
- **Droplet $12/mes**: 16+ meses con credito estudiantil
- **Backup storage**: $0.10/GB/mes (opcional)
- **Load Balancer**: $12/mes (solo si necesitas alta disponibilidad)

## Soporte

Para problemas o preguntas:
1. Revisar logs con `./monitor.sh logs`
2. Verificar estado con `./monitor.sh status`
3. Consultar documentacion de la API en `/docs`
4. Revisar issues en GitHub

## Actualizaciones Futuras

Para actualizar la aplicacion:
```bash
# Metodo automatico
./monitor.sh update

# Metodo manual
git pull origin main
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build
```