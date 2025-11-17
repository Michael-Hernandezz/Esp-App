#!/usr/bin/env python3
"""
Script para probar la API de microgrid directamente
"""
import requests
import json
import time

API_BASE = "http://localhost:8000"

def test_api_health():
    print("🏥 Probando endpoint de salud...")
    try:
        response = requests.get(f"{API_BASE}/health", timeout=5)
        print(f"✅ Salud: {response.status_code} - {response.json()}")
        return True
    except Exception as e:
        print(f"❌ Error en salud: {e}")
        return False

def test_telemetry():
    print("📊 Probando endpoint de telemetría...")
    try:
        params = {
            "device_id": "test-device",
            "fields": "v_bat_conv,soc_percent,chg_enable",
            "start": "-15m"
        }
        response = requests.get(f"{API_BASE}/telemetry/multi", params=params, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Telemetría obtenida:")
            print(f"   Device: {data['device_id']}")
            print(f"   Series disponibles: {list(data['series'].keys())}")
            for field, points in data['series'].items():
                if points:
                    latest = points[-1]
                    print(f"   {field}: {latest['value']} (at {latest['time']})")
                else:
                    print(f"   {field}: No data")
        else:
            print(f"❌ Error {response.status_code}: {response.text}")
            
    except Exception as e:
        print(f"❌ Error en telemetría: {e}")

def test_actuator_control():
    print("🎛️  Probando control de actuadores...")
    try:
        payload = {
            "device_id": "test-device",
            "chg_enable": 1,
            "dsg_enable": 0,
            "cp_enable": 1
        }
        response = requests.post(f"{API_BASE}/actuators/control", json=payload, timeout=5)
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Comando enviado: {result['payload']}")
        else:
            print(f"❌ Error {response.status_code}: {response.text}")
            
    except Exception as e:
        print(f"❌ Error en control: {e}")

def test_actuator_status():
    print("📟 Probando estado de actuadores...")
    try:
        response = requests.get(f"{API_BASE}/actuators/status/test-device", timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Estado de actuadores:")
            for actuator, value in data['actuators'].items():
                status = "ON" if value == 1 else "OFF"
                print(f"   {actuator}: {status}")
        else:
            print(f"❌ Error {response.status_code}: {response.text}")
            
    except Exception as e:
        print(f"❌ Error en estado: {e}")

def main():
    print("🚀 Iniciando pruebas de la API...")
    
    if not test_api_health():
        print("❌ La API no responde. Verifica que el contenedor esté corriendo.")
        return
    
    print("\n" + "="*50)
    test_telemetry()
    
    print("\n" + "="*50)
    test_actuator_control()
    
    # Esperar un poco para que el comando se procese
    print("⏳ Esperando 3 segundos...")
    time.sleep(3)
    
    print("\n" + "="*50)
    test_actuator_status()

if __name__ == "__main__":
    main()