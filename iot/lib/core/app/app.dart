import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
import 'package:iot/features/home/presentation/screens/home_screen.dart';
import 'package:iot/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:iot/features/automations/presentation/screens/automations_screen.dart';
import 'package:iot/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:iot/features/history/presentation/screens/history_screen.dart';
import 'package:ui_common/ui_common.dart';

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RoomStateProvider(
      notifier: RoomStateNotifier(),
      child: ScreenUtilInit(
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TheFlutterWay Smart Home Animated App',
            theme: SHTheme.dark,
            initialRoute: '/home',
            routes: {
              '/home': (context) => const HomeScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/automations': (context) => const AutomationsScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/history': (context) => const HistoryScreen(),
            },
          );
        },
      ),
    );
  }
}
