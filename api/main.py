import os, json
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import aiomqtt

# MQTT
MQTT_HOST = os.getenv("MQTT_HOST", "mosquitto")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_USER = os.getenv("MQTT_USER", "admin")
MQTT_PASS = os.getenv("MQTT_PASS", "admin")
MQTT_BASE = os.getenv("MQTT_BASE", "microgrid")

# Influx
INFLUX_URL = os.getenv("INFLUX_URL", "http://influxdb:8086")
INFLUX_TOKEN = os.getenv("INFLUX_TOKEN", "")
INFLUX_ORG = os.getenv("INFLUX_ORG", "microgrid")
INFLUX_BUCKET = os.getenv("INFLUX_BUCKET", "telemetry")

from influxdb_client import InfluxDBClient

app = FastAPI(title="Microgrid API")

# CORS para desarrollo; restringe origins en producción
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class CommandIn(BaseModel):
    device_id: str
    payload: dict
    retain: bool = False

@app.get("/health")
async def health():
    return {"ok": True}

@app.post("/commands/send")
async def send_command(cmd: CommandIn):
    topic = f"{MQTT_BASE}/{cmd.device_id}/cmd"
    payload = json.dumps(cmd.payload).encode()
    async with aiomqtt.Client(MQTT_HOST, port=MQTT_PORT, username=MQTT_USER, password=MQTT_PASS) as client:
        await client.publish(topic, payload, qos=1, retain=cmd.retain)
    return {"published": True, "topic": topic}

def _query_influx(flux: str):
    if not INFLUX_TOKEN:
        raise HTTPException(500, "INFLUX_TOKEN no configurado")
    try:
        with InfluxDBClient(url=INFLUX_URL, token=INFLUX_TOKEN, org=INFLUX_ORG, timeout=30_000) as client:
            return client.query_api().query(org=INFLUX_ORG, query=flux)
    except Exception as e:
        raise HTTPException(500, f"Error consultando Influx: {e}")

@app.get("/telemetry")
def get_telemetry(
    device_id: str = Query(..., description="dev-001"),
    field: str = Query(..., pattern="^(v_bat_conv|v_out_conv|v_cell1|v_cell2|v_cell3|i_circuit|soc_percent|soh_percent|alert|chg_enable|dsg_enable|cp_enable|pmon_enable)$", 
                        description="v_bat_conv|v_out_conv|v_cell1|v_cell2|v_cell3|i_circuit|soc_percent|soh_percent|alert|chg_enable|dsg_enable|cp_enable|pmon_enable"),
    start: str = Query("-15m", description="p.ej. -15m, -2h, 2025-01-01T00:00:00Z"),
    stop: str = Query("now()", description="p.ej. now() o ISO"),
    bucket: str | None = Query(None, description="por defecto INFLUX_BUCKET"),
    window: str | None = Query(None, description="aggregateWindow: 1m,5m, etc."),
    agg: str | None = Query("mean", description="mean,sum,max,min"),
):
    use_bucket = bucket or INFLUX_BUCKET
    flux = f'''
from(bucket: "{use_bucket}")
  |> range(start: {start}, stop: {stop})
  |> filter(fn: (r) => r._measurement == "telemetry" and r._field == "{field}" and r.device_id == "{device_id}")
'''
    if window:
        flux += f'  |> aggregateWindow(every: {window}, fn: {agg or "mean"}, createEmpty: false)\n'
    flux += '  |> keep(columns: ["_time","_value"])\n'

    tables = _query_influx(flux)
    points = []
    for table in tables:
        for rec in table.records:
            t = rec.get_time()
            v = rec.get_value()
            points.append({"time": t.isoformat(), "epochMs": int(t.timestamp()*1000), "value": float(v)})

    return {"device_id": device_id, "field": field, "bucket": use_bucket, "start": start, "stop": stop, "points": points}

