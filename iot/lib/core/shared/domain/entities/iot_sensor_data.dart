import 'package:iot/core/shared/data/services/influxdb_service.dart';

class IoTSensorData {
  final String deviceId;
  final String roomName;
  final double? temperature;
  final double? voltage;
  final double? current;
  final double? pressure;
  final String? status;
  final DateTime lastUpdated;

  IoTSensorData({
    required this.deviceId,
    required this.roomName,
    this.temperature,
    this.voltage,
    this.current,
    this.pressure,
    this.status,
    required this.lastUpdated,
  });

  /// Creacion desde un mapa de lecturas de sensores
  static IoTSensorData fromSensorReadings({
    required String deviceId,
    required String roomName,
    required Map<String, SensorReading> readings,
  }) {
    return IoTSensorData(
      deviceId: deviceId,
      roomName: roomName,
      temperature: readings['temp']?.value,
      voltage: readings['v']?.value,
      current: readings['i']?.value,
      pressure: readings['p']?.value,
      status: readings['status']?.valueAsString,
      lastUpdated: readings.values.isNotEmpty
          ? readings.values.first.timestamp
          : DateTime.now(),
    );
  }

  /// Indica si el dispositivo esta funcional
  bool get isOnline => status?.toLowerCase() == '1';

  /// Obtiene el último valor de temperatura válido
  bool get hasValidData =>
      temperature != null || voltage != null || current != null;

  IoTSensorData copyWith({
    String? deviceId,
    String? roomName,
    double? temperature,
    double? voltage,
    double? current,
    double? pressure,
    String? status,
    DateTime? lastUpdated,
  }) {
    return IoTSensorData(
      deviceId: deviceId ?? this.deviceId,
      roomName: roomName ?? this.roomName,
      temperature: temperature ?? this.temperature,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      pressure: pressure ?? this.pressure,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Convierte a SmartRoom para compatibilidad con UI existente
  dynamic toSmartRoom({
    required String imageUrl,
    required dynamic lights,
    required dynamic airCondition,
    required dynamic timer,
    required dynamic musicInfo,
  }) {
    return {
      'id': deviceId,
      'name': roomName,
      'imageUrl': imageUrl,
      'temperature': temperature ?? 20.0,
      'voltage': voltage ?? 0.0,
      'current': current ?? 0.0,
      'pressure': pressure ?? 0.0,
      'status': status ?? 'unknown',
      'isOnline': isOnline,
      'lights': lights,
      'airCondition': airCondition,
      'timer': timer,
      'musicInfo': musicInfo,
      'lastUpdated': lastUpdated,
    };
  }

  @override
  String toString() {
    return 'IoTSensorData(deviceId: $deviceId, roomName: $roomName, temp: $temperature°C, voltage: ${voltage}V, current: ${current}A, pressure: ${pressure}Pa, status: $status, updated: $lastUpdated)';
  }
}
