import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
import 'package:iot/core/shared/presentation/widgets/smart_home_drawer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<DeviceActivity> _deviceActivities = [
    DeviceActivity(
      id: '1',
      deviceName: 'Living Room - Luces',
      action: 'Encendido',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      room: 'Living Room',
      type: ActivityType.lights,
      energyUsed: 0.5,
    ),
    DeviceActivity(
      id: '2',
      deviceName: 'Cocina - Música',
      action: 'Reproduciendo',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      room: 'Cocina',
      type: ActivityType.music,
      energyUsed: 0.1,
    ),
    DeviceActivity(
      id: '3',
      deviceName: 'Dormitorio - A/C',
      action: 'Apagado',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      room: 'Dormitorio',
      type: ActivityType.airCondition,
      energyUsed: 2.3,
    ),
    DeviceActivity(
      id: '4',
      deviceName: 'Baño - Timer',
      action: 'Finalizado',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      room: 'Baño',
      type: ActivityType.timer,
      energyUsed: 0.0,
    ),
    DeviceActivity(
      id: '5',
      deviceName: 'Living Room - Luces',
      action: 'Apagado',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      room: 'Living Room',
      type: ActivityType.lights,
      energyUsed: 1.2,
    ),
  ];

  final List<EnergyConsumption> _energyHistory = [
    EnergyConsumption(
      date: DateTime.now(),
      totalConsumption: 15.6,
      lightingConsumption: 4.2,
      hvacConsumption: 8.1,
      appliancesConsumption: 3.3,
    ),
    EnergyConsumption(
      date: DateTime.now().subtract(const Duration(days: 1)),
      totalConsumption: 18.3,
      lightingConsumption: 5.1,
      hvacConsumption: 9.8,
      appliancesConsumption: 3.4,
    ),
    EnergyConsumption(
      date: DateTime.now().subtract(const Duration(days: 2)),
      totalConsumption: 12.9,
      lightingConsumption: 3.8,
      hvacConsumption: 6.2,
      appliancesConsumption: 2.9,
    ),
    EnergyConsumption(
      date: DateTime.now().subtract(const Duration(days: 3)),
      totalConsumption: 16.7,
      lightingConsumption: 4.9,
      hvacConsumption: 8.5,
      appliancesConsumption: 3.3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SHColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: SHColors.cardColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: SHColors.selectedColor,
          unselectedLabelColor: Colors.white70,
          indicatorColor: SHColors.selectedColor,
          tabs: const [
            Tab(text: 'Actividad de Dispositivos'),
            Tab(text: 'Consumo de Energía'),
          ],
        ),
      ),
      drawer: const SmartHomeDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDeviceActivityTab(), _buildEnergyConsumptionTab()],
      ),
    );
  }

  Widget _buildDeviceActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivitySummary(),
          const SizedBox(height: 24),
          _buildSectionTitle('Últimas Acciones'),
          const SizedBox(height: 16),
          ..._deviceActivities
              .map((activity) => _buildActivityCard(activity))
              ,
        ],
      ),
    );
  }

  Widget _buildActivitySummary() {
    final todayActivities = _deviceActivities
        .where((a) => _isToday(a.timestamp))
        .length;
    final activeDevices = 3; // Simulated
    final totalEnergyToday = _deviceActivities
        .where((a) => _isToday(a.timestamp))
        .fold(0.0, (sum, a) => sum + a.energyUsed);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de Hoy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Acciones',
                  '$todayActivities',
                  Icons.touch_app,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Dispositivos Activos',
                  '$activeDevices',
                  Icons.devices,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Energía Usada',
                  '${totalEnergyToday.toStringAsFixed(1)} kWh',
                  Icons.electric_bolt,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActivityCard(DeviceActivity activity) {
    final color = _getActivityColor(activity.type);
    final icon = _getActivityIcon(activity.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.deviceName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      _formatTimestamp(activity.timestamp),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        activity.action,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (activity.energyUsed > 0)
                      Text(
                        '${activity.energyUsed.toStringAsFixed(1)} kWh',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyConsumptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnergyChart(),
          const SizedBox(height: 24),
          _buildSectionTitle('Historial Diario'),
          const SizedBox(height: 16),
          ..._energyHistory
              .map((consumption) => _buildEnergyCard(consumption))
              ,
        ],
      ),
    );
  }

  Widget _buildEnergyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consumo de los Últimos 7 Días',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _energyHistory.take(7).map((consumption) {
                final maxConsumption = _energyHistory
                    .map((e) => e.totalConsumption)
                    .reduce((a, b) => a > b ? a : b);
                final height =
                    (consumption.totalConsumption / maxConsumption) * 120;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      consumption.totalConsumption.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            SHColors.selectedColor,
                            SHColors.selectedColor.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${consumption.date.day}/${consumption.date.month}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyCard(EnergyConsumption consumption) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _formatDate(consumption.date),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${consumption.totalConsumption.toStringAsFixed(1)} kWh',
                style: const TextStyle(
                  color: SHColors.selectedColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildConsumptionBreakdown(
                  'Iluminación',
                  consumption.lightingConsumption,
                  Colors.yellow,
                ),
              ),
              Expanded(
                child: _buildConsumptionBreakdown(
                  'Climatización',
                  consumption.hvacConsumption,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildConsumptionBreakdown(
                  'Electrodomésticos',
                  consumption.appliancesConsumption,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionBreakdown(
    String category,
    double consumption,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${consumption.toStringAsFixed(1)} kWh',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          category,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.lights:
        return Colors.yellow;
      case ActivityType.music:
        return Colors.purple;
      case ActivityType.airCondition:
        return Colors.cyan;
      case ActivityType.timer:
        return Colors.orange;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.lights:
        return Icons.lightbulb;
      case ActivityType.music:
        return Icons.music_note;
      case ActivityType.airCondition:
        return Icons.ac_unit;
      case ActivityType.timer:
        return Icons.timer;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Hoy';
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Ayer';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }
}

enum ActivityType { lights, music, airCondition, timer }

class DeviceActivity {
  final String id;
  final String deviceName;
  final String action;
  final DateTime timestamp;
  final String room;
  final ActivityType type;
  final double energyUsed;

  DeviceActivity({
    required this.id,
    required this.deviceName,
    required this.action,
    required this.timestamp,
    required this.room,
    required this.type,
    required this.energyUsed,
  });
}

class EnergyConsumption {
  final DateTime date;
  final double totalConsumption;
  final double lightingConsumption;
  final double hvacConsumption;
  final double appliancesConsumption;

  EnergyConsumption({
    required this.date,
    required this.totalConsumption,
    required this.lightingConsumption,
    required this.hvacConsumption,
    required this.appliancesConsumption,
  });
}
