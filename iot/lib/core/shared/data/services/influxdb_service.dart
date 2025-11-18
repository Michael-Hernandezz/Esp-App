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

  /// Obtiene datos de sensores desde InfluxDB
  static Future<List<SensorReading>> getSensorData({
    required String measurement,
    String? deviceId,
    Duration? timeRange,
  }) async {
    try {
      // Consulta Flux - Telegraf guarda todo en measurement="telemetry" y cada variable es un field
      final hours = timeRange?.inHours ?? 24;
      final query =
          '''
from(bucket: "$_bucket")
  |> range(start: -${hours}h)
  |> filter(fn: (r) => r["_measurement"] == "telemetry")
  |> filter(fn: (r) => r["_field"] == "$measurement")
  ${deviceId != null ? '|> filter(fn: (r) => r["device_id"] == "$deviceId")' : ''}
  |> sort(columns: ["_time"], desc: true)
  |> limit(n: 100)
''';


      final response = await http.post(
        Uri.parse('$_baseUrl/api/v2/query?org=$_org'),
        headers: _headers,
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final parsedData = _parseInfluxJsonResponse(response.body, measurement);
        return parsedData;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Obtiene últimos valores de sensores para el dashboard
  static Future<Map<String, SensorReading>> getLatestSensorData() async {
    try {
      // Nuevas variables del sistema BMS
      final measurements = [
        'v_bat_conv', // Voltaje de batería (convertidor)
        'v_out_conv', // Voltaje de salida (convertidor)
        'v_cell1', // Voltaje celda 1
        'v_cell2', // Voltaje celda 2
        'v_cell3', // Voltaje celda 3
        'i_circuit', // Corriente del circuito
        'soc_percent', // Estado de carga (%)
        'soh_percent', // Salud de la batería (%)
        'alert', // Alerta (1/0)
        'chg_enable', // CHG enable (1/0)
        'dsg_enable', // DSG enable (1/0)
        'cp_enable', // CP enable (1/0)
        'pmon_enable', // PMON enable (1/0)
        'status', // Estado general
      ];

      final Map<String, SensorReading> latestData = {};

      for (final measurement in measurements) {
        final data = await getSensorData(
          measurement: measurement,
          deviceId: 'dev-001', // Filtrar específicamente por dev-001
          timeRange: const Duration(hours: 1), // Reducir a 1 hora para debug
        );
        if (data.isNotEmpty) {
          latestData[measurement] =
              data.first; // Usar first porque ordenamos descendentemente
        }
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
      measurement: measurement,
      deviceId: deviceId,
      timeRange: timeRange,
    );
  }

  /// Parsea la respuesta CSV de InfluxDB
  static List<SensorReading> _parseInfluxJsonResponse(
    String csvData,
    String fieldName,
  ) {
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
      final fieldIndex = headers.indexOf('_field');
      final deviceIdIndex = headers.indexOf('device_id');

      if (valueIndex < 0) return readings;

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final values = line.split(',');
        if (values.length <= valueIndex) continue;

        try {
          final rawValue = values[valueIndex];
          final field = fieldIndex >= 0 && fieldIndex < values.length
              ? values[fieldIndex]
              : fieldName;

          final numericValue = double.tryParse(rawValue) ?? 0.0;

          final reading = SensorReading(
            timestamp: timeIndex >= 0 && timeIndex < values.length
                ? DateTime.parse(values[timeIndex])
                : DateTime.now(),
            value: numericValue,
            textValue: null,
            measurement:
                field, // Usar el field como measurement para compatibilidad
            deviceId: deviceIdIndex >= 0 && deviceIdIndex < values.length
                ? values[deviceIdIndex]
                : 'unknown',
          );
          readings.add(reading);
        } catch (e) {
          // Ignorar líneas inválidas silenciosamente
          continue;
        }
      }
    } catch (e) {
      // Ignorar errores de parseo silenciosamente
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
