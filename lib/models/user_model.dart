import 'package:equatable/equatable.dart';

/// Model representing app user profile
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final String vehicleType; // car, bike, truck, etc.
  final int cumulativeDamageScore;
  final DateTime createdAt;
  final DateTime? lastMaintenanceCheck;
  final Map<String, dynamic>? driverProfile; // Accelerometer-based driving behavior
  final Map<String, dynamic>? preferences; // Notification preferences, language, etc.
  final bool isPremium; // For future premium features
  final int totalHazardsReported;
  final int verifiedReports;
  
  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.vehicleType = 'car',
    this.cumulativeDamageScore = 0,
    required this.createdAt,
    this.lastMaintenanceCheck,
    this.driverProfile,
    this.preferences,
    this.isPremium = false,
    this.totalHazardsReported = 0,
    this.verifiedReports = 0,
  });
  
  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    phoneNumber,
    photoUrl,
    vehicleType,
    cumulativeDamageScore,
    createdAt,
    lastMaintenanceCheck,
    driverProfile,
    preferences,
    isPremium,
    totalHazardsReported,
    verifiedReports,
  ];
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'phone_number': phoneNumber,
      'photo_url': photoUrl,
      'vehicle_type': vehicleType,
      'cumulative_damage_score': cumulativeDamageScore,
      'created_at': createdAt.toIso8601String(),
      'last_maintenance_check': lastMaintenanceCheck?.toIso8601String(),
      'driver_profile': driverProfile,
      'preferences': preferences,
      'is_premium': isPremium,
      'total_hazards_reported': totalHazardsReported,
      'verified_reports': verifiedReports,
    };
  }
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase (from backend API) and snake_case (from DB)
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      displayName: (json['displayName'] ?? json['display_name'])?.toString(),
      phoneNumber: (json['phoneNumber'] ?? json['phone_number'])?.toString(),
      photoUrl: (json['photoUrl'] ?? json['photo_url'])?.toString(),
      vehicleType: (json['vehicleType'] ?? json['vehicle_type'])?.toString() ?? 'car',
      cumulativeDamageScore: (json['cumulativeDamageScore'] ?? json['cumulative_damage_score'] ?? 0) as int,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse((json['createdAt'] ?? json['created_at']).toString())
          : DateTime.now(),
      lastMaintenanceCheck: json['lastMaintenanceCheck'] != null || json['last_maintenance_check'] != null
          ? DateTime.parse((json['lastMaintenanceCheck'] ?? json['last_maintenance_check']).toString())
          : null,
      driverProfile: (json['driverProfile'] ?? json['driver_profile']) as Map<String, dynamic>?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      isPremium: (json['isPremium'] ?? json['is_premium'] ?? false) as bool,
      totalHazardsReported: (json['totalHazardsReported'] ?? json['total_hazards_reported'] ?? 0) as int,
      verifiedReports: (json['verifiedReports'] ?? json['verified_reports'] ?? 0) as int,
    );
  }
  
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? vehicleType,
    int? cumulativeDamageScore,
    DateTime? createdAt,
    DateTime? lastMaintenanceCheck,
    Map<String, dynamic>? driverProfile,
    Map<String, dynamic>? preferences,
    bool? isPremium,
    int? totalHazardsReported,
    int? verifiedReports,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      cumulativeDamageScore: cumulativeDamageScore ?? this.cumulativeDamageScore,
      createdAt: createdAt ?? this.createdAt,
      lastMaintenanceCheck: lastMaintenanceCheck ?? this.lastMaintenanceCheck,
      driverProfile: driverProfile ?? this.driverProfile,
      preferences: preferences ?? this.preferences,
      isPremium: isPremium ?? this.isPremium,
      totalHazardsReported: totalHazardsReported ?? this.totalHazardsReported,
      verifiedReports: verifiedReports ?? this.verifiedReports,
    );
  }
  
  /// Check if maintenance is recommended based on damage score
  bool get needsMaintenanceCheck {
    return cumulativeDamageScore >= 850;
  }
  
  /// Get damage level description
  String get damageLevel {
    if (cumulativeDamageScore < 300) return 'Excellent';
    if (cumulativeDamageScore < 600) return 'Good';
    if (cumulativeDamageScore < 850) return 'Fair';
    return 'Service Recommended';
  }
}
