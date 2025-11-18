import 'package:iot/core/shared/data/services/influxdb_service.dart';
import 'package:iot/core/shared/domain/entities/iot_sensor_data.dart';
import 'package:iot/core/shared/domain/entities/smart_room.dart';
import 'package:iot/core/shared/domain/entities/smart_device.dart';
import 'package:iot/core/shared/domain/entities/music_info.dart';

class IoTDataService {
  /// Obtiene datos reales de sensores IoT
  static Future<List<SmartRoom>> getRealIoTData() async {
    try {
      // Obtener datos del último período
      final latestData = await InfluxDBService.getLatestSensorData();

      if (latestData.isEmpty) {
        print('No hay datos disponibles desde InfluxDB');
        return [];
      }

      final List<SmartRoom> rooms = [];

      // Agrupar datos por dispositivo
      final deviceMap = <String, Map<String, SensorReading>>{};
      latestData.forEach((measurement, reading) {
        final deviceId = reading.deviceId;
        if (!deviceMap.containsKey(deviceId)) {
          deviceMap[deviceId] = {};
        }
        deviceMap[deviceId]![measurement] = reading;
      });

      // Crear una SmartRoom por cada dispositivo encontrado
      deviceMap.forEach((deviceId, deviceData) {
        final sensorData = IoTSensorData.fromSensorReadings(
          deviceId: deviceId,
          roomName: deviceId.toUpperCase().replaceAll('_', ' '),
          readings: deviceData,
        );

        // Solo agregar si hay datos válidos
        if (sensorData.hasValidData) {
          final room = SmartRoom(
            id: deviceId,
            name: sensorData.roomName,
            imageUrl: 'assets/images/0.jpeg', // Imagen por defecto
            temperature:
                sensorData.vBatConv ??
                20.0, // Usar voltaje de batería como "temperatura" para compatibilidad
            airHumidity: 0.0, // No disponible
            lights: SmartDevice(
              isOn: sensorData.isOnline,
              value: sensorData.isOnline ? 100 : 0,
            ),
            airCondition: SmartDevice(
              isOn:
                  (sensorData.vBatConv ?? 20) >
                  25, // Usar voltaje de batería como referencia
              value: (sensorData.socPercent ?? 50)
                  .round(), // Usar SOC como valor
            ),
            timer: SmartDevice(isOn: false, value: 0),
            musicInfo: MusicInfo(isOn: false, currentSong: Song.defaultSong),
          );
          rooms.add(room);
        }
      });

      return rooms;
    } catch (e) {
      print('Error obteniendo datos IoT reales: $e');
      return [];
    }
  }

  /// Obtiene datos históricos para gráficos
  static Future<List<SensorReading>> getHistoricalData({
    required String measurement,
    String? deviceId,
    Duration? timeRange,
  }) async {
    return await InfluxDBService.getHistoricalData(
      measurement: measurement,
      deviceId: deviceId,
      timeRange: timeRange ?? const Duration(hours: 24),
    );
  }

  /// Verifica si InfluxDB está disponible
  static Future<bool> isInfluxDBAvailable() async {
    try {
      final testData = await InfluxDBService.getLatestSensorData();
      return testData.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene estadísticas del sistema
  static Future<Map<String, dynamic>> getSystemStats() async {
    try {
      final latestData = await InfluxDBService.getLatestSensorData();

      // Contar dispositivos únicos
      final uniqueDevices = latestData.values.map((r) => r.deviceId).toSet();
      final activeDevices = latestData.values
          .where(
            (r) =>
                r.measurement == 'status' &&
                r.valueAsString.toLowerCase() == 'ok',
          )
          .map((r) => r.deviceId)
          .toSet();

      return {
        'total_devices': uniqueDevices.length,
        'active_devices': activeDevices.length,
        'last_update': latestData.isNotEmpty
            ? latestData.values.first.timestamp
            : DateTime.now(),
        'avg_battery_voltage': latestData.containsKey('v_bat_conv')
            ? latestData['v_bat_conv']!.value
            : 0.0,
        'avg_output_voltage': latestData.containsKey('v_out_conv')
            ? latestData['v_out_conv']!.value
            : 0.0,
        'avg_current': latestData.containsKey('i_circuit')
            ? latestData['i_circuit']!.value
            : 0.0,
        'avg_soc': latestData.containsKey('soc_percent')
            ? latestData['soc_percent']!.value
            : 0.0,
        'avg_soh': latestData.containsKey('soh_percent')
            ? latestData['soh_percent']!.value
            : 0.0,
        'system_status': latestData.containsKey('status')
            ? latestData['status']!.valueAsString
            : 'unknown',
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {
        'total_devices': 0,
        'active_devices': 0,
        'last_update': DateTime.now(),
        'avg_battery_voltage': 0.0,
        'avg_output_voltage': 0.0,
        'avg_current': 0.0,
        'avg_soc': 0.0,
        'avg_soh': 0.0,
        'system_status': 'error',
      };
    }
  }

  /// Obtiene los últimos datos del sensor BMS como IoTSensorData
  static Future<IoTSensorData?> getLatestSensorData() async {
    try {
      final sensorReadings = await InfluxDBService.getLatestSensorData();

      if (sensorReadings.isEmpty) {
        print('⚠️ Sin datos BMS disponibles');
        return null;
      }

      // Crear IoTSensorData desde las lecturas
      return IoTSensorData.fromSensorReadings(
        deviceId: 'dev-001', // Device ID por defecto
        roomName: 'Sistema BMS',
        readings: sensorReadings,
      );
    } catch (e) {
      print('Error obteniendo datos del sensor: $e');
      return null;
    }
  }
}
