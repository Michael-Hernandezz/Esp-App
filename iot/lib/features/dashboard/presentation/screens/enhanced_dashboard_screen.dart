import 'package:flutter/material.dart';
import 'package:iot/core/theme/sh_colors.dart';
import 'package:iot/core/shared/domain/entities/smart_room.dart';
import 'package:iot/core/shared/domain/entities/sensor_range.dart';
import 'package:iot/core/shared/presentation/providers/room_state_provider.dart';
import 'package:iot/core/shared/data/services/sensor_alert_service.dart';
import 'package:iot/core/shared/presentation/widgets/sensor_alert_widget.dart';
import 'package:iot/features/dashboard/presentation/widgets/iot_advanced_chart_widget.dart';
import 'package:iot/features/dashboard/presentation/widgets/iot_alerts_widget.dart';
import 'package:iot/features/dashboard/presentation/widgets/bms_data_widget.dart';
import 'package:iot/features/dashboard/presentation/widgets/bms_control_widget.dart';
import 'package:iot/core/shared/data/services/iot_data_service.dart';
import 'package:iot/core/shared/domain/entities/iot_sensor_data.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  Map<String, dynamic> _systemStats = {};
  List<SmartRoom> _iotRooms = [];
  bool _isLoading = true;
  late SensorAlertService _alertService;

  @override
  void initState() {
    super.initState();
    _alertService = SensorAlertService();
    _alertService.addListener(_onAlertsUpdated);
    // Solo generar alertas cuando se detecten valores reales fuera de rango
    // No iniciar monitoreo automático para evitar alertas aleatorias
    _loadSystemStats();
  }

  void _onAlertsUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSystemStats() async {
    try {
      final stats = await IoTDataService.getSystemStats();
      final iotRooms = await IoTDataService.getRealIoTData();
      if (mounted) {
        setState(() {
          _systemStats = stats;
          _iotRooms = iotRooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando estadísticas: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Valida los datos actuales de los sensores y genera alertas solo si hay anomalías reales
  Future<void> _validateCurrentSensorData() async {
    try {
      // Solo validar si hay datos del sistema cargados
      if (_systemStats.isEmpty) return;
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      
      // Crear mapa con los valores actuales de sensores
      final Map<String, double> sensorValues = {};
      
      // Mapear los datos del sistema a los nombres de variables de rango
      if (_systemStats.containsKey('voltage_in')) {
        sensorValues['v_conv_in'] = (_systemStats['voltage_in'] as num).toDouble();
      }
      if (_systemStats.containsKey('voltage_out')) {
        sensorValues['v_conv_out'] = (_systemStats['voltage_out'] as num).toDouble();
=======
=======
>>>>>>> Stashed changes

      // Crear mapa con los valores actuales de sensores
      final Map<String, double> sensorValues = {};

      // Mapear los datos del sistema a los nombres de variables de rango
      if (_systemStats.containsKey('voltage_in')) {
        sensorValues['v_conv_in'] = (_systemStats['voltage_in'] as num)
            .toDouble();
      }
      if (_systemStats.containsKey('voltage_out')) {
        sensorValues['v_conv_out'] = (_systemStats['voltage_out'] as num)
            .toDouble();
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
      }
      if (_systemStats.containsKey('current')) {
        sensorValues['i_circuit'] = (_systemStats['current'] as num).toDouble();
      }
      if (_systemStats.containsKey('avg_battery_voltage')) {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
        sensorValues['v_cell_1'] = (_systemStats['avg_battery_voltage'] as num).toDouble();
      }
      
=======
=======
>>>>>>> Stashed changes
        sensorValues['v_cell_1'] = (_systemStats['avg_battery_voltage'] as num)
            .toDouble();
      }

<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
      // Validar solo si tenemos datos para validar
      if (sensorValues.isNotEmpty) {
        await _alertService.validateSensorData(sensorValues);
      }
    } catch (e) {
      print('Error validando datos de sensores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomStateNotifier = RoomStateProvider.of(context);

    return Scaffold(
      backgroundColor: SHColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard IoT'),
        backgroundColor: SHColors.cardColor,
        foregroundColor: Colors.white,
<<<<<<< Updated upstream
<<<<<<< Updated upstream
        automaticallyImplyLeading: false, // Esto quita el botón de menú hamburguesa
=======
        automaticallyImplyLeading:
            false, // Esto quita el botón de menú hamburguesa
>>>>>>> Stashed changes
=======
        automaticallyImplyLeading:
            false, // Esto quita el botón de menú hamburguesa
>>>>>>> Stashed changes
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              try {
                // Mostrar indicador de carga
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Actualizando datos...'),
                    duration: Duration(seconds: 1),
                  ),
                );
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                
=======

>>>>>>> Stashed changes
=======

>>>>>>> Stashed changes
                // Actualizar datos en paralelo
                await Future.wait([
                  roomStateNotifier?.refreshData() ?? Future.value(),
                  _loadSystemStats(),
                ]);
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                
                // Validar datos después de la actualización para detectar alertas reales
                await _validateCurrentSensorData();
                
=======
=======
>>>>>>> Stashed changes

                // Validar datos después de la actualización para detectar alertas reales
                await _validateCurrentSensorData();

<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                // Confirmar actualización
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Datos actualizados correctamente'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al actualizar: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            tooltip: 'Actualizar datos en tiempo real',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await roomStateNotifier?.refreshData();
          await _loadSystemStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alertas de rango anormal en tiempo real
              AnimatedBuilder(
                animation: _alertService,
                builder: (context, child) {
                  if (_alertService.hasActiveAlerts) {
                    return Column(
                      children: [
                        AlertListWidget(
                          alerts: _alertService.activeAlerts,
                          onDismissAlert: (alert) {
                            _alertService.dismissAlert(alert);
                          },
                          onDismissAll: () {
                            _alertService.dismissAllAlerts();
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              _buildSystemOverview(),
              const SizedBox(height: 16),
              const IoTAlertsWidget(),
              const SizedBox(height: 24),
              _buildBMSSection(),
              const SizedBox(height: 24),
              _buildSensorCharts(),
              const SizedBox(height: 24),
              _buildDevicesStatus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemOverview() {
    if (_isLoading) {
      return Card(
        color: SHColors.cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      color: SHColors.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Sistema',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(
=======
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
>>>>>>> Stashed changes
=======
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
>>>>>>> Stashed changes
                fontWeight: FontWeight.bold,
                color: SHColors.chartPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Dispositivos Totales',
                    '${_systemStats['total_devices'] ?? 0}',
                    Icons.devices,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Dispositivos Activos',
                    '${_systemStats['active_devices'] ?? 0}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'V. Batería',
                    '${(_systemStats['avg_battery_voltage'] ?? 0.0).toStringAsFixed(1)}V',
                    Icons.battery_full,
                    SHColors.chartSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'V. Salida',
                    '${(_systemStats['avg_output_voltage'] ?? 0.0).toStringAsFixed(1)}V',
                    Icons.electrical_services,
                    SHColors.chartPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Corriente',
                    '${(_systemStats['avg_current'] ?? 0.0).toStringAsFixed(2)}A',
                    Icons.flash_on,
                    SHColors.chartAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Estado Carga',
                    '${(_systemStats['avg_soc'] ?? 0.0).toStringAsFixed(1)}%',
                    Icons.battery_charging_full,
                    SHColors.chartSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Salud Batería',
                    '${(_systemStats['avg_soh'] ?? 0.0).toStringAsFixed(1)}%',
                    Icons.health_and_safety,
                    SHColors.chartWarning,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(), // Espacio vacío para balance
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Estado del Sistema',
                    _systemStats['system_status'] ?? 'unknown',
                    _getStatusColor(_systemStats['system_status']),
                  ),
                ),
              ],
            ),
            if (_systemStats['last_update'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Última actualización: ${_formatDateTime(_systemStats['last_update'])}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SHColors.cardColors[1],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            status.toLowerCase() == 'ok' ? Icons.check_circle : Icons.error,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              Text(
                status.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'ok':
        return SHColors.chartSecondary;
      case 'error':
        return SHColors.chartWarning;
      case 'warning':
        return SHColors.chartAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBMSSection() {
    if (_iotRooms.isEmpty) {
      return Card(
        color: SHColors.cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.battery_unknown, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Sistema BMS No Conectado',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Verifica la conexión del dispositivo',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Usar el primer dispositivo IoT encontrado
    final firstDevice = _iotRooms.first;
    final sensorData = IoTSensorData(
      deviceId: firstDevice.id,
      roomName: firstDevice.name,
      vBatConv: firstDevice.temperature, // Mapeo temporal
      vOutConv: 12.0, // Valor por defecto
      vCell1: 3.7, // Valores simulados
      vCell2: 3.6,
      vCell3: 3.8,
      iCircuit: 2.5,
      socPercent: 75.0,
      sohPercent: 95.0,
      alert: 0,
      chgEnable: 1,
      dsgEnable: 1,
      cpEnable: 0,
      pmonEnable: 1,
      status: 'ok',
      lastUpdated: DateTime.now(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sistema de Gestión de Batería (BMS)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        BMSDataWidget(sensorData: sensorData, onRefresh: _loadSystemStats),
        const SizedBox(height: 16),
        BMSControlWidget(
          deviceId: 'dev-001', // Forzar deviceId correcto para BMS
          initialStates: _extractBMSStatesFromData(),
          onStateChanged: _loadSystemStats,
        ),
      ],
    );
  }

  Widget _buildSensorCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monitoreo IoT en Tiempo Real',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        IoTAdvancedChartWidget(
          measurement: 'v_bat_conv',
          title: 'Voltaje de Batería (Convertidor)',
          primaryColor: SHColors.chartSecondary,
          unit: 'V',
          deviceId: 'dev-001',
          chartType: IoTChartType.line,
          minThreshold: 22.0,
          maxThreshold: 26.0,
          showRealTimeIndicator: true,
        ),
        const SizedBox(height: 24),
        IoTAdvancedChartWidget(
          measurement: 'v_out_conv',
          title: 'Voltaje de Salida (Convertidor)',
          primaryColor: SHColors.chartPrimary,
          unit: 'V',
          deviceId: 'dev-001',
          chartType: IoTChartType.line,
          minThreshold: 11.0,
          maxThreshold: 13.0,
          showRealTimeIndicator: true,
        ),
        const SizedBox(height: 24),
        IoTAdvancedChartWidget(
          measurement: 'i_circuit',
          title: 'Corriente del Circuito',
          primaryColor: SHColors.chartAccent,
          unit: 'A',
          deviceId: 'dev-001',
          chartType: IoTChartType.line,
          maxThreshold: 5.0,
          showRealTimeIndicator: true,
        ),
        const SizedBox(height: 24),
        IoTAdvancedChartWidget(
          measurement: 'soc_percent',
          title: 'Estado de Carga (SOC)',
          primaryColor: SHColors.chartPrimary,
          unit: '%',
          deviceId: 'dev-001',
          chartType: IoTChartType.line,
          minThreshold: 20.0,
          maxThreshold: 100.0,
          showRealTimeIndicator: true,
        ),
        const SizedBox(height: 24),
        IoTAdvancedChartWidget(
          measurement: 'soh_percent',
          title: 'Salud de la Batería (SOH)',
          primaryColor: SHColors.chartWarning,
          unit: '%',
          deviceId: 'dev-001',
          chartType: IoTChartType.line,
          minThreshold: 80.0,
          maxThreshold: 100.0,
          showRealTimeIndicator: true,
        ),
      ],
    );
  }

  Widget _buildDevicesStatus() {
    return ValueListenableBuilder<List<SmartRoom>>(
      valueListenable: RoomStateProvider.of(context)!,
      builder: (context, rooms, _) {
        return Card(
          color: SHColors.cardColor,
          elevation: 4,
<<<<<<< Updated upstream
<<<<<<< Updated upstream
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
=======
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
>>>>>>> Stashed changes
=======
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
>>>>>>> Stashed changes
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de Habitaciones',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...rooms.map((room) => _buildRoomStatusItem(room)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomStatusItem(SmartRoom room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SHColors.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              room.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[800],
                  child: const Icon(Icons.home, color: Colors.white54),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${room.temperature.toStringAsFixed(1)}°C • ${room.airHumidity.toStringAsFixed(0)}% humedad',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildDeviceIndicator(room.lights.isOn, 'Luces'),
              const SizedBox(height: 4),
              _buildDeviceIndicator(room.airCondition.isOn, 'A/C'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceIndicator(bool isOn, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOn ? Colors.green : Colors.grey[600],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Extrae los estados BMS desde los datos de sistema cargados
  Map<String, int> _extractBMSStatesFromData() {
    final Map<String, int> bmsStates = {};
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    
    // Buscar en los datos de sistema los estados BMS
    if (_systemStats.containsKey('chg_enable')) {
      bmsStates['chg_enable'] = (_systemStats['chg_enable'] as num?)?.round() ?? 0;
    }
    if (_systemStats.containsKey('dsg_enable')) {
      bmsStates['dsg_enable'] = (_systemStats['dsg_enable'] as num?)?.round() ?? 0;
    }
    if (_systemStats.containsKey('cp_enable')) {
      bmsStates['cp_enable'] = (_systemStats['cp_enable'] as num?)?.round() ?? 0;
    }
    if (_systemStats.containsKey('pmon_enable')) {
      bmsStates['pmon_enable'] = (_systemStats['pmon_enable'] as num?)?.round() ?? 0;
    }
    
=======
=======
>>>>>>> Stashed changes

    // Buscar en los datos de sistema los estados BMS
    if (_systemStats.containsKey('chg_enable')) {
      bmsStates['chg_enable'] =
          (_systemStats['chg_enable'] as num?)?.round() ?? 0;
    }
    if (_systemStats.containsKey('dsg_enable')) {
      bmsStates['dsg_enable'] =
          (_systemStats['dsg_enable'] as num?)?.round() ?? 0;
    }
    if (_systemStats.containsKey('cp_enable')) {
      bmsStates['cp_enable'] =
          (_systemStats['cp_enable'] as num?)?.round() ?? 0;
    }
    if (_systemStats.containsKey('pmon_enable')) {
      bmsStates['pmon_enable'] =
          (_systemStats['pmon_enable'] as num?)?.round() ?? 0;
    }

<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    print('Estados BMS extraídos desde dashboard: $bmsStates');
    return bmsStates;
  }

  @override
  void dispose() {
    _alertService.removeListener(_onAlertsUpdated);
    super.dispose();
  }
}
