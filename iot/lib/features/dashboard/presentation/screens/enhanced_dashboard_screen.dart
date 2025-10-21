import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
import 'package:iot/features/dashboard/presentation/widgets/iot_advanced_chart_widget.dart';
import 'package:iot/features/dashboard/presentation/widgets/iot_alerts_widget.dart';
import 'package:iot/core/shared/data/services/iot_data_service.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  State<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen> {
  Map<String, dynamic> _systemStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSystemStats();
  }

  Future<void> _loadSystemStats() async {
    try {
      final stats = await IoTDataService.getSystemStats();
      setState(() {
        _systemStats = stats;
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
                    'Temperatura',
                    '${(_systemStats['avg_temperature'] ?? 0.0).toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Voltaje',
                    '${(_systemStats['avg_voltage'] ?? 0.0).toStringAsFixed(1)}V',
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
                    'Presión',
                    '${(_systemStats['avg_pressure'] ?? 0.0).toStringAsFixed(1)}Pa',
                    Icons.compress,
                    Colors.purple,
                  ),
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
          measurement: 'temp',
          title: 'Temperatura Ambiente',
          primaryColor: Colors.orange,
          unit: '°C',
          deviceId: 'TEMP-001',
          chartType: IoTChartType.line,
          minThreshold: 15.0,
          maxThreshold: 30.0,
          showRealTimeIndicator: true,
        ),
        const SizedBox(height: 24),
        IoTAdvancedChartWidget(
          measurement: 'v',
          title: 'Voltaje del Sistema',
          primaryColor: Colors.blue,
          unit: 'V',
          deviceId: 'VOLT-001',
          chartType: IoTChartType.line,
          minThreshold: 11.0,
          maxThreshold: 13.0,
          showRealTimeIndicator: true,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: IoTAdvancedChartWidget(
                measurement: 'i',
                title: 'Corriente',
                primaryColor: Colors.amber,
                unit: 'A',
                deviceId: 'AMP-001',
                chartType: IoTChartType.gauge,
                maxThreshold: 5.0,
                showRealTimeIndicator: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: IoTAdvancedChartWidget(
                measurement: 'p',
                title: 'Presión',
                primaryColor: Colors.purple,
                unit: 'kPa',
                deviceId: 'PRES-001',
                chartType: IoTChartType.gauge,
                maxThreshold: 1000.0,
                showRealTimeIndicator: true,
              ),
            ),
          ],
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
