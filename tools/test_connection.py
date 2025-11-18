#!/usr/bin/env python3
"""
Script para probar la conexion con el servidor ESP-APP en la nube
"""
import requests
import json
import time

# Configuracion del servidor en la nube
SERVER_IP = "104.131.178.99"
API_BASE = f"http://{SERVER_IP}:8000"

def test_api_connection():
    """Probar conexion con la API"""
    print("🔍 Probando conexion con la API...")
    try:
        response = requests.get(f"{API_BASE}/health", timeout=10)
        if response.status_code == 200:
            print("✅ API funcionando correctamente")
            return True
        else:
            print(f"❌ API error: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error conectando con API: {e}")
        return False

def test_actuator_status():
    """Probar endpoint de actuadores"""
    print("🔍 Probando endpoint de actuadores...")
    try:
        response = requests.get(f"{API_BASE}/actuators/status/dev-001", timeout=10)
        print(f"Status actuadores: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Actuadores: {data}")
        else:
            print(f"⚠️  Actuadores: {response.text}")
    except Exception as e:
        print(f"❌ Error: {e}")

def test_telemetry():
    """Probar endpoint de telemetria"""
    print("🔍 Probando endpoint de telemetria...")
    try:
        response = requests.get(f"{API_BASE}/telemetry/dev-001", timeout=10)
        print(f"Status telemetria: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Telemetria: {len(data)} registros")
        else:
            print(f"⚠️  Telemetria: {response.text}")
    except Exception as e:
        print(f"❌ Error: {e}")

def test_influxdb():
    """Probar conexion con InfluxDB"""
    print("🔍 Probando conexion con InfluxDB...")
    try:
        response = requests.get(f"http://{SERVER_IP}:8086/health", timeout=10)
        if response.status_code == 200:
            print("✅ InfluxDB funcionando correctamente")
        else:
            print(f"❌ InfluxDB error: {response.status_code}")
    except Exception as e:
        print(f"❌ Error conectando con InfluxDB: {e}")

def main():
    print("🚀 Probando servidor ESP-APP en la nube")
    print(f"📡 Servidor: {SERVER_IP}")
    print("-" * 50)
    
    # Probar servicios
    api_ok = test_api_connection()
    test_influxdb()
    
    if api_ok:
        test_actuator_status()
        test_telemetry()
    
    print("-" * 50)
    print("🎯 URLs de acceso:")
    print(f"   API: {API_BASE}")
    print(f"   Docs: {API_BASE}/docs")
    print(f"   InfluxDB: http://{SERVER_IP}:8086")
    print(f"   MQTT: {SERVER_IP}:1883")

if __name__ == "__main__":
    main()