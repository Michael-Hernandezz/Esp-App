#include <WiFi.h>
#include <AsyncMqttClient.h>
#include <ArduinoJson.h>
#include <NTPClient.h>
#include <WiFiUdp.h>

#ifndef WIFI_SSID
#define WIFI_SSID "ssid"
#endif
#ifndef WIFI_PASS
#define WIFI_PASS "pass"
#endif
#ifndef MQTT_HOST
#define MQTT_HOST "192.168.1.100"
#endif
#ifndef MQTT_PORT
#define MQTT_PORT 1883
#endif
#ifndef DEVICE_ID
#define DEVICE_ID "dev-001"
#endif
#ifndef MQTT_USER
#define MQTT_USER "dev-001"
#endif
#ifndef MQTT_PASS
#define MQTT_PASS "password"
#endif

AsyncMqttClient mqtt;
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 0, 60000);

const char* BASE = "microgrid";
String topicTel = String(BASE) + "/" + DEVICE_ID + "/telemetry";
String topicCmd = String(BASE) + "/" + DEVICE_ID + "/cmd";
String topicCfg = String(BASE) + "/" + DEVICE_ID + "/cfg";
String topicStatus = String(BASE) + "/" + DEVICE_ID + "/status";

struct State {
  float setpoint_v = 24.0;
  float setpoint_i = 5.0;
  bool enable = true;
  uint32_t period = 1000;
  
  // Estados de actuadores BMS
  bool chg_enable = false;
  bool dsg_enable = false;
  bool cp_enable = false;
  bool pmon_enable = true;
} state;

unsigned long lastT = 0;

// Simulación de lecturas BMS
float readVBatConv() { return 24.0 + (random(-10, 10) / 100.0); }
float readVOutConv() { return 12.0 + (random(-5, 5) / 100.0); }
float readVCell1() { return 3.7 + (random(-2, 2) / 100.0); }
float readVCell2() { return 3.6 + (random(-2, 2) / 100.0); }
float readVCell3() { return 3.8 + (random(-2, 2) / 100.0); }
float readICurrent() { return state.enable ? 2.5 + (random(-10, 10) / 100.0) : 0.0; }
float readSOC() { return 75.0 + (random(-5, 5) / 10.0); }
float readSOH() { return 95.0 + (random(-2, 2) / 10.0); }
int readAlert() { return random(0, 100) > 95 ? 1 : 0; }

void publishStatus(bool online) {
  StaticJsonDocument<128> doc;
  doc["online"] = online;
  String s; serializeJson(doc, s);
  mqtt.publish(topicStatus.c_str(), 1, true, s.c_str(), s.length());
}

void onMsg(char* topic, char* payload, AsyncMqttClientMessageProperties properties, size_t len, size_t index, size_t total) {
  StaticJsonDocument<256> doc;
  if (deserializeJson(doc, payload, len)) return;
  if (String(topic) == topicCmd) {
    // Comandos legacy
    if (doc.containsKey("setpoint_v")) state.setpoint_v = doc["setpoint_v"].as<float>();
    if (doc.containsKey("setpoint_i")) state.setpoint_i = doc["setpoint_i"].as<float>();
    if (doc.containsKey("enable")) state.enable = doc["enable"].as<bool>();
    
    // Comandos de actuadores BMS
    if (doc.containsKey("chg_enable")) {
      state.chg_enable = doc["chg_enable"].as<int>() == 1;
      Serial.println("CHG Enable: " + String(state.chg_enable));
    }
    if (doc.containsKey("dsg_enable")) {
      state.dsg_enable = doc["dsg_enable"].as<int>() == 1;
      Serial.println("DSG Enable: " + String(state.dsg_enable));
    }
    if (doc.containsKey("cp_enable")) {
      state.cp_enable = doc["cp_enable"].as<int>() == 1;
      Serial.println("CP Enable: " + String(state.cp_enable));
    }
    if (doc.containsKey("pmon_enable")) {
      state.pmon_enable = doc["pmon_enable"].as<int>() == 1;
      Serial.println("PMON Enable: " + String(state.pmon_enable));
    }
  } else if (String(topic) == topicCfg) {
    if (doc.containsKey("report_period_ms")) state.period = doc["report_period_ms"].as<uint32_t>();
  }
}

void connectMqtt() {
  mqtt.setClientId(DEVICE_ID);
  mqtt.setCredentials(MQTT_USER, MQTT_PASS);
  mqtt.setServer(MQTT_HOST, MQTT_PORT);
  StaticJsonDocument<64> will; will["online"] = false; String w; serializeJson(will, w);
  mqtt.setWill(topicStatus.c_str(), 1, true, w.c_str(), w.length());
  mqtt.connect();
}

void onMqttConnect(bool sessionPresent) {
  mqtt.subscribe(topicCmd.c_str(), 1);
  mqtt.subscribe(topicCfg.c_str(), 1);
  publishStatus(true);
}

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) { delay(300); }
  timeClient.begin();
  mqtt.onMessage(onMsg);
  mqtt.onConnect(onMqttConnect);
  connectMqtt();
}

void loop() {
  timeClient.update();
  unsigned long now = millis();
  if (now - lastT >= state.period) {
    lastT = now;
    
    // Leer todas las variables del BMS
    float vBatConv = readVBatConv();
    float vOutConv = readVOutConv();
    float vCell1 = readVCell1();
    float vCell2 = readVCell2();
    float vCell3 = readVCell3();
    float iCircuit = readICurrent();
    float socPercent = readSOC();
    float sohPercent = readSOH();
    int alert = readAlert();
    
    StaticJsonDocument<512> doc;
    
    // Variables del sistema BMS
    doc["v_bat_conv"] = vBatConv;
    doc["v_out_conv"] = vOutConv;
    doc["v_cell1"] = vCell1;
    doc["v_cell2"] = vCell2;
    doc["v_cell3"] = vCell3;
    doc["i_circuit"] = iCircuit;
    doc["soc_percent"] = socPercent;
    doc["soh_percent"] = sohPercent;
    doc["alert"] = alert;
    
    // Estados de actuadores
    doc["chg_enable"] = state.chg_enable ? 1 : 0;
    doc["dsg_enable"] = state.dsg_enable ? 1 : 0;
    doc["cp_enable"] = state.cp_enable ? 1 : 0;
    doc["pmon_enable"] = state.pmon_enable ? 1 : 0;
    
    doc["status"] = "ok";
    String ts;
    time_t epoch = timeClient.getEpochTime(); struct tm* t = gmtime(&epoch);
    char buf[32]; strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", t); ts = buf;
    doc["timestamp"] = ts;
    
    String s; serializeJson(doc, s);
    mqtt.publish(topicTel.c_str(), 1, false, s.c_str(), s.length());
  }
  static unsigned long lastRetry = 0;
  if (!mqtt.connected() && WiFi.status() == WL_CONNECTED && millis() - lastRetry > 3000) {
    lastRetry = millis(); connectMqtt();
  }
}