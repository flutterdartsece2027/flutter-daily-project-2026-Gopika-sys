import 'package:flutter/material.dart';

class AppStatusProvider extends ChangeNotifier {
  bool _isTracking = false;
  int _alertCount = 0;

  bool get isTracking => _isTracking;
  int get alertCount => _alertCount;

  void toggleTracking() {
    _isTracking = !_isTracking;
    notifyListeners();
  }

  void incrementAlerts() {
    _alertCount++;
    notifyListeners();
  }
}