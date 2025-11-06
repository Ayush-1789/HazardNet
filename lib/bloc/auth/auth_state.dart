import 'package:equatable/equatable.dart';
import 'package:event_safety_app/models/user_model.dart';

/// States for Authentication BLoC
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  
  const Authenticated(this.user);
  
  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}

class AuthEmailVerificationSent extends AuthState {}

class AuthPasswordResetSent extends AuthState {}
