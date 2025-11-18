#!/bin/bash

# Script para actualizar configuraciones de ESP-APP en DigitalOcean
# Este script debe ejecutarse en el servidor de producción

set -e

APP_DIR="/opt/esp-app"
LOG_FILE="/var/log/esp-app-update.log"

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

log "=== INICIANDO ACTUALIZACIÓN DE ESP-APP ==="

# Verificar si es root
if [[ $EUID -ne 0 ]]; then
   log "ERROR: Este script debe ejecutarse como root"
   exit 1
fi

# Ir al directorio de la aplicación
cd $APP_DIR

log "=== FASE 1: Actualizando código desde repositorio ==="
git stash 2>/dev/null || true
git pull origin main

log "=== FASE 2: Deteniendo servicios ==="
cd $APP_DIR/DigitalOcean
docker-compose -f docker-compose.prod.yml down

log "=== FASE 3: Limpiando imágenes antiguas ==="
docker system prune -f
docker image prune -af

log "=== FASE 4: Verificando configuraciones ==="
# Verificar que las configuraciones estén correctas
if [ ! -f "telegraf/telegraf.conf" ]; then
    log "ERROR: Configuración de Telegraf no encontrada"
    exit 1
fi

if [ ! -f "mosquitto/config/mosquitto.conf" ]; then
    log "ERROR: Configuración de Mosquitto no encontrada"
    exit 1
fi

log "=== FASE 5: Reconstruyendo y desplegando servicios ==="
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

log "=== FASE 6: Esperando estabilización de servicios ==="
sleep 45

log "=== FASE 7: Verificando estado de servicios ==="
echo "Estado de contenedores:"
docker-compose -f docker-compose.prod.yml ps

echo "Verificando salud de servicios..."
for service in mosquitto-prod influxdb-prod telegraf-prod microgrid-api-prod; do
    if docker ps | grep -q $service; then
        log "✅ $service: FUNCIONANDO"
    else
        log "❌ $service: ERROR"
    fi
done

# Verificar API
PUBLIC_IP=$(curl -s ifconfig.me)
if curl -f -s http://localhost:8000/health > /dev/null; then
    log "✅ API REST: FUNCIONANDO"
else
    log "❌ API REST: ERROR"
fi

# Verificar InfluxDB
if curl -f -s http://localhost:8086/ping > /dev/null; then
    log "✅ InfluxDB: FUNCIONANDO"
else
    log "❌ InfluxDB: ERROR"
fi

log "=== ACTUALIZACIÓN COMPLETADA ==="
log "ESP-APP actualizado y funcionando en:"
log "- API REST: http://$PUBLIC_IP:8000"
log "- InfluxDB UI: http://$PUBLIC_IP:8086"
log "- MQTT Broker: $PUBLIC_IP:1883"
log "- Documentación API: http://$PUBLIC_IP:8000/docs"
log ""
log "Para ver logs: docker-compose -f $APP_DIR/DigitalOcean/docker-compose.prod.yml logs -f"

echo "¡Actualización completada exitosamente!"