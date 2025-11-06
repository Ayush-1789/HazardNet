import 'package:equatable/equatable.dart';

/// Model for sensor data from gyroscope and accelerometer
class SensorDataModel extends Equatable {
  final DateTime timestamp;
  final AccelerometerData? accelerometer;
  final GyroscopeData? gyroscope;
  final double? impactMagnitude; // Calculated impact force
  final bool isPotentialImpact; // Whether this reading indicates a pothole hit
  
  const SensorDataModel({
    required this.timestamp,
    this.accelerometer,
    this.gyroscope,
    this.impactMagnitude,
    this.isPotentialImpact = false,
  });
  
  @override
  List<Object?> get props => [
    timestamp,
    accelerometer,
    gyroscope,
    impactMagnitude,
    isPotentialImpact,
  ];
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'accelerometer': accelerometer?.toJson(),
      'gyroscope': gyroscope?.toJson(),
      'impact_magnitude': impactMagnitude,
      'is_potential_impact': isPotentialImpact,
    };
  }
  
  factory SensorDataModel.fromJson(Map<String, dynamic> json) {
    return SensorDataModel(
      timestamp: DateTime.parse(json['timestamp'] as String),
      accelerometer: json['accelerometer'] != null 
          ? AccelerometerData.fromJson(json['accelerometer'] as Map<String, dynamic>)
          : null,
      gyroscope: json['gyroscope'] != null
          ? GyroscopeData.fromJson(json['gyroscope'] as Map<String, dynamic>)
          : null,
      impactMagnitude: json['impact_magnitude'] != null 
          ? (json['impact_magnitude'] as num).toDouble() 
          : null,
      isPotentialImpact: json['is_potential_impact'] as bool? ?? false,
    );
  }
}

/// Accelerometer data (x, y, z axes in m/s²)
class AccelerometerData extends Equatable {
  final double x;
  final double y;
  final double z;
  
  const AccelerometerData({
    required this.x,
    required this.y,
    required this.z,
  });
  
  @override
  List<Object> get props => [x, y, z];
  
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }
  
  factory AccelerometerData.fromJson(Map<String, dynamic> json) {
    return AccelerometerData(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }
  
  /// Calculate magnitude of acceleration vector
  double get magnitude {
    return (x * x + y * y + z * z);
  }
}

/// Gyroscope data (rotation around x, y, z axes in rad/s)
class GyroscopeData extends Equatable {
  final double x;
  final double y;
  final double z;
  
  const GyroscopeData({
    required this.x,
    required this.y,
    required this.z,
  });
  
  @override
  List<Object> get props => [x, y, z];
  
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }
  
  factory GyroscopeData.fromJson(Map<String, dynamic> json) {
    return GyroscopeData(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }
}
