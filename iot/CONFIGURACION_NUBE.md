# ESP-APP Flutter - Configuración para Servidor en la Nube

## ✅ Cambios Realizados

### 1. **Configuración de Entorno (.env)**
- ✅ **InfluxDB URL**: Cambiado de `http://10.0.2.2:8086` a `http://104.131.178.99:8086`
- ✅ **API URL**: Cambiado de `http://10.0.2.2:8000` a `http://104.131.178.99:8000`
- ✅ **Token**: Usando token unificado `m9dZ53tgCda7obiBCJn4xFVloD8q9zbqckGPvMzlPxJ3Jwb2ur6gGp-sgWD-KjHH5tvJIqgCSvpuVKeOHj66rw==`
- ✅ **Bucket**: Configurado como `telemetry`
- ✅ **Organización**: Configurado como `microgrid`

### 2. **Servicio InfluxDB (influxdb_service.dart)**
- ✅ **Measurement**: Cambiado de campos individuales a `mqtt_consumer`
- ✅ **Query Flux**: Actualizada para usar `_measurement = "mqtt_consumer"`
- ✅ **Topics Filter**: Filtra por `topic = "microgrid/dev-001/telemetry"`
- ✅ **Fields**: Actualizado para usar los nuevos campos BMS
- ✅ **Método getSensorData**: Cambiado parámetro `measurement` a `field`

### 3. **Servicio de Control de Actuadores (actuator_control_service.dart)**
- ✅ **API URL**: Actualizada para usar servidor en la nube
- ✅ **Endpoints**: Configurados para usar `/actuators/control` y `/actuators/status`

### 4. **Servicio de Datos IoT (iot_data_service.dart)**
- ✅ **Método getLatestSensorData**: Agregado para obtener datos BMS como IoTSensorData
- ✅ **Integración**: Conecta InfluxDBService con widgets BMS

### 5. **Dashboard Principal (enhanced_dashboard_screen.dart)**
- ✅ **Sección BMS**: Actualizada para usar datos reales de InfluxDB
- ✅ **FutureBuilder**: Implementado para cargar datos asincrónicamente
- ✅ **Manejo de errores**: Muestra estado de conexión BMS
- ✅ **Widgets BMS**: Integrados BMSDataWidget y BMSControlWidget

### 6. **Configuración de Aplicación (app_config.dart)**
- ✅ **Archivo nuevo**: Configuración centralizada para desarrollo/producción
- ✅ **URLs**: Configurables entre local y nube
- ✅ **Logger**: Utilidades de logging para debugging

## 🎯 Configuración Final del Servidor

### **InfluxDB:**
- **URL**: http://104.131.178.99:8086
- **Bucket**: `telemetry`
- **Measurement**: `mqtt_consumer`
- **Org**: `microgrid`
- **Token**: `m9dZ53tgCda7obiBCJn4xFVloD8q9zbqckGPvMzlPxJ3Jwb2ur6gGp-sgWD-KjHH5tvJIqgCSvpuVKeOHj66rw==`

### **API REST:**
- **URL**: http://104.131.178.99:8000
- **Endpoints**:
  - `GET /health` - Health check
  - `POST /actuators/control` - Control de actuadores
  - `GET /actuators/status/{device_id}` - Estado de actuadores
  - `GET /telemetry/{device_id}` - Datos de telemetría

### **MQTT:**
- **Broker**: 104.131.178.99:1883
- **Username**: admin
- **Password**: admin12345
- **Topics**: 
  - `microgrid/dev-001/telemetry` - Datos del BMS
  - `microgrid/dev-001/cmd` - Comandos a dispositivo

## 📊 Campos BMS Disponibles

Los siguientes campos están disponibles en InfluxDB desde `mqtt_consumer`:

### **Voltajes:**
- `v_bat_conv` - Voltaje de batería (convertidor)
- `v_out_conv` - Voltaje de salida (convertidor)  
- `v_cell1` - Voltaje celda 1
- `v_cell2` - Voltaje celda 2
- `v_cell3` - Voltaje celda 3

### **Corriente y Estado:**
- `i_circuit` - Corriente del circuito
- `soc_percent` - Estado de carga (%)
- `soh_percent` - Salud de la batería (%)
- `alert` - Alerta (0/1)

### **Actuadores:**
- `chg_enable` - Cargador habilitado (0/1)
- `dsg_enable` - Descargador habilitado (0/1)
- `cp_enable` - Bomba de carga habilitada (0/1)
- `pmon_enable` - Monitor de pack habilitado (0/1)

## 🚀 Próximos Pasos

1. **Probar la aplicación Flutter**:
   ```bash
   cd iot
   flutter run
   ```

2. **Verificar conectividad**:
   - Revisar que los datos aparezcan en el dashboard
   - Probar control de actuadores
   - Verificar gráficos históricos

3. **Debugging**:
   - Logs aparecerán en consola Flutter
   - Verificar conexión a http://104.131.178.99:8000/health
   - Revisar datos en http://104.131.178.99:8086

4. **Simulación de datos**:
   ```bash
   cd tools
   python simulate_device.py
   ```

## 🔧 Configuración de Desarrollo vs Producción

Para cambiar entre servidor local y nube, editar `lib/core/config/app_config.dart`:

```dart
// Para usar servidor en la nube (ACTUAL)
static const bool useCloudServer = true;

// Para usar servidor local (DESARROLLO)
static const bool useCloudServer = false;
```

¡La aplicación Flutter está lista para funcionar con tu servidor en la nube! 🎉