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

state = {
  "setpoint_v": 24.0, "setpoint_i": 5.0, "enable": True,
  "chg_enable": False, "dsg_enable": False, 
  "cp_enable": False, "pmon_enable": True
}

def on_connect(client, userdata, flags, rc, properties=None):
  print("Connected:", rc)
  client.subscribe([(TOPIC_CMD, 1), (TOPIC_CFG, 1)])
  client.publish(TOPIC_STATUS, json.dumps({"online": True, "fw": "sim-1.0", "status": 1}), qos=1, retain=True)

def on_message(client, userdata, msg):
  try: data = json.loads(msg.payload.decode())
  except: print("Invalid JSON on", msg.topic); return
  if msg.topic == TOPIC_CMD:
    # Comandos legacy
    for k in ["setpoint_v", "setpoint_i", "enable"]:
      if k in data: state[k] = data[k]
    # Comandos de actuadores
    for k in ["chg_enable", "dsg_enable", "cp_enable", "pmon_enable"]:
      if k in data: 
        state[k] = bool(data[k])
        print(f"Actuator {k}: {state[k]}")
    print("CMD:", data)
  elif msg.topic == TOPIC_CFG:
    global REPORT_MS
    REPORT_MS = int(data.get("report_period_ms", REPORT_MS))
    print("CFG:", data)

def loop_publish(client):
  while True:
    # Simular variables del BMS
    v_bat_conv = 24.0 + random.uniform(-0.1, 0.1)
    v_out_conv = 12.0 + random.uniform(-0.05, 0.05)
    v_cell1 = 3.7 + random.uniform(-0.02, 0.02)
    v_cell2 = 3.6 + random.uniform(-0.02, 0.02)
    v_cell3 = 3.8 + random.uniform(-0.02, 0.02)
    i_circuit = (2.5 if state["enable"] else 0.1) + random.uniform(-0.02, 0.02)
    soc_percent = 75.0 + random.uniform(-0.5, 0.5)
    soh_percent = 95.0 + random.uniform(-0.2, 0.2)
    alert = 1 if random.random() > 0.98 else 0
    
    payload = {
      "v_bat_conv": round(v_bat_conv, 3),
      "v_out_conv": round(v_out_conv, 3),
      "v_cell1": round(v_cell1, 3),
      "v_cell2": round(v_cell2, 3),
      "v_cell3": round(v_cell3, 3),
      "i_circuit": round(i_circuit, 3),
      "soc_percent": round(soc_percent, 1),
      "soh_percent": round(soh_percent, 1),
      "alert": alert,
      "chg_enable": 1 if state["chg_enable"] else 0,
      "dsg_enable": 1 if state["dsg_enable"] else 0,
      "cp_enable": 1 if state["cp_enable"] else 0,
      "pmon_enable": 1 if state["pmon_enable"] else 0,
      "status": "ok",
      "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    }
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