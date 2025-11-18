/// Clase que define los rangos de valores para cada variable del sensor
class SensorRange {
  const SensorRange({
    required this.variable,
    required this.adequateMin,
    required this.adequateMax,
    required this.abnormalCondition,
    required this.maximumMax,
    required this.unit,
  });

  final String variable;
  final double adequateMin;
  final double adequateMax;
  final String abnormalCondition;
  final double maximumMax;
  final String unit;

  /// Verifica si un valor está en el rango adecuado
  bool isInAdequateRange(double value) {
    return value >= adequateMin && value <= adequateMax;
  }

  /// Verifica si un valor está en rango anormal
  bool isInAbnormalRange(double value) {
    return value < adequateMin || value > adequateMax;
  }

  /// Verifica si un valor está en el rango máximo crítico
  bool isInCriticalRange(double value) {
    return value > maximumMax || value < 0;
  }

  /// Obtiene el tipo de alerta basado en el valor
  AlertType getAlertType(double value) {
    if (isInCriticalRange(value)) {
      return AlertType.critical;
    } else if (value < adequateMin) {
      return AlertType.below;  // Valores por debajo del mínimo
    } else if (value > adequateMax) {
      return AlertType.abnormal;  // Valores por encima del máximo
    } else {
      return AlertType.normal;
    }
  }

  /// Obtiene un mensaje descriptivo del problema
  String getAlertMessage(double value) {
    if (value < adequateMin) {
      return 'VALOR BAJO - ${variable}: ${value.toStringAsFixed(2)} ${unit} (mínimo: ${adequateMin.toStringAsFixed(1)})';
    } else if (value > adequateMax) {
      return 'RANGO ANORMAL - ${variable}: ${value.toStringAsFixed(2)} ${unit} (máximo: ${adequateMax.toStringAsFixed(1)})';
    } else if (value > maximumMax) {
      return 'RANGO CRÍTICO - ${variable}: ${value.toStringAsFixed(2)} ${unit} (límite máximo: ${maximumMax.toStringAsFixed(1)})';
    }
    return 'Valor normal';
  }
}

/// Tipos de alerta del sistema
enum AlertType {
  normal,
  below,      // Nuevo: valor por debajo del rango (amarillo)
  abnormal,   // Valor por encima del rango (rojo)
  critical,   // Valor crítico
}

/// Configuración de rangos para todas las variables del sistema
class SensorRangeConfig {
  static const Map<String, SensorRange> ranges = {
    'v_conv_in': SensorRange(
      variable: 'Voltaje convertidor entrada',
      adequateMin: 8.7,
      adequateMax: 12.3,
      abnormalCondition: 'menor que 8.7 y mayor a 12.3',
      maximumMax: 12.6,
      unit: 'V',
    ),
    'v_conv_out': SensorRange(
      variable: 'Voltaje convertidor salida',
      adequateMin: 11.5,
      adequateMax: 12.5,
      abnormalCondition: 'menor que 11.5 y mayor a 12.5',
      maximumMax: 30.0,
      unit: 'V',
    ),
    'v_cell_1': SensorRange(
      variable: 'Voltaje celda 1',
      adequateMin: 3.6,
      adequateMax: 4.2,
      abnormalCondition: 'menor que 3.6',
      maximumMax: 4.2,
      unit: 'V',
    ),
    'v_cell_2': SensorRange(
      variable: 'Voltaje celda 2',
      adequateMin: 3.6,
      adequateMax: 4.2,
      abnormalCondition: 'menor que 3.6',
      maximumMax: 4.2,
      unit: 'V',
    ),
    'v_cell_3': SensorRange(
      variable: 'Voltaje celda 3',
      adequateMin: 3.6,
      adequateMax: 4.2,
      abnormalCondition: 'menor que 3.6',
      maximumMax: 4.2,
      unit: 'V',
    ),
    'i_circuit': SensorRange(
      variable: 'Corriente de las celdas',
      adequateMin: 3.0,
      adequateMax: 4.0,
      abnormalCondition: 'entre 3 y 4',
      maximumMax: 4.0,
      unit: 'A',
    ),
    'soc_percent': SensorRange(
      variable: 'Salud de la batería',
      adequateMin: 70.0,
      adequateMax: 100.0,
      abnormalCondition: 'menor que 70%',
      maximumMax: 100.0,
      unit: '%',
    ),
    'charge_state': SensorRange(
      variable: 'Estado de carga',
      adequateMin: 0.0,
      adequateMax: 100.0,
      abnormalCondition: 'convertir voltaje de entrada en porcentaje (siendo 12.6 el 100% y 0 el 0%)',
      maximumMax: 100.0,
      unit: '%',
    ),
  };

  /// Obtiene el rango para una variable específica
  static SensorRange? getRangeFor(String variable) {
    return ranges[variable];
  }

  /// Obtiene todas las variables monitoreadas
  static List<String> getAllVariables() {
    return ranges.keys.toList();
  }

  /// Valida todos los valores de un conjunto de datos del sensor
  static List<SensorAlert> validateSensorData(Map<String, double> sensorData) {
    final List<SensorAlert> alerts = [];

    for (final entry in sensorData.entries) {
      final range = getRangeFor(entry.key);
      if (range != null) {
        final alertType = range.getAlertType(entry.value);
        if (alertType != AlertType.normal) {
          alerts.add(
            SensorAlert(
              variable: entry.key,
              value: entry.value,
              alertType: alertType,
              message: range.getAlertMessage(entry.value),
              timestamp: DateTime.now(),
            ),
          );
        }
      }
    }

    return alerts;
  }
}

/// Clase que representa una alerta del sensor
class SensorAlert {
  const SensorAlert({
    required this.variable,
    required this.value,
    required this.alertType,
    required this.message,
    required this.timestamp,
  });

  final String variable;
  final double value;
  final AlertType alertType;
  final String message;
  final DateTime timestamp;

  /// Convierte la alerta a un mapa para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'variable': variable,
      'value': value,
      'alertType': alertType.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Crea una alerta desde un mapa
  factory SensorAlert.fromMap(Map<String, dynamic> map) {
    return SensorAlert(
      variable: map['variable'],
      value: map['value'],
      alertType: AlertType.values.byName(map['alertType']),
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}