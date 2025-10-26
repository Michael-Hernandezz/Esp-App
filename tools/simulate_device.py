#!/usr/bin/env python3
import json, os, time, random, threading
import paho.mqtt.client as mqtt

BROKER = os.getenv("MQTT_HOST", "localhost")
PORT = int(os.getenv("MQTT_PORT", "1883"))
USER = os.getenv("MQTT_USER", "admin")
PASS = os.getenv("MQTT_PASS", "admin12345")
BASE = os.getenv("MQTT_BASE", "microgrid")
DEVICE_ID = os.getenv("DEVICE_ID", "dev-001")
REPORT_MS = int(os.getenv("REPORT_MS", "1000"))

TOPIC_TEL = f"{BASE}/{DEVICE_ID}/telemetry"
TOPIC_CMD = f"{BASE}/{DEVICE_ID}/cmd"
TOPIC_CFG = f"{BASE}/{DEVICE_ID}/cfg"
TOPIC_STATUS = f"{BASE}/{DEVICE_ID}/status"

state = {"setpoint_v": 24.0, "setpoint_i": 5.0, "enable": True}

def on_connect(client, userdata, flags, rc, properties=None):
  print("Connected:", rc)
  client.subscribe([(TOPIC_CMD, 1), (TOPIC_CFG, 1)])
  client.publish(TOPIC_STATUS, json.dumps({"online": True, "fw": "sim-1.0", "status": 1}), qos=1, retain=True)

def on_message(client, userdata, msg):
  try: data = json.loads(msg.payload.decode())
  except: print("Invalid JSON on", msg.topic); return
  if msg.topic == TOPIC_CMD:
    for k in ["setpoint_v", "setpoint_i", "enable"]:
      if k in data: state[k] = data[k]
    print("CMD:", data)
  elif msg.topic == TOPIC_CFG:
    global REPORT_MS
    REPORT_MS = int(data.get("report_period_ms", REPORT_MS))
    print("CFG:", data)

def loop_publish(client):
  while True:
    v = float(state["setpoint_v"]) + random.uniform(-0.05, 0.05)
    i = (float(state["setpoint_i"]) * 0.9 if state["enable"] else 0.0) + random.uniform(-0.02, 0.02)
    p = v * i
    temp = 35.0 + random.uniform(-1.0, 1.0)
    payload = {"v": round(v,3), "i": round(i,3), "p": round(p,3), "temp": round(temp,2),
              "status": 1, "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
    client.publish(TOPIC_TEL, json.dumps(payload), qos=1)
    time.sleep(REPORT_MS/1000.0)

def main():
  client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id=DEVICE_ID, clean_session=True)
  client.username_pw_set(USER, PASS)
  client.will_set(TOPIC_STATUS, json.dumps({"online": False, "status": 0}), qos=1, retain=True)
  client.on_connect = on_connect
  client.on_message = on_message
  client.connect(BROKER, PORT, keepalive=60)
  threading.Thread(target=loop_publish, args=(client,), daemon=True).start()
  client.loop_forever()

if __name__ == "__main__":
  main()