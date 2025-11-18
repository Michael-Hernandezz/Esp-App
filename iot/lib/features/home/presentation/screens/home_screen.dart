import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
import 'package:iot/core/shared/data/services/sensor_alert_service.dart';
import 'package:iot/core/shared/presentation/widgets/sensor_alert_widget.dart';
import 'package:ui_common/ui_common.dart';

import '../widgets/lighted_background.dart';
import '../widgets/page_indicators.dart';
import '../widgets/smart_room_page_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = PageController(viewportFraction: 0.8);
  final ValueNotifier<double> pageNotifier = ValueNotifier(0);
  final ValueNotifier<int> roomSelectorNotifier = ValueNotifier(-1);
  late SensorAlertService _alertService;

  @override
  void initState() {
    controller.addListener(pageListener);
    _alertService = SensorAlertService();
    _alertService.addListener(_onAlertsUpdated);
    // Solo alertas basadas en datos reales cuando se detecten anomalías
    super.initState();
  }

  void _onAlertsUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller
      ..removeListener(pageListener)
      ..dispose();
    _alertService.removeListener(_onAlertsUpdated);
    super.dispose();
  }

  void pageListener() {
    pageNotifier.value = controller.page ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return LightedBackgound(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const ShAppBar(),
        drawer: const SmartHomeDrawer(),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 24),
                  Text("SELECT A ROOM", style: context.bodyLarge),
                  height32,
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                        SmartRoomsPageView(
                          pageNotifier: pageNotifier,
                          roomSelectorNotifier: roomSelectorNotifier,
                          controller: controller,
                        ),
                        Positioned.fill(
                          top: null,
                          child: Column(
                            children: [
                              PageIndicators(
                                roomSelectorNotifier: roomSelectorNotifier,
                                pageNotifier: pageNotifier,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Banner flotante de alertas críticas
              AnimatedBuilder(
                animation: _alertService,
                builder: (context, child) {
                  final criticalAlert = _alertService.activeAlerts
                      .where((alert) => alert.alertType == AlertType.critical || alert.alertType == AlertType.abnormal || alert.alertType == AlertType.below)
                      .isNotEmpty
                      ? _alertService.activeAlerts
                          .where((alert) => alert.alertType == AlertType.critical || alert.alertType == AlertType.abnormal || alert.alertType == AlertType.below)
                          .first
                      : null;
                  
                  if (criticalAlert != null) {
                    return FloatingAlertBanner(
                      alert: criticalAlert,
                      onTap: () {
                        // Navegar al dashboard o mostrar detalles
                        Navigator.of(context).pushNamed('/dashboard');
                      },
                      onDismiss: () {
                        _alertService.dismissAlert(criticalAlert);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
