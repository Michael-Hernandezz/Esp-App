#!/bin/bash

# Script de monitoreo para ESP-APP
# Ejecutar con: ./monitor.sh [status|logs|restart|update]

APP_DIR="/opt/esp-app/DigitalOcean"
COMPOSE_FILE="docker-compose.prod.yml"

cd $APP_DIR

case $1 in
    "status")
        echo "=== Estado de los servicios ==="
        docker-compose -f $COMPOSE_FILE ps
        echo ""
        echo "=== Uso de recursos ==="
        docker stats --no-stream
        ;;
    "logs")
        if [ -n "$2" ]; then
            docker-compose -f $COMPOSE_FILE logs -f $2
        else
            docker-compose -f $COMPOSE_FILE logs -f
        fi
        ;;
    "restart")
        echo "Reiniciando servicios..."
        docker-compose -f $COMPOSE_FILE restart
        echo "Servicios reiniciados"
        ;;
    "update")
        echo "Actualizando aplicacion..."
        git pull origin main
        docker-compose -f $COMPOSE_FILE down
        docker-compose -f $COMPOSE_FILE build --no-cache
        docker-compose -f $COMPOSE_FILE up -d
        echo "Aplicacion actualizada"
        ;;
    "health")
        echo "=== Verificacion de salud ==="
        curl -s http://localhost:8000/health && echo " - API: OK" || echo " - API: ERROR"
        curl -s http://localhost:8086/ping && echo " - InfluxDB: OK" || echo " - InfluxDB: ERROR"
        docker exec mosquitto-prod mosquitto_pub -h localhost -t test -m test && echo " - MQTT: OK" || echo " - MQTT: ERROR"
        ;;
    *)
        echo "Uso: $0 [status|logs|restart|update|health]"
        echo ""
        echo "Comandos disponibles:"
        echo "  status  - Mostrar estado de servicios y recursos"
        echo "  logs    - Mostrar logs (opcional: especificar servicio)"
        echo "  restart - Reiniciar todos los servicios"
        echo "  update  - Actualizar aplicacion desde Git"
        echo "  health  - Verificar salud de los servicios"
        echo ""
        echo "Ejemplos:"
        echo "  $0 status"
        echo "  $0 logs microgrid-api-prod"
        echo "  $0 health"
        ;;
esac