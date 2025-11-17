import 'package:iot/core/shared/data/services/influxdb_service.dart';

class IoTSensorData {
  final String deviceId;
  final String roomName;

  // Variables del sistema BMS
  final double? vBatConv; // Voltaje de batería (convertidor)
  final double? vOutConv; // Voltaje de salida (convertidor)
  final double? vCell1; // Voltaje celda 1
  final double? vCell2; // Voltaje celda 2
  final double? vCell3; // Voltaje celda 3
  final double? iCircuit; // Corriente del circuito
  final double? socPercent; // Estado de carga (%)
  final double? sohPercent; // Salud de la batería (%)
  final int? alert; // Alerta (1/0)

  // Estados de actuadores
  final int? chgEnable; // CHG enable (1/0)
  final int? dsgEnable; // DSG enable (1/0)
  final int? cpEnable; // CP enable (1/0)
  final int? pmonEnable; // PMON enable (1/0)

  final String? status;
  final DateTime lastUpdated;

  // Variables legacy para compatibilidad
  @Deprecated('Use vBatConv instead')
  double? get temperature => vBatConv;
  @Deprecated('Use vBatConv instead')
  double? get voltage => vBatConv;
  @Deprecated('Use iCircuit instead')
  double? get current => iCircuit;
  @Deprecated('Use socPercent instead')
  double? get pressure => socPercent;

  IoTSensorData({
    required this.deviceId,
    required this.roomName,
    this.vBatConv,
    this.vOutConv,
    this.vCell1,
    this.vCell2,
    this.vCell3,
    this.iCircuit,
    this.socPercent,
    this.sohPercent,
    this.alert,
    this.chgEnable,
    this.dsgEnable,
    this.cpEnable,
    this.pmonEnable,
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
      vBatConv: readings['v_bat_conv']?.value,
      vOutConv: readings['v_out_conv']?.value,
      vCell1: readings['v_cell1']?.value,
      vCell2: readings['v_cell2']?.value,
      vCell3: readings['v_cell3']?.value,
      iCircuit: readings['i_circuit']?.value,
      socPercent: readings['soc_percent']?.value,
      sohPercent: readings['soh_percent']?.value,
      alert: readings['alert']?.value.toInt(),
      chgEnable: readings['chg_enable']?.value.toInt(),
      dsgEnable: readings['dsg_enable']?.value.toInt(),
      cpEnable: readings['cp_enable']?.value.toInt(),
      pmonEnable: readings['pmon_enable']?.value.toInt(),
      status: readings['status']?.valueAsString,
      lastUpdated: readings.values.isNotEmpty
          ? readings.values.first.timestamp
          : DateTime.now(),
    );
  }

  /// Indica si el dispositivo esta funcional
  bool get isOnline => status?.toLowerCase() == 'ok';

  /// Obtiene el último valor válido
  bool get hasValidData =>
      vBatConv != null ||
      vOutConv != null ||
      iCircuit != null ||
      socPercent != null;

  IoTSensorData copyWith({
    String? deviceId,
    String? roomName,
    double? vBatConv,
    double? vOutConv,
    double? vCell1,
    double? vCell2,
    double? vCell3,
    double? iCircuit,
    double? socPercent,
    double? sohPercent,
    int? alert,
    int? chgEnable,
    int? dsgEnable,
    int? cpEnable,
    int? pmonEnable,
    String? status,
    DateTime? lastUpdated,
  }) {
    return IoTSensorData(
      deviceId: deviceId ?? this.deviceId,
      roomName: roomName ?? this.roomName,
      vBatConv: vBatConv ?? this.vBatConv,
      vOutConv: vOutConv ?? this.vOutConv,
      vCell1: vCell1 ?? this.vCell1,
      vCell2: vCell2 ?? this.vCell2,
      vCell3: vCell3 ?? this.vCell3,
      iCircuit: iCircuit ?? this.iCircuit,
      socPercent: socPercent ?? this.socPercent,
      sohPercent: sohPercent ?? this.sohPercent,
      alert: alert ?? this.alert,
      chgEnable: chgEnable ?? this.chgEnable,
      dsgEnable: dsgEnable ?? this.dsgEnable,
      cpEnable: cpEnable ?? this.cpEnable,
      pmonEnable: pmonEnable ?? this.pmonEnable,
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
      'temperature':
          vBatConv ??
          20.0, // Usar voltaje de batería como "temperatura" para compatibilidad
      'voltage': vBatConv ?? 0.0,
      'current': iCircuit ?? 0.0,
      'pressure': socPercent ?? 0.0, // SOC como "presión"
      'status': status ?? 'unknown',
      'isOnline': isOnline,
      'lights': lights,
      'airCondition': airCondition,
      'timer': timer,
      'musicInfo': musicInfo,
      'lastUpdated': lastUpdated,
      // Nuevos campos BMS
      'vBatConv': vBatConv,
      'vOutConv': vOutConv,
      'vCell1': vCell1,
      'vCell2': vCell2,
      'vCell3': vCell3,
      'iCircuit': iCircuit,
      'socPercent': socPercent,
      'sohPercent': sohPercent,
      'alert': alert,
      'chgEnable': chgEnable,
      'dsgEnable': dsgEnable,
      'cpEnable': cpEnable,
      'pmonEnable': pmonEnable,
    };
  }

  @override
  String toString() {
    return 'IoTSensorData(deviceId: $deviceId, roomName: $roomName, vBat: ${vBatConv}V, vOut: ${vOutConv}V, vCells: [${vCell1}V, ${vCell2}V, ${vCell3}V], current: ${iCircuit}A, SOC: $socPercent%, SOH: $sohPercent%, alert: $alert, actuators: [CHG:$chgEnable, DSG:$dsgEnable, CP:$cpEnable, PMON:$pmonEnable], status: $status, updated: $lastUpdated)';
  }
}
