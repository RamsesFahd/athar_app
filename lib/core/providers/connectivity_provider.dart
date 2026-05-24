import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>();

  // Emit current state immediately
  Connectivity().checkConnectivity().then((results) {
    if (!controller.isClosed) {
      controller.add(_isOnline(results));
    }
  });

  final sub = Connectivity().onConnectivityChanged.listen((results) {
    if (!controller.isClosed) {
      controller.add(_isOnline(results));
    }
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});

bool _isOnline(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);
