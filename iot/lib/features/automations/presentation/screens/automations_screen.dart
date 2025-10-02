import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
import 'package:iot/core/shared/presentation/widgets/smart_home_drawer.dart';

class AutomationsScreen extends StatefulWidget {
  const AutomationsScreen({super.key});

  @override
  State<AutomationsScreen> createState() => _AutomationsScreenState();
}

class _AutomationsScreenState extends State<AutomationsScreen> {
  final List<AutomationRule> _automations = [
    AutomationRule(
      id: '1',
      name: 'Luces nocturnas',
      description: 'Encender luces automáticamente a las 7 PM',
      isActive: true,
      trigger: 'Tiempo: 19:00',
      action: 'Encender luces del living',
      icon: Icons.schedule,
    ),
    AutomationRule(
      id: '2',
      name: 'Modo descanso',
      description: 'Apagar todo a las 11 PM',
      isActive: true,
      trigger: 'Tiempo: 23:00',
      action: 'Apagar todos los dispositivos',
      icon: Icons.bedtime,
    ),
    AutomationRule(
      id: '3',
      name: 'Música matutina',
      description: 'Música relajante por la mañana',
      isActive: false,
      trigger: 'Tiempo: 07:00',
      action: 'Reproducir música en cocina',
      icon: Icons.music_note,
    ),
  ];

  final List<GlobalTimer> _timers = [
    GlobalTimer(
      id: '1',
      name: 'Luces cocina',
      remainingTime: Duration(minutes: 15, seconds: 30),
      totalTime: const Duration(minutes: 30),
      device: 'Cocina - Luces',
      isActive: true,
    ),
    GlobalTimer(
      id: '2',
      name: 'Aire acondicionado',
      remainingTime: Duration(hours: 1, minutes: 45),
      totalTime: const Duration(hours: 2),
      device: 'Living - A/C',
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SHColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Automatizaciones'),
        backgroundColor: SHColors.cardColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAutomationDialog,
          ),
        ],
      ),
      drawer: const SmartHomeDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Temporizadores Activos'),
            const SizedBox(height: 16),
            ..._timers.map((timer) => _buildTimerCard(timer)).toList(),
            const SizedBox(height: 32),
            _buildSectionTitle('Reglas de Automatización'),
            const SizedBox(height: 16),
            ..._automations
                .map((automation) => _buildAutomationCard(automation))
                .toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTimerDialog,
        backgroundColor: SHColors.selectedColor,
        child: const Icon(Icons.timer_outlined),
      ),
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

  Widget _buildTimerCard(GlobalTimer timer) {
    final progress =
        1.0 - (timer.remainingTime.inSeconds / timer.totalTime.inSeconds);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.timer, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      timer.device,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDuration(timer.remainingTime),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'de ${_formatDuration(timer.totalTime)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _cancelTimer(timer.id),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationCard(AutomationRule automation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: automation.isActive
            ? Border.all(color: SHColors.selectedColor.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (automation.isActive
                              ? SHColors.selectedColor
                              : Colors.grey)
                          .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  automation.icon,
                  color: automation.isActive
                      ? SHColors.selectedColor
                      : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      automation.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      automation.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: automation.isActive,
                onChanged: (value) => _toggleAutomation(automation.id, value),
                activeColor: SHColors.selectedColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Disparador: ${automation.trigger}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Acción: ${automation.action}',
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

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }

  void _toggleAutomation(String id, bool isActive) {
    setState(() {
      final automation = _automations.firstWhere((a) => a.id == id);
      automation.isActive = isActive;
    });

    MessageService.showDeviceMessage(
      context,
      'Automatización ${isActive ? 'activada' : 'desactivada'}',
      isActive,
    );
  }

  void _cancelTimer(String id) {
    setState(() {
      _timers.removeWhere((timer) => timer.id == id);
    });

    MessageService.showDeviceMessage(context, 'Temporizador cancelado', false);
  }

  void _showAddAutomationDialog() {
    MessageService.showDeviceMessage(
      context,
      'Función de agregar automatización próximamente',
      true,
    );
  }

  void _showAddTimerDialog() {
    MessageService.showDeviceMessage(
      context,
      'Función de agregar temporizador próximamente',
      true,
    );
  }
}

class AutomationRule {
  final String id;
  final String name;
  final String description;
  bool isActive;
  final String trigger;
  final String action;
  final IconData icon;

  AutomationRule({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.trigger,
    required this.action,
    required this.icon,
  });
}

class GlobalTimer {
  final String id;
  final String name;
  final Duration remainingTime;
  final Duration totalTime;
  final String device;
  final bool isActive;

  GlobalTimer({
    required this.id,
    required this.name,
    required this.remainingTime,
    required this.totalTime,
    required this.device,
    required this.isActive,
  });
}
