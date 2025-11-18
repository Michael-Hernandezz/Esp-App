#!/usr/bin/env python3
"""
Script para verificar si Telegraf está pasando datos a InfluxDB
"""
from influxdb_client import InfluxDBClient
import os

# Configuración de InfluxDB desde .env
INFLUX_URL = "http://localhost:8086"
INFLUX_TOKEN = "m9dZ53tgCda7obiBCJn4xFVloD8q9zbqckGPvMzlPxJ3Jwb2ur6gGp-sgWD-KjHH5tvJIqgCSvpuVKeOHj66rw=="
INFLUX_ORG = "microgrid"
INFLUX_BUCKET = "telemetry"

def test_influxdb_connection():
    print("🔍 Probando conexión a InfluxDB...")
    
    try:
        with InfluxDBClient(url=INFLUX_URL, token=INFLUX_TOKEN, org=INFLUX_ORG, timeout=10_000) as client:
            # Verificar salud del servidor
            health = client.health()
            print(f"✅ InfluxDB está saludable: {health.status}")
            
            # Consultar datos recientes de dev-001
            query = f'''
from(bucket: "{INFLUX_BUCKET}")
  |> range(start: -5m)
  |> filter(fn: (r) => r._measurement == "telemetry")
  |> filter(fn: (r) => r.device_id == "dev-001")
  |> limit(n: 10)
'''
            
            print("📊 Consultando datos recientes de dev-001...")
            tables = client.query_api().query(org=INFLUX_ORG, query=query)
            
            data_found = False
            for table in tables:
                for record in table.records:
                    data_found = True
                    field = record.values.get("_field")
                    value = record.get_value()
                    timestamp = record.get_time()
                    device_id = record.values.get("device_id")
                    
                    print(f"📈 {device_id}: {field} = {value} (at {timestamp})")
            
            if not data_found:
                print("⚠️  No se encontraron datos recientes. Esto puede indicar que:")
                print("   - Telegraf no está funcionando correctamente")
                print("   - Los datos MQTT no llegaron a Telegraf")
                print("   - Hay un problema en la configuración")
                
                # Verificar si hay algún dato en el bucket
                print("\n🔍 Verificando si hay ALGÚN dato en el bucket...")
                general_query = f'''
from(bucket: "{INFLUX_BUCKET}")
  |> range(start: -24h)
  |> limit(n: 10)
'''
                tables = client.query_api().query(org=INFLUX_ORG, query=general_query)
                
                general_data = False
                for table in tables:
                    for record in table.records:
                        general_data = True
                        print(f"🔸 Measurement: {record.values.get('_measurement')}, Field: {record.values.get('_field')}, Device: {record.values.get('device_id')}")
                
                if not general_data:
                    print("❌ El bucket está completamente vacío")
            else:
                print("✅ ¡Telegraf está funcionando! Los datos MQTT llegaron a InfluxDB")
                
    except Exception as e:
        print(f"❌ Error conectando a InfluxDB: {e}")

if __name__ == "__main__":
    test_influxdb_connection()