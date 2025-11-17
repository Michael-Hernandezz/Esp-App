import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iot/core/core.dart';
import 'package:iot/core/shared/data/services/actuator_control_service.dart';

class CellVoltageChartWidget extends StatefulWidget {
  final String deviceId;

  const CellVoltageChartWidget({super.key, required this.deviceId});

  @override
  State<CellVoltageChartWidget> createState() => _CellVoltageChartWidgetState();
}

class _CellVoltageChartWidgetState extends State<CellVoltageChartWidget> {
  Map<String, List<TelemetryPoint>> _voltageData = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVoltageData();
  }

  Future<void> _loadVoltageData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ActuatorControlService.getTelemetryData(
        deviceId: widget.deviceId,
        fields: ['v_cell1', 'v_cell2', 'v_cell3'],
        start: '-1h',
      );

      if (data != null) {
        setState(() {
          _voltageData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No se pudieron cargar los datos';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
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
                  'Voltajes de Celdas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadVoltageData,
                  tooltip: 'Actualizar datos',
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 8),
            Text(
              'Error cargando datos',
              style: TextStyle(color: Colors.red[300]),
            ),
            const SizedBox(height: 4),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_voltageData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No hay datos de voltaje disponibles',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[800]!, strokeWidth: 0.5);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: null,
              getTitlesWidget: (double value, TitleMeta meta) {
                // Mostrar solo algunos puntos para evitar sobrecarga
                if (value.toInt() % 5 == 0) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${value.toInt()}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.2,
              reservedSize: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${value.toStringAsFixed(1)}V',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        minY: 3.0,
        maxY: 4.2,
        lineBarsData: _buildLineChartBars(),
      ),
    );
  }

  List<LineChartBarData> _buildLineChartBars() {
    final List<LineChartBarData> bars = [];
    final colors = [Colors.red, Colors.green, Colors.blue];
    final cellNames = ['v_cell1', 'v_cell2', 'v_cell3'];

    for (int i = 0; i < cellNames.length; i++) {
      final cellName = cellNames[i];
      final cellData = _voltageData[cellName];

      if (cellData != null && cellData.isNotEmpty) {
        bars.add(
          LineChartBarData(
            spots: cellData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            color: colors[i],
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 2,
                  color: colors[i],
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        );
      }
    }

    return bars;
  }
}
