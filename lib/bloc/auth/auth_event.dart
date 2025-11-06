import 'package:equatable/equatable.dart';

/// Events for Authentication BLoC
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  
  const SignInWithEmail({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object> get props => [email, password];
}

class SignUpWithEmail extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;
  final String vehicleType;
  
  const SignUpWithEmail({
    required this.email,
    required this.password,
    this.displayName,
    this.vehicleType = 'car',
  });
  
  @override
  List<Object?> get props => [email, password, displayName, vehicleType];
}

class SignInWithGoogle extends AuthEvent {}

class SignInAnonymously extends AuthEvent {}

class SignOut extends AuthEvent {}

class SendEmailVerification extends AuthEvent {}

class SendPasswordResetEmail extends AuthEvent {
  final String email;
  
  const SendPasswordResetEmail(this.email);
  
  @override
  List<Object> get props => [email];
}

class UpdateUserProfile extends AuthEvent {
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final String? vehicleType;
  
  const UpdateUserProfile({
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.vehicleType,
  });
  
  @override
  List<Object?> get props => [displayName, phoneNumber, photoUrl, vehicleType];
}

class IncrementDamageScore extends AuthEvent {
  final int points;
  
  const IncrementDamageScore(this.points);
  
  @override
  List<Object> get props => [points];
}

class RecordMaintenanceCheck extends AuthEvent {}