@app.get("/telemetry/multi")
def get_telemetry_multi(
    device_id: str = Query(...),
    fields: str = Query("v_bat_conv,v_out_conv,v_cell1,v_cell2,v_cell3,i_circuit,soc_percent,soh_percent,alert,chg_enable,dsg_enable,cp_enable,pmon_enable", 
                       description="coma-separado: v_bat_conv,v_out_conv,v_cell1,v_cell2,v_cell3,i_circuit,soc_percent,soh_percent,alert,chg_enable,dsg_enable,cp_enable,pmon_enable"),
    start: str = Query("-15m"),
    stop: str = Query("now()"),
    bucket: str | None = Query(None),
    window: str | None = Query(None),
    agg: str | None = Query("mean"),
):
    use_bucket = bucket or INFLUX_BUCKET
    wanted = [f.strip() for f in fields.split(",") if f.strip()]

    # Formatear la lista para Flux
    wanted_set = '[' + ', '.join([f'"{w}"' for w in wanted]) + ']'
    
    flux = f'''
data = from(bucket: "{use_bucket}")
  |> range(start: {start}, stop: {stop})
  |> filter(fn: (r) => r._measurement == "telemetry" and r.device_id == "{device_id}")
  |> filter(fn: (r) => contains(value: r._field, set: {wanted_set}))
'''
    if window:
        flux += f'  |> aggregateWindow(every: {window}, fn: {agg or "mean"}, createEmpty: false)\n'
    flux += '  |> keep(columns: ["_time","_value","_field"])\n'
    flux += 'data'

    tables = _query_influx(flux)
    series: dict[str, list] = {k: [] for k in wanted}
    for table in tables:
        for rec in table.records:
            field = rec.values.get("_field")
            t = rec.get_time()
            v = rec.get_value()
            if field in series:
                series[field].append({"time": t.isoformat(), "epochMs": int(t.timestamp()*1000), "value": float(v)})

    return {"device_id": device_id, "bucket": use_bucket, "start": start, "stop": stop, "series": series}

# ========== CONTROL DE ACTUADORES ==========

class ActuatorCommand(BaseModel):
    device_id: str
    chg_enable: int | None = None    # 0 o 1
    dsg_enable: int | None = None    # 0 o 1  
    cp_enable: int | None = None     # 0 o 1
    pmon_enable: int | None = None   # 0 o 1

@app.post("/actuators/control")
async def control_actuators(cmd: ActuatorCommand):
    """Controla los actuadores del sistema BMS"""
    topic = f"{MQTT_BASE}/{cmd.device_id}/cmd"
    
    # Solo envía campos que no sean None
    payload = {}
    if cmd.chg_enable is not None:
        payload["chg_enable"] = cmd.chg_enable
    if cmd.dsg_enable is not None:
        payload["dsg_enable"] = cmd.dsg_enable
    if cmd.cp_enable is not None:
        payload["cp_enable"] = cmd.cp_enable
    if cmd.pmon_enable is not None:
        payload["pmon_enable"] = cmd.pmon_enable
    
    if not payload:
        raise HTTPException(400, "Al menos un actuador debe especificarse")
    
    async with aiomqtt.Client(MQTT_HOST, port=MQTT_PORT, username=MQTT_USER, password=MQTT_PASS) as client:
        await client.publish(topic, json.dumps(payload).encode(), qos=1, retain=False)
    
    return {"published": True, "topic": topic, "payload": payload}

@app.get("/actuators/status/{device_id}")
def get_actuator_status(device_id: str):
    """Obtiene el estado actual de todos los actuadores"""
    try:
        flux = f'''
from(bucket: "{INFLUX_BUCKET}")
  |> range(start: -5m)
  |> filter(fn: (r) => r._measurement == "telemetry" and r.device_id == "{device_id}")
  |> filter(fn: (r) => contains(value: r._field, set: ["chg_enable", "dsg_enable", "cp_enable", "pmon_enable"]))
  |> last()
  |> keep(columns: ["_time","_value","_field"])
'''
        tables = _query_influx(flux)
        status = {}
        for table in tables:
            for rec in table.records:
                field = rec.values.get("_field")
                value = int(rec.get_value())
                status[field] = value
        
        return {"device_id": device_id, "actuators": status}
    except Exception as e:
        raise HTTPException(500, f"Error obteniendo estado de actuadores: {e}")