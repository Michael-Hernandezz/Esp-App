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

    // Determinar el valor base según el tipo de medición
    double baseValue;
    switch (widget.measurement) {
      case 'temp':
        baseValue = 22.0;
        break;
      case 'v':
        baseValue = 12.0;
        break;
      case 'v_bat_conv':
        baseValue = 24.0; // Voltaje típico de batería
        break;
      case 'v_out_conv':
        baseValue = 12.0; // Voltaje típico de salida
        break;
      case 'i_circuit':
        baseValue = 2.5; // Corriente típica
        break;
      default:
        baseValue = widget.minThreshold != null && widget.maxThreshold != null
            ? (widget.minThreshold! + widget.maxThreshold!) / 2
            : 2.5;
    }

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
        case 'v_bat_conv':
        case 'v_out_conv':
          // Voltaje con pequeñas fluctuaciones realistas
          value = baseValue + (random.nextDouble() - 0.5) * 1.0;
          // Asegurar que esté dentro del rango esperado
          if (widget.minThreshold != null && widget.maxThreshold != null) {
            value = value.clamp(widget.minThreshold!, widget.maxThreshold!);
          }
          break;
        case 'i_circuit':
          // Corriente con fluctuaciones
          value = baseValue + (random.nextDouble() - 0.5) * 1.0;
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
          border: Border.all(
            color: widget.primaryColor.withOpacity(0.2),
            width: 1,
          ),
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
            color: widget.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIconForMeasurement(),
            color: widget.primaryColor,
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
                  color: Colors.white,
                ),
              ),
              if (widget.deviceId != null)
                Text(
                  'Sensor ${widget.deviceId}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[300]),
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
                  color: SHColors.chartSecondary.withOpacity(
                    0.3 + _pulseController.value * 0.7,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: SHColors.chartSecondary,
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
        color: SHColors.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.primaryColor.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valor Actual',
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[300],
                  ),
=======
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[300]),
>>>>>>> Stashed changes
=======
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[300]),
>>>>>>> Stashed changes
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentValue.toStringAsFixed(1)}${widget.unit}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
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
              selectedColor: widget.primaryColor.withOpacity(0.2),
              checkmarkColor: widget.primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
      case IoTChartType.pie:
        return _buildPieChart();
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
                  color: Colors.white.withOpacity(0.1),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.white.withOpacity(0.05),
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[300],
                          ),
=======
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[300]),
>>>>>>> Stashed changes
=======
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[300]),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[300],
                      ),
