import os, json
from fastapi import FastAPI
from pydantic import BaseModel
import aiomqtt

MQTT_HOST = os.getenv("MQTT_HOST", "mosquitto")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_USER = os.getenv("MQTT_USER", "admin")
MQTT_PASS = os.getenv("MQTT_PASS", "admin")
MQTT_BASE = os.getenv("MQTT_BASE", "microgrid")

app = FastAPI(title="Microgrid API")

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