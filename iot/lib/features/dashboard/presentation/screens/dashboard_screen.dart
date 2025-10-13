import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roomStateNotifier = RoomStateProvider.of(context);
    
    return Scaffold(
      backgroundColor: SHColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: SHColors.cardColor,
        foregroundColor: Colors.white,
      ),
      drawer: const SmartHomeDrawer(),
      body: ValueListenableBuilder<List<SmartRoom>>(
        valueListenable: roomStateNotifier!,
        builder: (context, rooms, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(context, rooms),
                const SizedBox(height: 24),
                _buildEnergyConsumption(context),
                const SizedBox(height: 24),
                _buildActiveDevices(context, rooms),
                const SizedBox(height: 24),
                _buildQuickActions(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, List<SmartRoom> rooms) {
    final totalDevices = rooms.length * 4; // lights, music, timer, AC per room
    final activeDevices = rooms.fold(0, (sum, room) {
      int count = 0;
      if (room.lights.isOn) count++;
      if (room.musicInfo.isOn) count++;
      if (room.timer.isOn) count++;
      if (room.airCondition.isOn) count++;
      return sum + count;
    });

    final averageTemp =
        rooms.fold(0.0, (sum, room) => sum + room.temperature) / rooms.length;

    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            title: 'Dispositivos Activos',
            value: '$activeDevices/$totalDevices',
            icon: Icons.devices,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            title: 'Temperatura Promedio',
            value: '${averageTemp.toStringAsFixed(1)}°C',
            icon: Icons.thermostat,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyConsumption(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.electric_bolt, color: Colors.yellow, size: 20),
              SizedBox(width: 8),
              Text(
                'Consumo de Energía',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEnergyItem('Hoy', '12.5 kWh', Colors.blue),
              _buildEnergyItem('Esta semana', '89.2 kWh', Colors.green),
              _buildEnergyItem('Este mes', '345.8 kWh', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyItem(String period, String consumption, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              consumption.split(' ')[0],
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          period,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          consumption,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveDevices(BuildContext context, List<SmartRoom> rooms) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.power_settings_new,
                color: SHColors.selectedColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Dispositivos Encendidos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...rooms.expand((room) => _getActiveDevicesForRoom(room)),
        ],
      ),
    );
  }

  List<Widget> _getActiveDevicesForRoom(SmartRoom room) {
    List<Widget> devices = [];

    if (room.lights.isOn) {
      devices.add(
        _buildDeviceItem(
          '${room.name} - Luces',
          Icons.lightbulb,
          Colors.yellow,
        ),
      );
    }
    if (room.musicInfo.isOn) {
      devices.add(
        _buildDeviceItem(
          '${room.name} - Música',
          Icons.music_note,
          Colors.purple,
        ),
      );
    }
    if (room.timer.isOn) {
      devices.add(
        _buildDeviceItem('${room.name} - Timer', Icons.timer, Colors.blue),
      );
    }
    if (room.airCondition.isOn) {
      devices.add(
        _buildDeviceItem('${room.name} - A/C', Icons.ac_unit, Colors.cyan),
      );
    }

    return devices;
  }

  Widget _buildDeviceItem(String name, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flash_on, color: SHColors.selectedColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Acciones Rápidas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Apagar Todo',
                  Icons.power_off,
                  Colors.red,
                  () => _turnOffAllDevices(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Modo Noche',
                  Icons.nights_stay,
                  Colors.indigo,
                  () => MessageService.showDeviceMessage(
                    context,
                    'Modo noche',
                    true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _turnOffAllDevices(BuildContext context) {
    final roomStateNotifier = RoomStateProvider.of(context);
    final rooms = roomStateNotifier?.value ?? [];

    for (final room in rooms) {
      roomStateNotifier?.updateLightsState(room.id, false);
      roomStateNotifier?.updateMusicState(room.id, false);
      roomStateNotifier?.updateTimerState(room.id, false);
      roomStateNotifier?.updateAirConditionState(room.id, false);
    }

    MessageService.showDeviceMessage(context, 'Todos los dispositivos', false);
  }
}
