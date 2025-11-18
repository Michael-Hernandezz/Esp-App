#!/bin/bash

# Script para actualizar configuraciones de ESP-APP
# Uso: ./update-config.sh [ip|token|passwords]

APP_DIR="/opt/esp-app/DigitalOcean"
REPO_DIR="/opt/esp-app"

cd $APP_DIR

case $1 in
    "ip")
        if [ -z "$2" ]; then
            PUBLIC_IP=$(curl -s ifconfig.me)
            echo "IP publica detectada: $PUBLIC_IP"
        else
            PUBLIC_IP=$2
            echo "Usando IP proporcionada: $PUBLIC_IP"
        fi
        
        echo "Configurando IP publica en archivos..."
        
        # Actualizar README con la IP
        sed -i "s/YOUR_DROPLET_IP/$PUBLIC_IP/g" README.md
        
        echo "IP actualizada a: $PUBLIC_IP"
        echo "URLs de acceso:"
        echo "- API: http://$PUBLIC_IP:8000"
        echo "- InfluxDB: http://$PUBLIC_IP:8086"
        echo "- MQTT: $PUBLIC_IP:1883"
        ;;
        
    "token")
        if [ -z "$2" ]; then
            echo "Error: Debe proporcionar un nuevo token"
            echo "Uso: $0 token NUEVO_TOKEN"
            exit 1
        fi
        
        NEW_TOKEN=$2
        echo "Actualizando token de InfluxDB..."
        
        # Actualizar docker-compose
        sed -i "s/DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=.*/DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=$NEW_TOKEN/" docker-compose.prod.yml
        sed -i "s/INFLUXDB_TOKEN=.*/INFLUXDB_TOKEN=$NEW_TOKEN/" docker-compose.prod.yml
        
        # Actualizar .env si existe
        if [ -f ".env" ]; then
            sed -i "s/INFLUXDB_TOKEN=.*/INFLUXDB_TOKEN=$NEW_TOKEN/" .env
        fi
        
        echo "Token actualizado. Reiniciando servicios..."
        docker-compose -f docker-compose.prod.yml restart
        ;;
        
    "passwords")
        echo "Generando nuevas contraseñas seguras..."
        
        # Generar contraseñas aleatorias
        INFLUX_PASS=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
        SECRET_KEY=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-50)
        
        echo "Nueva contraseña InfluxDB: $INFLUX_PASS"
        echo "Nueva secret key: $SECRET_KEY"
        
        # Actualizar docker-compose
        sed -i "s/DOCKER_INFLUXDB_INIT_PASSWORD=.*/DOCKER_INFLUXDB_INIT_PASSWORD=$INFLUX_PASS/" docker-compose.prod.yml
        
        # Crear/actualizar .env
        if [ ! -f ".env" ]; then
            cp .env.example .env
        fi
        sed -i "s/INFLUXDB_PASSWORD=.*/INFLUXDB_PASSWORD=$INFLUX_PASS/" .env
        sed -i "s/SECRET_KEY=.*/SECRET_KEY=$SECRET_KEY/" .env
        
        echo "Contraseñas actualizadas. IMPORTANTE: Guarda estas credenciales en un lugar seguro."
        echo "Reiniciando servicios..."
        docker-compose -f docker-compose.prod.yml down
        docker-compose -f docker-compose.prod.yml up -d
        ;;
        
    "ssl")
        echo "Configuracion SSL/TLS (requiere certificados)"
        echo "Esta funcionalidad estara disponible en version futura"
        ;;
        
    *)
        echo "Uso: $0 [ip|token|passwords|ssl]"
        echo ""
        echo "Comandos disponibles:"
        echo "  ip [IP]        - Actualizar IP publica (detecta automaticamente si no se proporciona)"
        echo "  token TOKEN    - Actualizar token de InfluxDB"
        echo "  passwords      - Generar nuevas contraseñas seguras"
        echo "  ssl            - Configure SSL certificates (futuro)"
        echo ""
        echo "Ejemplos:"
        echo "  $0 ip                          # Detectar y configurar IP automaticamente"
        echo "  $0 ip 192.168.1.100           # Usar IP especifica"
        echo "  $0 token mi-nuevo-token-123   # Cambiar token InfluxDB"
        echo "  $0 passwords                   # Generar contraseñas seguras"
        ;;
esac