=======
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[300]),
>>>>>>> Stashed changes
=======
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[300]),
>>>>>>> Stashed changes
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: widget.primaryColor.withOpacity(0.2),
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
                color: widget.primaryColor,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final quality = _data[index].quality;
                    Color dotColor = widget.primaryColor;
                    if (quality == IoTDataQuality.critical) {
                      dotColor = SHColors.chartWarning;
                    }
                    if (quality == IoTDataQuality.warning) {
                      dotColor = SHColors.chartAccent;
                    }

                    return FlDotCirclePainter(
                      radius: 4,
                      color: dotColor,
                      strokeWidth: 2,
                      strokeColor: SHColors.cardColor,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      widget.primaryColor.withOpacity(0.15),
                      widget.primaryColor.withOpacity(0.02),
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
                    color: SHColors.chartWarning.withOpacity(0.8),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                  ),
                if (widget.maxThreshold != null)
                  HorizontalLine(
                    y: widget.maxThreshold!,
                    color: SHColors.chartAccent.withOpacity(0.8),
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
                valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentValue.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
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

  Widget _buildPieChart() {
    if (_data.isEmpty) return const SizedBox.shrink();

    final currentValue = _data.last.value;
    final maxValue = widget.maxThreshold ?? 100.0;
    final minValue = widget.minThreshold ?? 0.0;
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    
    // Calcular porcentaje del valor actual
    final normalizedValue = ((currentValue - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
=======
=======
>>>>>>> Stashed changes

    // Calcular porcentaje del valor actual
    final normalizedValue = ((currentValue - minValue) / (maxValue - minValue))
        .clamp(0.0, 1.0);
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    final currentPercentage = normalizedValue * 100;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Gauge completamente personalizado sin elementos adicionales
              SizedBox(
                height: 200,
                width: 280,
                child: CustomPaint(
                  painter: CleanGaugePainter(
                    value: normalizedValue * _animationController.value,
                    minValue: minValue,
                    maxValue: maxValue,
                    currentValue: currentValue,
                    unit: widget.unit,
                  ),
                ),
              ),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
              
              const SizedBox(height: 24),
              
              // Valor principal destacado
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
=======
=======
>>>>>>> Stashed changes

              const SizedBox(height: 24),

              // Valor principal destacado
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getGaugeColor(normalizedValue),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getGaugeColor(normalizedValue).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currentValue.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: _getGaugeColor(normalizedValue),
                        letterSpacing: -2,
                        shadows: [
                          Shadow(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                            color: _getGaugeColor(normalizedValue).withOpacity(0.5),
=======
                            color: _getGaugeColor(
                              normalizedValue,
                            ).withOpacity(0.5),
>>>>>>> Stashed changes
=======
                            color: _getGaugeColor(
                              normalizedValue,
                            ).withOpacity(0.5),
>>>>>>> Stashed changes
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.unit,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _getGaugeColor(normalizedValue).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
              
              const SizedBox(height: 20),
              
=======

              const SizedBox(height: 20),

>>>>>>> Stashed changes
=======

              const SizedBox(height: 20),

>>>>>>> Stashed changes
              // Información del estado y rango
              Row(
                children: [
                  Expanded(
                    child: Container(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
=======
=======
>>>>>>> Stashed changes
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF30363D),
                          width: 1,
                        ),
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
                          Text(
                            'Estado',
                            style: const TextStyle(
                              color: Color(0xFFA5A5A5),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStatusText(currentValue, minValue, maxValue),
                            style: TextStyle(
                              color: _getGaugeColor(normalizedValue),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                                  color: _getGaugeColor(normalizedValue).withOpacity(0.3),
=======
                                  color: _getGaugeColor(
                                    normalizedValue,
                                  ).withOpacity(0.3),
>>>>>>> Stashed changes
=======
                                  color: _getGaugeColor(
                                    normalizedValue,
                                  ).withOpacity(0.3),
>>>>>>> Stashed changes
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
=======
=======
>>>>>>> Stashed changes
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF30363D),
                          width: 1,
                        ),
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
                          Text(
                            'Progreso',
                            style: const TextStyle(
                              color: Color(0xFFA5A5A5),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currentPercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: _getGaugeColor(normalizedValue),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                                  color: _getGaugeColor(normalizedValue).withOpacity(0.3),
=======
                                  color: _getGaugeColor(
                                    normalizedValue,
                                  ).withOpacity(0.3),
>>>>>>> Stashed changes
=======
                                  color: _getGaugeColor(
                                    normalizedValue,
                                  ).withOpacity(0.3),
>>>>>>> Stashed changes
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getGaugeColor(double normalizedValue) {
    if (normalizedValue < 0.2) return const Color(0xFFFF4444); // Rojo
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    if (normalizedValue < 0.4) return const Color(0xFFFF8800); // Naranja  
=======
    if (normalizedValue < 0.4) return const Color(0xFFFF8800); // Naranja
>>>>>>> Stashed changes
=======
    if (normalizedValue < 0.4) return const Color(0xFFFF8800); // Naranja
>>>>>>> Stashed changes
    if (normalizedValue < 0.7) return const Color(0xFFFFDD00); // Amarillo
    if (normalizedValue < 0.9) return const Color(0xFF88DD00); // Verde claro
    return const Color(0xFF00DD44); // Verde
  }

  Widget _buildStatistics() {
    if (_data.isEmpty) return const SizedBox.shrink();

    // Si es gráfica pie, mostrar información de rango simplificada
    if (widget.chartType == IoTChartType.pie) {
      final currentValue = _data.last.value;
      final maxValue = widget.maxThreshold ?? 100.0;
      final minValue = widget.minThreshold ?? 0.0;
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      
=======

>>>>>>> Stashed changes
=======

>>>>>>> Stashed changes
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1117),
          borderRadius: BorderRadius.circular(12),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
          border: Border.all(
            color: const Color(0xFF21262D),
            width: 1,
          ),
=======
          border: Border.all(color: const Color(0xFF21262D), width: 1),
>>>>>>> Stashed changes
=======
          border: Border.all(color: const Color(0xFF21262D), width: 1),
>>>>>>> Stashed changes
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rango',
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${minValue.toStringAsFixed(0)} - ${maxValue.toStringAsFixed(0)}${widget.unit}',
                  style: const TextStyle(
                    color: Color(0xFFF0F6FC),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
            Container(
              width: 1,
              height: 30,
              color: const Color(0xFF21262D),
            ),
=======
            Container(width: 1, height: 30, color: const Color(0xFF21262D)),
>>>>>>> Stashed changes
=======
            Container(width: 1, height: 30, color: const Color(0xFF21262D)),
>>>>>>> Stashed changes
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Estado',
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(currentValue, minValue, maxValue),
                  style: TextStyle(
                    color: _getStatusColor(currentValue, minValue, maxValue),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Para otros tipos de gráfica, mostrar estadísticas normales
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
          child: _buildStatCard('Máximo', max.toStringAsFixed(1), SHColors.chartWarning),
=======
=======
>>>>>>> Stashed changes
          child: _buildStatCard(
            'Máximo',
            max.toStringAsFixed(1),
            SHColors.chartWarning,
          ),
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
        return SHColors.chartWarning;
      case IoTDataQuality.warning:
        return SHColors.chartAccent;
      case IoTDataQuality.normal:
        return widget.primaryColor;
    }
  }

  String _getStatusText(double value, double min, double max) {
    final percentage = ((value - min) / (max - min)) * 100;
    if (percentage < 20) return 'Bajo';
    if (percentage < 40) return 'Normal';
    if (percentage < 80) return 'Bueno';
    return 'Óptimo';
  }

  Color _getStatusColor(double value, double min, double max) {
    final percentage = ((value - min) / (max - min)) * 100;
    if (percentage < 20) return const Color(0xFFFF6B6B); // Rojo
    if (percentage < 40) return const Color(0xFFFFA726); // Naranja
    if (percentage < 80) return const Color(0xFF00D9FF); // Azul
    return const Color(0xFF4CAF50); // Verde
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

enum IoTChartType { line, bar, gauge, pie }

enum IoTTimeRange {
  last1Hour('1h'),
  last3Hours('3h'),
  last6Hours('6h'),
  last12Hours('12h'),
  last24Hours('24h');

  const IoTTimeRange(this.label);
  final String label;
}

class CleanGaugePainter extends CustomPainter {
  final double value; // 0.0 to 1.0
  final double minValue;
  final double maxValue;
  final double currentValue;
  final String unit;

  CleanGaugePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.currentValue,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.75);
    final radius = math.min(size.width, size.height) * 0.32;

    // Dibujar solo el arco de fondo limpio
    final backgroundPaint = Paint()
      ..color = const Color(0xFF1C2128)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Dibujar segmentos de colores limpios
    final segments = [
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      const Color(0xFFE53E3E), // Rojo 
=======
      const Color(0xFFE53E3E), // Rojo
>>>>>>> Stashed changes
=======
      const Color(0xFFE53E3E), // Rojo
>>>>>>> Stashed changes
      const Color(0xFFFF8C00), // Naranja
      const Color(0xFFECC94B), // Amarillo
      const Color(0xFF68D391), // Verde claro
      const Color(0xFF38A169), // Verde
    ];
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    
=======

>>>>>>> Stashed changes
=======

>>>>>>> Stashed changes
    double startAngle = math.pi;
    const totalAngle = math.pi;

    for (int i = 0; i < segments.length; i++) {
      final segmentAngle = totalAngle / segments.length;
      final paint = Paint()
        ..color = segments[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        false,
        paint,
      );
      startAngle += segmentAngle;
    }

    // Dibujar aguja limpia sin elementos adicionales
    final needleAngle = math.pi + (value * math.pi);
    final needleLength = radius * 0.75;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    // Aguja principal blanca brillante
    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Centro de la aguja
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerPaint);

    // Dibujar etiquetas mínimas y limpias
    _drawCleanLabels(canvas, size, center, radius);
  }

<<<<<<< Updated upstream
<<<<<<< Updated upstream
  void _drawCleanLabels(Canvas canvas, Size size, Offset center, double radius) {
=======
=======
>>>>>>> Stashed changes
  void _drawCleanLabels(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
  ) {
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.8),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    // Solo etiquetas mínima y máxima
    final minPainter = TextPainter(
      text: TextSpan(text: minValue.toInt().toString(), style: textStyle),
      textDirection: TextDirection.ltr,
    );
    minPainter.layout();
    minPainter.paint(canvas, Offset(center.dx - radius - 20, center.dy + 10));

    final maxPainter = TextPainter(
      text: TextSpan(text: maxValue.toInt().toString(), style: textStyle),
      textDirection: TextDirection.ltr,
    );
    maxPainter.layout();
    maxPainter.paint(canvas, Offset(center.dx + radius - 10, center.dy + 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
