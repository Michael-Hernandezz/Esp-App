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
} state;

unsigned long lastT = 0;

float readVoltage() { return state.setpoint_v + (random(-5, 5) / 100.0); }
float readCurrent() { return state.enable ? state.setpoint_i * 0.9 : 0.0; }
float readTemp() { return 35.0 + (random(-10, 10) / 10.0); }

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
    if (doc.containsKey("setpoint_v")) state.setpoint_v = doc["setpoint_v"].as<float>();
    if (doc.containsKey("setpoint_i")) state.setpoint_i = doc["setpoint_i"].as<float>();
    if (doc.containsKey("enable")) state.enable = doc["enable"].as<bool>();
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
    float v = readVoltage(), i = readCurrent(), p = v * i, temp = readTemp();
    StaticJsonDocument<256> doc;
    doc["v"] = v; doc["i"] = i; doc["p"] = p; doc["temp"] = temp;
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