import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InfluxDBService {
  static final String _baseUrl =
      dotenv.env['INFLUXDB_URL'] ?? 'http://localhost:8086';
  static final String _token = dotenv.env['INFLUXDB_TOKEN'] ?? '';
  static final String _org = dotenv.env['INFLUXDB_ORG'] ?? '';
  static final String _bucket = dotenv.env['INFLUXDB_BUCKET'] ?? '';

  static Map<String, String> get _headers => {
    'Authorization': 'Token $_token',
    'Content-Type': 'application/json',
    'Accept': 'application/csv',
  };

  /// Obtiene datos de sensores desde InfluxDB usando mqtt_consumer measurement
  static Future<List<SensorReading>> getSensorData({
    required String field,
    String? deviceId,
    Duration? timeRange,
  }) async {
    try {
      // Consulta Flux para obtener datos del measurement mqtt_consumer
      final query = deviceId != null
          ? '''
from(bucket: "$_bucket")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "mqtt_consumer")
  |> filter(fn: (r) => r["_field"] == "$field")
  |> filter(fn: (r) => r["topic"] == "microgrid/$deviceId/telemetry")
  |> sort(columns: ["_time"], desc: true)
  |> limit(n: 50)
'''
          : '''
from(bucket: "$_bucket")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "mqtt_consumer")
  |> filter(fn: (r) => r["_field"] == "$field")
  |> sort(columns: ["_time"], desc: true)
  |> limit(n: 50)
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v2/query?org=$_org'),
        headers: _headers,
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final parsedData = _parseInfluxJsonResponse(response.body);
        return parsedData;
      } else {
        print('❌ InfluxDB Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ InfluxDB Connection Error: $e');
      return [];
    }
  }

  /// Obtiene últimos valores de sensores para el dashboard
  static Future<Map<String, SensorReading>> getLatestSensorData() async {
    try {
      // Variables del sistema BMS
      final fields = [
        'v_bat_conv',
        'v_out_conv',
        'v_cell1',
        'v_cell2',
        'v_cell3',
        'i_circuit',
        'soc_percent',
        'soh_percent',
        'alert',
        'chg_enable',
        'dsg_enable',
        'cp_enable',
        'pmon_enable',
      ];

      final Map<String, SensorReading> latestData = {};

      for (final field in fields) {
        final data = await getSensorData(
          field: field,
          deviceId: 'dev-001',
          timeRange: const Duration(hours: 2),
        );

        if (data.isNotEmpty) {
          latestData[field] = data.last;
        }
      }

      if (latestData.isNotEmpty) {
        print('✅ Datos BMS cargados: ${latestData.keys.length} campos');
      } else {
        print('⚠️ No se encontraron datos BMS');
      }

      return latestData;
    } catch (e) {
      return {};
    }
  }

  /// Obtiene datos históricos para gráficos
  static Future<List<SensorReading>> getHistoricalData({
    required String measurement,
    String? deviceId,
    required Duration timeRange,
  }) async {
    return getSensorData(
      field: measurement,
      deviceId: deviceId,
      timeRange: timeRange,
    );
  }

  /// Parsea la respuesta CSV de InfluxDB
  static List<SensorReading> _parseInfluxJsonResponse(String csvData) {
    final List<SensorReading> readings = [];

    if (csvData.trim().isEmpty || csvData.length <= 2) {
      return readings;
    }

    try {
      final lines = csvData.split('\n');
      if (lines.length < 2) return readings;

      // Buscar índices de columnas importantes
      final headers = lines[0].split(',');
      final timeIndex = headers.indexOf('_time');
      final valueIndex = headers.indexOf('_value');
      final measurementIndex = headers.indexOf('_measurement');
      final deviceIdIndex = headers.indexOf('device_id');

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final values = line.split(',');
        if (values.length <= valueIndex || valueIndex < 0) continue;

        try {
          final rawValue = values[valueIndex];
          final measurement =
              measurementIndex >= 0 && measurementIndex < values.length
              ? values[measurementIndex]
              : 'mqtt_consumer';

          final numericValue = double.tryParse(rawValue) ?? 0.0;

          final reading = SensorReading(
            timestamp: timeIndex >= 0 && timeIndex < values.length
                ? DateTime.parse(values[timeIndex])
                : DateTime.now(),
            value: numericValue,
            textValue: null,
            measurement: measurement,
            deviceId: deviceIdIndex >= 0 && deviceIdIndex < values.length
                ? values[deviceIdIndex]
                : 'dev-001',
          );
          readings.add(reading);
        } catch (e) {
          // Ignorar errores de parseado menores
        }
      }
    } catch (e) {
      print('❌ Error parseando datos InfluxDB: $e');
    }

    return readings;
  }
}

/// Modelo
class SensorReading {
  final DateTime timestamp;
  final double value;
  final String? textValue;
  final String measurement;
  final String deviceId;

  SensorReading({
    required this.timestamp,
    required this.value,
    this.textValue,
    required this.measurement,
    required this.deviceId,
  });

  /// Obtiene el valor como string, útil para campos como 'status'
  String get valueAsString => textValue ?? value.toString();

  @override
  String toString() {
    return 'SensorReading(timestamp: $timestamp, value: ${textValue ?? value}, measurement: $measurement, deviceId: $deviceId)';
  }
}
