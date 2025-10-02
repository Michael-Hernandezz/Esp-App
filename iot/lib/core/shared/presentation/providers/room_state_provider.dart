import 'package:flutter/material.dart';
import '../providers/room_state_notifier.dart';

class RoomStateProvider extends InheritedNotifier<RoomStateNotifier> {
  const RoomStateProvider({
    required super.notifier,
    required super.child,
    super.key,
  });

  static RoomStateNotifier? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<RoomStateProvider>()
        ?.notifier;
  }
}
