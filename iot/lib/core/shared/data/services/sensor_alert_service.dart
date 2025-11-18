import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:iot/core/shared/domain/entities/sensor_range.dart';
import 'package:iot/core/shared/domain/entities/iot_sensor_data.dart';
import 'package:iot/core/shared/data/services/influxdb_service.dart';

/// Servicio que monitorea los valores de los sensores y genera alertas
class SensorAlertService extends ChangeNotifier {
  static final SensorAlertService _instance = SensorAlertService._internal();
  factory SensorAlertService() => _instance;
  SensorAlertService._internal();

  // Lista de alertas activas
  final List<SensorAlert> _activeAlerts = [];
  List<SensorAlert> get activeAlerts => List.unmodifiable(_activeAlerts);

  // Lista de todas las alertas (historial)
  final List<SensorAlert> _allAlerts = [];
  List<SensorAlert> get allAlerts => List.unmodifiable(_allAlerts);

  // Timer para monitoreo periódico
  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  bool get isMonitoring => _isMonitoring;

  // Configuración de intervalos de monitoreo
  static const Duration _monitoringInterval = Duration(seconds: 10);
  static const Duration _alertCooldown = Duration(minutes: 1);

  // Mapa para controlar el cooldown de alertas repetidas
  final Map<String, DateTime> _lastAlertTime = {};

  /// Inicia el monitoreo automático de sensores
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(_monitoringInterval, (timer) {
      _checkSensorValues();
    });
    
    // También hacer una verificación inmediata
    _checkSensorValues();
    
    print('SensorAlertService: Monitoreo iniciado');
    notifyListeners();
  }

  /// Detiene el monitoreo automático
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    print('SensorAlertService: Monitoreo detenido');
    notifyListeners();
  }

  /// Valida datos específicos de sensores y genera alertas si es necesario
  /// Este método debe llamarse cuando se reciban nuevos datos de sensores
  Future<void> validateSensorData(Map<String, double> sensorValues) async {
    try {
      // Validar todos los valores
      final newAlerts = SensorRangeConfig.validateSensorData(sensorValues);
      
      // Procesar las nuevas alertas
      for (final alert in newAlerts) {
        _processNewAlert(alert);
      }

      // Limpiar alertas obsoletas
      _cleanupOldAlerts();

    } catch (e) {
      print('Error al validar datos de sensores: $e');
    }
  }

  /// Verifica los valores actuales de los sensores (método privado para monitoreo automático)
  Future<void> _checkSensorValues() async {
    try {
      // Obtener los datos más recientes de InfluxDB
      final latestData = await InfluxDBService.getLatestSensorData();
      
      if (latestData.isEmpty) return;

      // Convertir los datos a un mapa con los nombres correctos de variables
      final Map<String, double> sensorValues = {};
      
      // Mapear los datos de InfluxDB a nuestras variables de rango
      for (final entry in latestData.entries) {
        final measurement = entry.key;
        final reading = entry.value;
        
        switch (measurement) {
          case 'v_bat_conv':
            sensorValues['v_conv_in'] = reading.value;
            break;
          case 'v_out_conv':
            sensorValues['v_conv_out'] = reading.value;
            break;
          case 'v_cell_1':
            sensorValues['v_cell_1'] = reading.value;
            break;
          case 'v_cell_2':
            sensorValues['v_cell_2'] = reading.value;
            break;
          case 'v_cell_3':
            sensorValues['v_cell_3'] = reading.value;
            break;
          case 'i_circuit':
            sensorValues['i_circuit'] = reading.value;
            break;
          case 'soc_percent':
            sensorValues['soc_percent'] = reading.value;
            break;
          case 'soh_percent':
            // Usar SOH para estado de carga también
            sensorValues['charge_state'] = reading.value;
            break;
        }
      }

      // Usar el nuevo método para validar datos
      await validateSensorData(sensorValues);

    } catch (e) {
      print('Error al verificar valores de sensores: $e');
    }
  }

  /// Procesa una nueva alerta aplicando cooldown
  void _processNewAlert(SensorAlert alert) {
    final now = DateTime.now();
    final lastAlert = _lastAlertTime[alert.variable];
    
    // Aplicar cooldown para evitar spam de alertas
    if (lastAlert != null && 
        now.difference(lastAlert) < _alertCooldown) {
      return; // Saltar esta alerta por estar en cooldown
    }

    // Agregar la alerta a las listas
    _activeAlerts.add(alert);
    _allAlerts.insert(0, alert); // Agregar al principio para orden cronológico inverso
    _lastAlertTime[alert.variable] = now;

    print('Nueva alerta: ${alert.message}');
    notifyListeners();

    // Limitar el historial de alertas
    if (_allAlerts.length > 100) {
      _allAlerts.removeLast();
    }
  }

  /// Método público para agregar alertas manualmente (útil para testing)
  void addTestAlert(SensorAlert alert) {
    _processNewAlert(alert);
  }

  /// Limpia alertas antiguas de la lista activa
  void _cleanupOldAlerts() {
    final now = DateTime.now();
    const maxAlertAge = Duration(minutes: 5);

    _activeAlerts.removeWhere((alert) {
      return now.difference(alert.timestamp) > maxAlertAge;
    });
  }

  /// Elimina una alerta específica de las alertas activas
  void dismissAlert(SensorAlert alert) {
    _activeAlerts.remove(alert);
    notifyListeners();
  }

  /// Elimina todas las alertas activas
  void dismissAllAlerts() {
    _activeAlerts.clear();
    notifyListeners();
  }

  /// Obtiene el número de alertas críticas activas
  int get criticalAlertsCount {
    return _activeAlerts
        .where((alert) => alert.alertType == AlertType.critical)
        .length;
  }

  /// Obtiene el número de alertas anormales activas
  int get abnormalAlertsCount {
    return _activeAlerts
        .where((alert) => alert.alertType == AlertType.abnormal)
        .length;
  }

  /// Verifica si hay alertas activas
  bool get hasActiveAlerts => _activeAlerts.isNotEmpty;

  /// Obtiene la alerta más reciente
  SensorAlert? get latestAlert {
    if (_activeAlerts.isEmpty) return null;
    return _activeAlerts.first;
  }

  /// Fuerza una verificación manual inmediata
  Future<void> forceCheck() async {
    await _checkSensorValues();
  }

  /// Obtiene estadísticas de alertas
  Map<String, dynamic> getAlertStats() {
    final now = DateTime.now();
    final last24Hours = _allAlerts
        .where((alert) => now.difference(alert.timestamp) < const Duration(hours: 24))
        .toList();

    return {
      'total_alerts_24h': last24Hours.length,
      'active_alerts': _activeAlerts.length,
      'critical_alerts': criticalAlertsCount,
      'abnormal_alerts': abnormalAlertsCount,
      'most_frequent_variable': _getMostFrequentVariable(last24Hours),
      'monitoring_status': _isMonitoring,
    };
  }

  /// Obtiene la variable con más alertas
  String _getMostFrequentVariable(List<SensorAlert> alerts) {
    final Map<String, int> frequency = {};
    
    for (final alert in alerts) {
      frequency[alert.variable] = (frequency[alert.variable] ?? 0) + 1;
    }

    if (frequency.isEmpty) return 'none';

    return frequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}