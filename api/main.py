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
    field: str = Query(..., pattern="^(v|i|p|temp)$", description="v|i|p|temp"),
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
    fields: str = Query("v,i,p,temp", description="coma-separado: v,i,p,temp"),
    start: str = Query("-15m"),
    stop: str = Query("now()"),
    bucket: str | None = Query(None),
    window: str | None = Query(None),
    agg: str | None = Query("mean"),
):
    use_bucket = bucket or INFLUX_BUCKET
    wanted = [f.strip() for f in fields.split(",") if f.strip()]

    flux = f'''
data = from(bucket: "{use_bucket}")
  |> range(start: {start}, stop: {stop})
  |> filter(fn: (r) => r._measurement == "telemetry" and r.device_id == "{device_id}")
  |> filter(fn: (r) => contains(value: r._field, set: {wanted}))
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