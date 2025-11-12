import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';
import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/models/sensor_data_model.dart';

/// Service for monitoring gyroscope/accelerometer and detecting impacts.
class GyroMonitorService {
  GyroMonitorService();

  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  
  final StreamController<SensorDataModel> _impactController =
      StreamController<SensorDataModel>.broadcast();
  
  DateTime? _lastTriggerTime;
  GyroscopeData? _lastGyroData;
  AccelerometerData? _lastAccelData;

  /// Stream of detected impacts (gyro triggers).
  Stream<SensorDataModel> get impactStream => _impactController.stream;

  /// Start monitoring sensors for impact detection.
  void startMonitoring() {
    // Listen to gyroscope events
    _gyroSubscription = gyroscopeEventStream().listen((event) {
      _lastGyroData = GyroscopeData(
        x: event.x,
        y: event.y,
        z: event.z,
      );
      _checkForImpact();
    });

    // Listen to accelerometer events (optional: for additional impact metrics)
    _accelSubscription = accelerometerEventStream().listen((event) {
      _lastAccelData = AccelerometerData(
        x: event.x,
        y: event.y,
        z: event.z,
      );
    });
  }

  /// Stop monitoring sensors.
  void stopMonitoring() {
    _gyroSubscription?.cancel();
    _gyroSubscription = null;
    _accelSubscription?.cancel();
    _accelSubscription = null;
  }

  void _checkForImpact() {
    final gyro = _lastGyroData;
    if (gyro == null) {
      return;
    }

    // Calculate gyroscope magnitude (rad/s)
    final magnitude = math.sqrt(gyro.x * gyro.x + gyro.y * gyro.y + gyro.z * gyro.z);

    // Check if magnitude exceeds threshold
    if (magnitude < AppConstants.gyroscopeImpactThresholdRadPerSec) {
      return;
    }

    // Check cooldown period to avoid spamming triggers
    final now = DateTime.now();
    if (_lastTriggerTime != null) {
      final cooldown = Duration(seconds: AppConstants.gyroTriggerCooldownSeconds);
      if (now.difference(_lastTriggerTime!) < cooldown) {
        return;
      }
    }

    _lastTriggerTime = now;

    // Emit impact event
    final sensorData = SensorDataModel(
      timestamp: now,
      gyroscope: gyro,
      accelerometer: _lastAccelData,
      impactMagnitude: magnitude,
      isPotentialImpact: true,
    );

    _impactController.add(sensorData);
  }

  void dispose() {
    stopMonitoring();
    _impactController.close();
  }
}
