#!/bin/bash

# Script de backup para ESP-APP
# Crea respaldos de datos criticos

APP_DIR="/opt/esp-app/DigitalOcean"
BACKUP_DIR="/opt/backups/esp-app"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="esp-app-backup-$DATE"

# Crear directorio de backups
mkdir -p $BACKUP_DIR

echo "Iniciando backup: $BACKUP_NAME"

cd $APP_DIR

# Crear directorio para este backup
mkdir -p $BACKUP_DIR/$BACKUP_NAME

# Backup de datos de InfluxDB
echo "Respaldando datos de InfluxDB..."
docker exec influxdb-prod influx backup /tmp/backup
docker cp influxdb-prod:/tmp/backup $BACKUP_DIR/$BACKUP_NAME/influxdb

# Backup de configuraciones
echo "Respaldando configuraciones..."
cp -r mosquitto/config $BACKUP_DIR/$BACKUP_NAME/
cp -r telegraf $BACKUP_DIR/$BACKUP_NAME/
cp docker-compose.prod.yml $BACKUP_DIR/$BACKUP_NAME/

# Backup de logs importantes
echo "Respaldando logs..."
mkdir -p $BACKUP_DIR/$BACKUP_NAME/logs
cp /var/log/esp-app-deploy.log $BACKUP_DIR/$BACKUP_NAME/logs/ 2>/dev/null || true
docker-compose logs > $BACKUP_DIR/$BACKUP_NAME/logs/docker-compose.log

# Crear archivo comprimido
echo "Comprimiendo backup..."
cd $BACKUP_DIR
tar -czf $BACKUP_NAME.tar.gz $BACKUP_NAME
rm -rf $BACKUP_NAME

# Limpiar backups antiguos (mantener solo los ultimos 7)
echo "Limpiando backups antiguos..."
ls -t esp-app-backup-*.tar.gz | tail -n +8 | xargs -r rm

echo "Backup completado: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
echo "Backups disponibles:"
ls -lh $BACKUP_DIR/esp-app-backup-*.tar.gz