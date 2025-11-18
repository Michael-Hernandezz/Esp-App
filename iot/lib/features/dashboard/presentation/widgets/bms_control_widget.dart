import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
import 'package:iot/core/shared/data/services/actuator_control_service.dart';

class BMSControlWidget extends StatefulWidget {
  final String deviceId;
  final Map<String, int>? initialStates;
  final VoidCallback? onStateChanged;

  const BMSControlWidget({
    super.key,
    required this.deviceId,
    this.initialStates,
    this.onStateChanged,
  });

  @override
  State<BMSControlWidget> createState() => _BMSControlWidgetState();
}

class _BMSControlWidgetState extends State<BMSControlWidget> {
  Map<String, int> _actuatorStates = {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _actuatorStates = widget.initialStates ?? {};
    // Siempre cargar estados desde la API para asegurar sincronización
    _loadActuatorStates();
  }

  Future<void> _loadActuatorStates() async {
    print('🔄 BMSControlWidget: Iniciando carga de estados desde API...');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      print('🔄 BMSControlWidget: Consultando API para deviceId: ${widget.deviceId}');
=======
      print(
        '🔄 BMSControlWidget: Consultando API para deviceId: ${widget.deviceId}',
      );
>>>>>>> Stashed changes
=======
      print(
        '🔄 BMSControlWidget: Consultando API para deviceId: ${widget.deviceId}',
      );
>>>>>>> Stashed changes
      final states = await ActuatorControlService.getActuatorStatus(
        widget.deviceId,
      );
      print('🔄 BMSControlWidget: Respuesta de API: $states');
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      
=======

>>>>>>> Stashed changes
=======

>>>>>>> Stashed changes
      if (states != null) {
        setState(() {
          _actuatorStates = states;
          _isLoading = false;
        });
        print('✅ BMSControlWidget: Estados actualizados: $_actuatorStates');
      } else {
        setState(() {
          _error = 'No se pudieron cargar los estados';
          _isLoading = false;
        });
        print('❌ BMSControlWidget: Error - No se pudieron cargar estados');
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
      print('❌ BMSControlWidget: Excepción al cargar estados: $e');
    }
  }

  Future<void> _toggleActuator(String actuatorId) async {
    final currentState = _actuatorStates[actuatorId] ?? 0;
    final newState = currentState == 1 ? 0 : 1;
    
    print('🎮 BMSControlWidget: Toggle $actuatorId: $currentState → $newState');

    print('🎮 BMSControlWidget: Toggle $actuatorId: $currentState → $newState');

    print('🎮 BMSControlWidget: Toggle $actuatorId: $currentState → $newState');

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;
      print('🎮 BMSControlWidget: Enviando comando para $actuatorId...');

      switch (actuatorId) {
        case 'chg_enable':
          success = await ActuatorControlService.controlCharger(
            widget.deviceId,
            newState == 1,
          );
          break;
        case 'dsg_enable':
          success = await ActuatorControlService.controlDischarger(
            widget.deviceId,
            newState == 1,
          );
          break;
        case 'cp_enable':
          success = await ActuatorControlService.controlChargePump(
            widget.deviceId,
            newState == 1,
          );
          break;
        case 'pmon_enable':
          success = await ActuatorControlService.controlPackMonitoring(
            widget.deviceId,
            newState == 1,
          );
          break;
      }

      print('🎮 BMSControlWidget: Resultado del comando: $success');

      if (success) {
        setState(() {
          _actuatorStates[actuatorId] = newState;
          _isLoading = false;
        });

        widget.onStateChanged?.call();
<<<<<<< Updated upstream
<<<<<<< Updated upstream
        print('✅ BMSControlWidget: Estado local actualizado: $actuatorId = $newState');
=======
        print(
          '✅ BMSControlWidget: Estado local actualizado: $actuatorId = $newState',
        );
>>>>>>> Stashed changes
=======
        print(
          '✅ BMSControlWidget: Estado local actualizado: $actuatorId = $newState',
        );
>>>>>>> Stashed changes

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${ActuatorControlService.actuatorNames[actuatorId]} ${newState == 1 ? "activado" : "desactivado"}',
              ),
              backgroundColor: newState == 1 ? Colors.green : Colors.orange,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cambiar el estado del actuador'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: SHColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Control BMS',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _isLoading ? null : _loadActuatorStates,
                  tooltip: 'Actualizar estados',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading && _actuatorStates.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red[400]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadActuatorStates,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else
              _buildActuatorGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildActuatorGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: ActuatorControlService.actuatorNames.entries.map((entry) {
        final actuatorId = entry.key;
        final actuatorName = entry.value;
        final isActive = (_actuatorStates[actuatorId] ?? 0) == 1;

        return _buildActuatorButton(
          actuatorId: actuatorId,
          name: actuatorName,
          isActive: isActive,
          onTap: () => _toggleActuator(actuatorId),
        );
      }).toList(),
    );
  }

  Widget _buildActuatorButton({
    required String actuatorId,
    required String name,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.green : Colors.grey.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getActuatorIcon(actuatorId),
                color: isActive ? Colors.green : Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isActive ? 'ON' : 'OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActuatorIcon(String actuatorId) {
    switch (actuatorId) {
      case 'chg_enable':
        return Icons.battery_charging_full;
      case 'dsg_enable':
        return Icons.battery_alert;
      case 'cp_enable':
        return Icons.water_drop;
      case 'pmon_enable':
        return Icons.monitor_heart;
      default:
        return Icons.power;
    }
  }
}
