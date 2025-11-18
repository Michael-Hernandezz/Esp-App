import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
import 'package:iot/features/home/presentation/screens/home_screen.dart';
import 'package:iot/features/dashboard/presentation/screens/enhanced_dashboard_screen.dart';
import 'package:iot/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:iot/features/settings/presentation/screens/settings_screen.dart';
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
              '/dashboard': (context) => const EnhancedDashboardScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
