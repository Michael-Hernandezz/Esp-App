#!/usr/bin/env python3
"""
Script de prueba para MQTT Mosquitto
"""
import json
import time
import paho.mqtt.client as mqtt

# Configuración
BROKER = "localhost"  # Docker expone el puerto 1883
PORT = 1883
USER = "admin"
PASS = "admin12345" 
BASE = "microgrid"
DEVICE_ID = "test-device"

TOPIC_TEL = f"{BASE}/{DEVICE_ID}/telemetry"
TOPIC_CMD = f"{BASE}/{DEVICE_ID}/cmd"
TOPIC_STATUS = f"{BASE}/{DEVICE_ID}/status"

def on_connect(client, userdata, flags, rc, properties=None):
    print(f"✅ Conectado a MQTT con código: {rc}")
    if rc == 0:
        print("🔹 Suscribiéndose a topics de comandos...")
        client.subscribe([(TOPIC_CMD, 1)])
        
        # Publicar estado online
        status_msg = {"online": True, "test": True, "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
        client.publish(TOPIC_STATUS, json.dumps(status_msg), qos=1, retain=True)
        print(f"📤 Estado publicado en: {TOPIC_STATUS}")
    else:
        print(f"❌ Error conectando: {rc}")

def on_disconnect(client, userdata, rc, *args):
    print(f"⚠️  Desconectado de MQTT: {rc}")

def on_message(client, userdata, msg):
    try:
        data = json.loads(msg.payload.decode())
        print(f"📨 Mensaje recibido en {msg.topic}: {data}")
    except Exception as e:
        print(f"❌ Error procesando mensaje: {e}")

def on_publish(client, userdata, mid, *args):
    print(f"📤 Mensaje publicado (mid: {mid})")

def test_mqtt():
    print("🚀 Iniciando prueba de MQTT...")
    
    # Crear cliente
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id=f"{DEVICE_ID}-test", clean_session=True)
    client.username_pw_set(USER, PASS)
    
    # Configurar callbacks
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_message = on_message
    client.on_publish = on_publish
    
    # Will message (mensaje de desconexión)
    will_msg = {"online": False, "test": True}
    client.will_set(TOPIC_STATUS, json.dumps(will_msg), qos=1, retain=True)
    
    try:
        print(f"🔌 Conectando a {BROKER}:{PORT}...")
        client.connect(BROKER, PORT, keepalive=60)
        
        # Iniciar loop en background
        client.loop_start()
        
        # Enviar algunos mensajes de telemetría de prueba
        for i in range(5):
            telemetry = {
                "v_bat_conv": 24.1 + (i * 0.1),
                "v_out_conv": 12.0,
                "v_cell1": 3.7,
                "v_cell2": 3.6,
                "v_cell3": 3.8,
                "i_circuit": 2.5,
                "soc_percent": 75.0,
                "soh_percent": 95.0,
                "alert": 0,
                "chg_enable": 1 if i % 2 == 0 else 0,
                "dsg_enable": 1,
                "cp_enable": 0,
                "pmon_enable": 1,
                "status": "ok",
                "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "test_count": i + 1
            }
            
            result = client.publish(TOPIC_TEL, json.dumps(telemetry), qos=1)
            print(f"📤 Telemetría {i+1}/5 enviada a: {TOPIC_TEL}")
            time.sleep(2)
        
        # Mantener conexión por un tiempo
        print("⏳ Manteniendo conexión por 10 segundos...")
        time.sleep(10)
        
    except Exception as e:
        print(f"❌ Error: {e}")
    finally:
        client.loop_stop()
        client.disconnect()
        print("🛑 Desconectado de MQTT")

if __name__ == "__main__":
    test_mqtt()