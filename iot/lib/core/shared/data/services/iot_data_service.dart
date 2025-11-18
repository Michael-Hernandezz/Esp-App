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
          roomName: _getDeviceName(deviceId),
          readings: deviceData,
        );

        // Solo agregar si hay datos válidos
        if (sensorData.hasValidData) {
          final room = SmartRoom(
            id: deviceId,
            name: sensorData.roomName,
            imageUrl: _getDeviceImage(deviceId),
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

      // Crear mapa base con datos del sistema
      final Map<String, dynamic> systemStats = {
        'total_devices': uniqueDevices.length,
        'active_devices': activeDevices.length,
        'last_update': latestData.isNotEmpty
            ? latestData.values.first.timestamp
            : DateTime.now(),
      };

      // Agregar datos de sensores específicos
      if (latestData.containsKey('v_bat_conv')) {
        systemStats['avg_battery_voltage'] = latestData['v_bat_conv']!.value;
      } else {
        systemStats['avg_battery_voltage'] = 0.0;
      }

      if (latestData.containsKey('v_out_conv')) {
        systemStats['avg_output_voltage'] = latestData['v_out_conv']!.value;
      } else {
        systemStats['avg_output_voltage'] = 0.0;
      }

      if (latestData.containsKey('i_circuit')) {
        systemStats['avg_current'] = latestData['i_circuit']!.value;
      } else {
        systemStats['avg_current'] = 0.0;
      }

      if (latestData.containsKey('soc_percent')) {
        systemStats['avg_soc'] = latestData['soc_percent']!.value;
      } else {
        systemStats['avg_soc'] = 0.0;
      }

      if (latestData.containsKey('soh_percent')) {
        systemStats['avg_soh'] = latestData['soh_percent']!.value;
      } else {
        systemStats['avg_soh'] = 0.0;
      }

      if (latestData.containsKey('status')) {
        systemStats['system_status'] = latestData['status']!.valueAsString;
      } else {
        systemStats['system_status'] = 'unknown';
      }

      // *** AGREGAR ESTADOS BMS PARA PERSISTENCIA ***
      if (latestData.containsKey('chg_enable')) {
        systemStats['chg_enable'] = latestData['chg_enable']!.value.round();
      }
      if (latestData.containsKey('dsg_enable')) {
        systemStats['dsg_enable'] = latestData['dsg_enable']!.value.round();
      }
      if (latestData.containsKey('cp_enable')) {
        systemStats['cp_enable'] = latestData['cp_enable']!.value.round();
      }
      if (latestData.containsKey('pmon_enable')) {
        systemStats['pmon_enable'] = latestData['pmon_enable']!.value.round();
      }

      return systemStats;
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

  /// Convierte el deviceId a un nombre más amigable
  static String _getDeviceName(String deviceId) {
    switch (deviceId.toLowerCase()) {
      case 'test-device':
      case 'test_device':
        return 'DEV-001';
      default:
        return deviceId.toUpperCase().replaceAll('_', ' ');
    }
  }

  /// Asigna la imagen correspondiente según el tipo de dispositivo
  static String _getDeviceImage(String deviceId) {
    switch (deviceId.toLowerCase()) {
      case 'test-device':
      case 'test_device':
        return 'assets/images/4.jpeg'; // Imagen diferente para ESP32/dispositivo IoT
      default:
        return 'assets/images/0.jpeg'; // Imagen por defecto
    }
  }
}
