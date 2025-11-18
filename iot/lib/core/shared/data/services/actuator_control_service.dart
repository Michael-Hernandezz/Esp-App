import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio para controlar actuadores del sistema BMS a través de la API
class ActuatorControlService {
  static final String _apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';

  /// Controla los actuadores del sistema BMS
  static Future<bool> controlActuators({
    required String deviceId,
    int? chgEnable, // 0 o 1
    int? dsgEnable, // 0 o 1
    int? cpEnable, // 0 o 1
    int? pmonEnable, // 0 o 1
  }) async {
    try {
      final Map<String, dynamic> payload = {'device_id': deviceId};

      // Solo agregar campos que no sean null
      if (chgEnable != null) payload['chg_enable'] = chgEnable;
      if (dsgEnable != null) payload['dsg_enable'] = dsgEnable;
      if (cpEnable != null) payload['cp_enable'] = cpEnable;
      if (pmonEnable != null) payload['pmon_enable'] = pmonEnable;

      final response = await http.post(
        Uri.parse('$_apiUrl/actuators/control'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el estado actual de todos los actuadores
  static Future<Map<String, int>?> getActuatorStatus(String deviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/actuators/status/$deviceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final actuators = result['actuators'] as Map<String, dynamic>?;

        if (actuators != null) {
          return actuators.map((key, value) => MapEntry(key, value as int));
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene telemetría histórica desde la API
  static Future<Map<String, List<TelemetryPoint>>?> getTelemetryData({
    required String deviceId,
    List<String>? fields,
    String start = '-15m',
    String stop = 'now()',
  }) async {
    try {
      final fieldsParam =
          fields?.join(',') ??
          'v_bat_conv,v_out_conv,v_cell1,v_cell2,v_cell3,i_circuit,soc_percent,soh_percent,alert,chg_enable,dsg_enable,cp_enable,pmon_enable';

      final uri = Uri.parse('$_apiUrl/telemetry/multi').replace(
        queryParameters: {
          'device_id': deviceId,
          'fields': fieldsParam,
          'start': start,
          'stop': stop,
        },
      );

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final series = result['series'] as Map<String, dynamic>?;

        if (series != null) {
          final Map<String, List<TelemetryPoint>> telemetryData = {};

          series.forEach((field, points) {
            final pointsList = (points as List)
                .map(
                  (point) =>
                      TelemetryPoint.fromJson(point as Map<String, dynamic>),
                )
                .toList();
            telemetryData[field] = pointsList;
          });

          return telemetryData;
        }
      } 

      return null;
    } catch (e) {
      return null;
    }
  }

  // Métodos de conveniencia para controlar actuadores individuales

  /// Control del CHG (carga)
  static Future<bool> controlCharger(String deviceId, bool enable) async {
    return await controlActuators(
      deviceId: deviceId,
      chgEnable: enable ? 1 : 0,
    );
  }

  /// Control del DSG (descarga)
  static Future<bool> controlDischarger(String deviceId, bool enable) async {
    return await controlActuators(
      deviceId: deviceId,
      dsgEnable: enable ? 1 : 0,
    );
  }

  /// Control de la bomba de carga (CP)
  static Future<bool> controlChargePump(String deviceId, bool enable) async {
    return await controlActuators(deviceId: deviceId, cpEnable: enable ? 1 : 0);
  }

  /// Control del monitoreo del pack (PMON)
  static Future<bool> controlPackMonitoring(
    String deviceId,
    bool enable,
  ) async {
    return await controlActuators(
      deviceId: deviceId,
      pmonEnable: enable ? 1 : 0,
    );
  }

  /// Obtiene los nombres legibles de los actuadores
  static Map<String, String> get actuatorNames => {
    'chg_enable': 'Carga (CHG)',
    'dsg_enable': 'Descarga (DSG)',
    'cp_enable': 'Bomba de Carga (CP)',
    'pmon_enable': 'Monitor Pack (PMON)',
  };

  /// Obtiene las descripciones de los actuadores
  static Map<String, String> get actuatorDescriptions => {
    'chg_enable': 'Activación de MOSFET de carga',
    'dsg_enable': 'Activación de MOSFET de descarga',
    'cp_enable': 'Activación de la bomba de carga',
    'pmon_enable': 'Activación del monitoreo del pack (voltaje)',
  };
}

/// Modelo para puntos de telemetría
class TelemetryPoint {
  final String time;
  final int epochMs;
  final double value;

  TelemetryPoint({
    required this.time,
    required this.epochMs,
    required this.value,
  });

  factory TelemetryPoint.fromJson(Map<String, dynamic> json) {
    return TelemetryPoint(
      time: json['time'] as String,
      epochMs: json['epochMs'] as int,
      value: (json['value'] as num).toDouble(),
    );
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(epochMs);

  @override
  String toString() {
    return 'TelemetryPoint(time: $time, value: $value)';
  }
}
