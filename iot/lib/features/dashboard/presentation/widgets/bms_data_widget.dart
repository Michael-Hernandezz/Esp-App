import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
import 'package:iot/core/shared/domain/entities/iot_sensor_data.dart';

class BMSDataWidget extends StatelessWidget {
  final IoTSensorData sensorData;
  final VoidCallback? onRefresh;

  const BMSDataWidget({super.key, required this.sensorData, this.onRefresh});

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
                  'Datos BMS',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      sensorData.isOnline ? Icons.wifi : Icons.wifi_off,
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                      color: sensorData.isOnline ? SHColors.chartSecondary : SHColors.chartWarning,
=======
                      color: sensorData.isOnline
                          ? SHColors.chartSecondary
                          : SHColors.chartWarning,
>>>>>>> Stashed changes
=======
                      color: sensorData.isOnline
                          ? SHColors.chartSecondary
                          : SHColors.chartWarning,
>>>>>>> Stashed changes
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    if (onRefresh != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: onRefresh,
                        tooltip: 'Actualizar datos',
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Voltajes
            _buildSectionTitle('Voltajes'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDataCard(
                    'Batería (Conv.)',
                    '${sensorData.vBatConv?.toStringAsFixed(2) ?? '--'} V',
                    Icons.battery_full,
                    _getVoltageColor(sensorData.vBatConv, 24.0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDataCard(
                    'Salida (Conv.)',
                    '${sensorData.vOutConv?.toStringAsFixed(2) ?? '--'} V',
                    Icons.electrical_services,
                    _getVoltageColor(sensorData.vOutConv, 12.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Celdas
            _buildSectionTitle('Voltajes de Celdas'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDataCard(
                    'Celda 1',
                    '${sensorData.vCell1?.toStringAsFixed(3) ?? '--'} V',
                    Icons.battery_1_bar,
                    _getCellVoltageColor(sensorData.vCell1),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildDataCard(
                    'Celda 2',
                    '${sensorData.vCell2?.toStringAsFixed(3) ?? '--'} V',
                    Icons.battery_2_bar,
                    _getCellVoltageColor(sensorData.vCell2),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildDataCard(
                    'Celda 3',
                    '${sensorData.vCell3?.toStringAsFixed(3) ?? '--'} V',
                    Icons.battery_3_bar,
                    _getCellVoltageColor(sensorData.vCell3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Corriente y Estados
            Row(
              children: [
                Expanded(
                  child: _buildDataCard(
                    'Corriente',
                    '${sensorData.iCircuit?.toStringAsFixed(2) ?? '--'} A',
                    Icons.flash_on,
                    _getCurrentColor(sensorData.iCircuit),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDataCard(
                    'Alerta',
                    sensorData.alert == 1 ? 'ACTIVA' : 'Normal',
                    sensorData.alert == 1 ? Icons.warning : Icons.check_circle,
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                    sensorData.alert == 1 ? SHColors.chartWarning : SHColors.chartSecondary,
=======
                    sensorData.alert == 1
                        ? SHColors.chartWarning
                        : SHColors.chartSecondary,
>>>>>>> Stashed changes
=======
                    sensorData.alert == 1
                        ? SHColors.chartWarning
                        : SHColors.chartSecondary,
>>>>>>> Stashed changes
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Estado de carga y salud
            Row(
              children: [
                Expanded(
                  child: _buildDataCard(
                    'Estado de Carga',
                    '${sensorData.socPercent?.toStringAsFixed(1) ?? '--'} %',
                    Icons.battery_charging_full,
                    _getSOCColor(sensorData.socPercent),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDataCard(
                    'Salud Batería',
                    '${sensorData.sohPercent?.toStringAsFixed(1) ?? '--'} %',
                    Icons.health_and_safety,
                    _getSOHColor(sensorData.sohPercent),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Timestamp
            Text(
              'Última actualización: ${_formatTimestamp(sensorData.lastUpdated)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDataCard(
    String label,
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getVoltageColor(double? voltage, double nominal) {
    if (voltage == null) return Colors.grey;
    final ratio = voltage / nominal;
    if (ratio > 1.1) return SHColors.chartWarning;
    if (ratio > 0.9) return SHColors.chartSecondary;
    if (ratio > 0.8) return SHColors.chartAccent;
    return SHColors.chartWarning;
  }

  Color _getCellVoltageColor(double? voltage) {
    if (voltage == null) return Colors.grey;
    if (voltage > 4.2) return SHColors.chartWarning;
    if (voltage > 3.2) return SHColors.chartSecondary;
    if (voltage > 3.0) return SHColors.chartAccent;
    return SHColors.chartWarning;
  }

  Color _getCurrentColor(double? current) {
    if (current == null) return Colors.grey;
    if (current.abs() > 5.0) return SHColors.chartWarning;
    if (current.abs() > 2.0) return SHColors.chartAccent;
    return SHColors.chartSecondary;
  }

  Color _getSOCColor(double? soc) {
    if (soc == null) return Colors.grey;
    if (soc > 80) return SHColors.chartSecondary;
    if (soc > 50) return SHColors.chartPrimary;
    if (soc > 20) return SHColors.chartAccent;
    return SHColors.chartWarning;
  }

  Color _getSOHColor(double? soh) {
    if (soh == null) return Colors.grey;
    if (soh > 90) return SHColors.chartSecondary;
    if (soh > 70) return SHColors.chartAccent;
    return SHColors.chartWarning;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Hace ${difference.inSeconds} segundos';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
