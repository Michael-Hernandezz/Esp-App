import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../core/theme/sh_colors.dart';

/// Widget avanzado de gráficas para IoT con múltiples tipos de visualización
class IoTAdvancedChartWidget extends StatefulWidget {
  final String measurement;
  final String title;
  final Color primaryColor;
  final String unit;
  final String? deviceId;
  final IoTChartType chartType;
  final double? minThreshold;
  final double? maxThreshold;
  final bool showRealTimeIndicator;

  const IoTAdvancedChartWidget({
    super.key,
    required this.measurement,
    required this.title,
    required this.primaryColor,
    required this.unit,
    this.deviceId,
    this.chartType = IoTChartType.line,
    this.minThreshold,
    this.maxThreshold,
    this.showRealTimeIndicator = true,
  });

  @override
  State<IoTAdvancedChartWidget> createState() => _IoTAdvancedChartWidgetState();
}

class _IoTAdvancedChartWidgetState extends State<IoTAdvancedChartWidget>
    with TickerProviderStateMixin {
  List<IoTDataPoint> _data = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  IoTTimeRange _selectedTimeRange = IoTTimeRange.last6Hours;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _loadData();
    if (widget.showRealTimeIndicator) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Simulando datos IoT más realistas
      _data = _generateIoTData();

      setState(() {
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<IoTDataPoint> _generateIoTData() {
    final random = math.Random();
    final now = DateTime.now();
    final dataPoints = <IoTDataPoint>[];

    final baseValue = widget.measurement == 'temp'
        ? 22.0
        : widget.measurement == 'v'
        ? 12.0
        : 2.5;

    for (int i = 50; i >= 0; i--) {
      final timestamp = now.subtract(Duration(minutes: i * 5));
      double value;

      // Generar datos más realistas según el tipo de sensor
      switch (widget.measurement) {
        case 'temp':
          // Temperatura con patrón diario y variación natural
          final hourOfDay = timestamp.hour;
          final dayPattern = math.sin((hourOfDay - 6) * math.pi / 12) * 5;
          value = baseValue + dayPattern + (random.nextDouble() - 0.5) * 3;
          break;
        case 'v':
          // Voltaje con pequeñas fluctuaciones
          value = baseValue + (random.nextDouble() - 0.5) * 0.5;
          break;
        default:
          value = baseValue + (random.nextDouble() - 0.5) * 2;
      }

      final quality = _getDataQuality(value);
      dataPoints.add(
        IoTDataPoint(timestamp: timestamp, value: value, quality: quality),
      );
    }

    return dataPoints;
  }

  IoTDataQuality _getDataQuality(double value) {
    if (widget.minThreshold != null && value < widget.minThreshold!) {
      return IoTDataQuality.critical;
    }
    if (widget.maxThreshold != null && value > widget.maxThreshold!) {
      return IoTDataQuality.warning;
    }
    return IoTDataQuality.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: SHColors.cardColor, // Fondo oscuro
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: SHColors.cardColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildCurrentValueDisplay(),
              const SizedBox(height: 20),
              _buildTimeRangeSelector(),
              const SizedBox(height: 16),
              SizedBox(height: 250, child: _buildChart()),
              const SizedBox(height: 16),
              _buildStatistics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SHColors.chartPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIconForMeasurement(),
            color: SHColors.chartPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (widget.deviceId != null)
                Text(
                  'Sensor ${widget.deviceId}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        if (widget.showRealTimeIndicator)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(
                    0.3 + _pulseController.value * 0.7,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Actualizar datos',
        ),
      ],
    );
  }

  Widget _buildCurrentValueDisplay() {
    final currentValue = _data.isNotEmpty ? _data.last.value : 0.0;
    final quality = _data.isNotEmpty
        ? _data.last.quality
        : IoTDataQuality.normal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SHColors.chartPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SHColors.chartPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valor Actual',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentValue.toStringAsFixed(1)}${widget.unit}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SHColors.chartPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildQualityIndicator(quality),
        ],
      ),
    );
  }

  Widget _buildQualityIndicator(IoTDataQuality quality) {
    Color color;
    IconData icon;
    String text;

    switch (quality) {
      case IoTDataQuality.critical:
        color = Colors.red;
        icon = Icons.warning;
        text = 'Crítico';
        break;
      case IoTDataQuality.warning:
        color = Colors.orange;
        icon = Icons.error_outline;
        text = 'Alerta';
        break;
      case IoTDataQuality.normal:
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'Normal';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: IoTTimeRange.values.map((range) {
          final isSelected = range == _selectedTimeRange;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(range.label),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedTimeRange = range;
                  });
                  _loadData();
                }
              },
              selectedColor: SHColors.chartPrimary.withOpacity(0.2),
              checkmarkColor: SHColors.chartPrimary,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: SHColors.chartPrimary),
      );
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_data.isEmpty) {
      return _buildEmptyWidget();
    }

    switch (widget.chartType) {
      case IoTChartType.line:
        return _buildLineChart();
      case IoTChartType.bar:
        return _buildBarChart();
      case IoTChartType.gauge:
        return _buildGaugeChart();
    }
  }

  Widget _buildLineChart() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: null,
              verticalInterval: null,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: SHColors.chartGrid.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: SHColors.chartGrid.withOpacity(0.1),
                  strokeWidth: 1,
                );
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
                    if (value.toInt() >= 0 && value.toInt() < _data.length) {
                      final timestamp = _data[value.toInt()].timestamp;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall,
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
                  interval: null,
                  reservedSize: 50,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      '${value.toInt()}${widget.unit}',
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: SHColors.chartPrimary.withOpacity(0.2),
                width: 1,
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: _data.asMap().entries.map((entry) {
                  final animatedValue =
                      entry.value.value * _animationController.value;
                  return FlSpot(entry.key.toDouble(), animatedValue);
                }).toList(),
                isCurved: true,
                color: SHColors.chartPrimary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final quality = _data[index].quality;
                    Color dotColor = SHColors.chartPrimary;
                    if (quality == IoTDataQuality.critical) {
                      dotColor = SHColors.chartError;
                    }
                    if (quality == IoTDataQuality.warning) {
                      dotColor = SHColors.chartWarning;
                    }

                    return FlDotCirclePainter(
                      radius: 4,
                      color: dotColor,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      SHColors.chartPrimary.withOpacity(0.3),
                      SHColors.chartPrimary.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                if (widget.minThreshold != null)
                  HorizontalLine(
                    y: widget.minThreshold!,
                    color: SHColors.chartError.withOpacity(0.8),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                  ),
                if (widget.maxThreshold != null)
                  HorizontalLine(
                    y: widget.maxThreshold!,
                    color: SHColors.chartWarning.withOpacity(0.8),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _data.map((e) => e.value).reduce(math.max) * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < _data.length) {
                  final timestamp = _data[value.toInt()].timestamp;
                  return Text(
                    '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}${widget.unit}');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                color: _getColorForQuality(entry.value.quality),
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGaugeChart() {
    final currentValue = _data.isNotEmpty ? _data.last.value : 0.0;
    final maxValue = widget.maxThreshold ?? 100.0;
    final percentage = (currentValue / maxValue).clamp(0.0, 1.0);

    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 20,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  SHColors.chartPrimary,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentValue.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SHColors.chartPrimary,
                  ),
                ),
                Text(widget.unit, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    if (_data.isEmpty) return const SizedBox.shrink();

    final values = _data.map((e) => e.value).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Promedio',
            avg.toStringAsFixed(1),
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard('Mínimo', min.toStringAsFixed(1), Colors.green),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard('Máximo', max.toStringAsFixed(1), Colors.red),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            '$value${widget.unit}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
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

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No hay datos disponibles',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  IconData _getIconForMeasurement() {
    switch (widget.measurement) {
      case 'temp':
        return Icons.thermostat;
      case 'v':
        return Icons.electrical_services;
      case 'i':
        return Icons.flash_on;
      case 'humidity':
        return Icons.water_drop;
      case 'pressure':
        return Icons.compress;
      default:
        return Icons.sensors;
    }
  }

  Color _getColorForQuality(IoTDataQuality quality) {
    switch (quality) {
      case IoTDataQuality.critical:
        return SHColors.chartError;
      case IoTDataQuality.warning:
        return SHColors.chartWarning;
      case IoTDataQuality.normal:
        return SHColors.chartPrimary;
    }
  }
}

// Modelos de datos
class IoTDataPoint {
  final DateTime timestamp;
  final double value;
  final IoTDataQuality quality;

  IoTDataPoint({
    required this.timestamp,
    required this.value,
    required this.quality,
  });
}

enum IoTDataQuality { normal, warning, critical }

enum IoTChartType { line, bar, gauge }

enum IoTTimeRange {
  last1Hour('1h'),
  last6Hours('6h'),
  last24Hours('24h'),
  last7Days('7d'),
  last30Days('30d');

  const IoTTimeRange(this.label);
  final String label;
}
