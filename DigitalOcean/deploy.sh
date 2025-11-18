#!/bin/bash

# Script de despliegue para ESP-APP en DigitalOcean
# Autor: ESP-APP Team
# Version: 1.0

set -e

echo "Iniciando despliegue de ESP-APP en produccion..."

# Variables de configuracion
REPO_URL="https://github.com/Michael-Hernandezz/Esp-App.git"
APP_DIR="/opt/esp-app"
LOG_FILE="/var/log/esp-app-deploy.log"

# Funcion para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Verificar si es root
if [[ $EUID -ne 0 ]]; then
   log "ERROR: Este script debe ejecutarse como root"
   exit 1
fi

log "=== FASE 1: Actualizacion del sistema ==="
apt update && apt upgrade -y
apt install -y curl git ufw fail2ban

log "=== FASE 2: Instalacion de Docker ==="
if ! command -v docker &> /dev/null; then
    log "Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $SUDO_USER 2>/dev/null || true
    rm get-docker.sh
else
    log "Docker ya esta instalado"
fi

log "=== FASE 3: Instalacion de Docker Compose ==="
if ! command -v docker-compose &> /dev/null; then
    log "Instalando Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    log "Docker Compose ya esta instalado"
fi

log "=== FASE 4: Configuracion de firewall ==="
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 8000/tcp  # API
ufw allow 1883/tcp  # MQTT
ufw allow 8086/tcp  # InfluxDB
ufw --force enable

log "=== FASE 5: Configuracion de Fail2Ban ==="
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl start fail2ban

log "=== FASE 6: Clonacion del repositorio ==="
if [ -d "$APP_DIR" ]; then
    log "Actualizando repositorio existente..."
    cd $APP_DIR
    git pull origin main
else
    log "Clonando repositorio..."
    git clone $REPO_URL $APP_DIR
    cd $APP_DIR
fi

log "=== FASE 7: Configuracion de permisos ==="
chown -R $SUDO_USER:$SUDO_USER $APP_DIR 2>/dev/null || true

log "=== FASE 8: Creacion de directorios ==="
cd $APP_DIR/DigitalOcean
mkdir -p mosquitto/config mosquitto/data mosquitto/log
mkdir -p telegraf
mkdir -p logs

# Copiar configuraciones
cp ../infra/mosquitto/mosquitto.conf mosquitto/config/
cp ../infra/telegraf/telegraf.conf telegraf/

# Ajustar permisos para mosquitto
chown -R 1883:1883 mosquitto/ 2>/dev/null || true

log "=== FASE 9: Despliegue de contenedores ==="
# Detener servicios existentes
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# Limpiar imagenes huerfanas
docker system prune -f

# Construir y desplegar
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

log "=== FASE 10: Verificacion de servicios ==="
sleep 30

# Verificar estado de contenedores
if docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
    log "Contenedores desplegados correctamente"
else
    log "ERROR: Algunos contenedores no se iniciaron correctamente"
    docker-compose -f docker-compose.prod.yml logs
    exit 1
fi

# Obtener IP publica
PUBLIC_IP=$(curl -s ifconfig.me)

log "=== DESPLIEGUE COMPLETADO ==="
log "ESP-APP esta funcionando en:"
log "- API REST: http://$PUBLIC_IP:8000"
log "- InfluxDB UI: http://$PUBLIC_IP:8086"
log "- MQTT Broker: $PUBLIC_IP:1883"
log "- Documentacion API: http://$PUBLIC_IP:8000/docs"
log ""
log "Credenciales InfluxDB:"
log "- Usuario: admin"
log "- Password: microgrid123"
log "- Token: m9dZ53tgCda7obiBCJn4xFVloD8q9zbqckGPvMzlPxJ3Jwb2ur6gGp-sgWD-KjHH5tvJIqgCSvpuVKeOHj66rw=="
log ""
log "Logs disponibles en: $LOG_FILE"
log "Para monitorear: docker-compose -f $APP_DIR/DigitalOcean/docker-compose.prod.yml logs -f"

echo "Despliegue completado exitosamente!"