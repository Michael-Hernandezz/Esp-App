import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSystemStats();
  }

  Future<void> _loadSystemStats() async {
    try {
      final stats = await IoTDataService.getSystemStats();
      final iotRooms = await IoTDataService.getRealIoTData();
      setState(() {
        _systemStats = stats;
        _iotRooms = iotRooms;
        _isLoading = false;
      });
    } catch (e) {
      print('Error cargando estadísticas: $e');
      setState(() {
        _isLoading = false;
      });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              roomStateNotifier?.refreshData();
              _loadSystemStats();
            },
            tooltip: 'Actualizar datos',
          ),
        ],
      ),
      drawer: const SmartHomeDrawer(),
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
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del Sistema',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'V. Salida',
                    '${(_systemStats['avg_output_voltage'] ?? 0.0).toStringAsFixed(1)}V',
                    Icons.electrical_services,
                    Colors.blue,
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
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Estado Carga',
                    '${(_systemStats['avg_soc'] ?? 0.0).toStringAsFixed(1)}%',
                    Icons.battery_charging_full,
                    Colors.cyan,
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
                    Colors.purple,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBMSSection() {
    if (_iotRooms.isEmpty) {
      return Card(
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
          deviceId: firstDevice.id,
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
          primaryColor: Colors.green,
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
          primaryColor: Colors.blue,
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
          primaryColor: Colors.amber,
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
          primaryColor: Colors.cyan,
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
          primaryColor: Colors.purple,
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
}
