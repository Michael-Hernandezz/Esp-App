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
      print('Iniciando consulta para measurement: $measurement');

      // Consulta Flux para obtener datos
      final query =
          '''
from(bucket: "$_bucket")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_field"] == "$measurement")
  |> sort(columns: ["_time"], desc: true)
  |> limit(n: 10)
''';

      print('Query: $query');
      print('URL: $_baseUrl/api/v2/query?org=$_org');
      print('Headers: $_headers');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v2/query?org=$_org'),
        headers: _headers,
        body: jsonEncode({'query': query}),
      );

      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Respuesta exitosa de InfluxDB para $measurement');
        print('Contenido completo de respuesta: ${response.body}');
        print('Longitud de respuesta: ${response.body.length}');
        final parsedData = _parseInfluxJsonResponse(response.body);
        print('Datos parseados: ${parsedData.length} registros');
        if (parsedData.isNotEmpty) {
          print('Primer registro: ${parsedData.first}');
        }
        return parsedData;
      } else {
        print('Error en InfluxDB: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al obtener datos de InfluxDB: $e');
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
          timeRange: const Duration(hours: 24),
        );

        if (data.isNotEmpty) {
          latestData[measurement] = data.last;
        }
      }

      return latestData;
    } catch (e) {
      print('Error al obtener datos más recientes: $e');
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
  static List<SensorReading> _parseInfluxJsonResponse(String csvData) {
    final List<SensorReading> readings = [];

    if (csvData.trim().isEmpty || csvData.length <= 2) {
      print('Respuesta vacía de InfluxDB');
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

      print('Headers encontrados: $headers');
      print(
        'Índices - time: $timeIndex, value: $valueIndex, measurement: $measurementIndex, device: $deviceIdIndex',
      );

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
              : 'unknown';

          final numericValue = double.tryParse(rawValue) ?? 0.0;
          final textValue = null;

          final reading = SensorReading(
            timestamp: timeIndex >= 0 && timeIndex < values.length
                ? DateTime.parse(values[timeIndex])
                : DateTime.now(),
            value: numericValue,
            textValue: textValue,
            measurement: measurement,
            deviceId: deviceIdIndex >= 0 && deviceIdIndex < values.length
                ? values[deviceIdIndex]
                : 'unknown',
          );
          readings.add(reading);
          print('Registro parseado: ${reading.toString()}');
        } catch (e) {
          print('Error parseando línea: $line - $e');
        }
      }
    } catch (e) {
      print('Error general parseando CSV: $e');
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
