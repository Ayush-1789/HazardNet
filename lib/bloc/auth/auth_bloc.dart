import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:event_safety_app/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing user authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Uuid _uuid = const Uuid();
  UserModel? _currentUser;
  
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithEmail>(_onSignInWithEmail);
    on<SignUpWithEmail>(_onSignUpWithEmail);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignInAnonymously>(_onSignInAnonymously);
    on<SignOut>(_onSignOut);
    on<SendEmailVerification>(_onSendEmailVerification);
    on<SendPasswordResetEmail>(_onSendPasswordResetEmail);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<IncrementDamageScore>(_onIncrementDamageScore);
    on<RecordMaintenanceCheck>(_onRecordMaintenanceCheck);
  }
  
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      // TODO: Check backend auth status (JWT token validation)
      // For MVP, using mock authentication
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (_currentUser != null) {
        emit(Authenticated(_currentUser!));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onSignInWithEmail(
    SignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      // TODO: Implement backend auth sign in (POST /api/auth/login)
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user for MVP
      _currentUser = UserModel(
        id: _uuid.v4(),
        email: event.email,
        displayName: event.email.split('@')[0],
        createdAt: DateTime.now(),
        vehicleType: 'car',
      );
      
      emit(Authenticated(_currentUser!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onSignUpWithEmail(
    SignUpWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      // TODO: Implement backend auth sign up (POST /api/auth/register)
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user for MVP
      _currentUser = UserModel(
        id: _uuid.v4(),
        email: event.email,
        displayName: event.displayName ?? event.email.split('@')[0],
        createdAt: DateTime.now(),
        vehicleType: event.vehicleType,
      );
      
      emit(Authenticated(_currentUser!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      // TODO: Implement Google Sign In
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user
      _currentUser = UserModel(
        id: _uuid.v4(),
        email: 'user@gmail.com',
        displayName: 'Google User',
        createdAt: DateTime.now(),
        vehicleType: 'car',
      );
      
      emit(Authenticated(_currentUser!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onSignInAnonymously(
    SignInAnonymously event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      // TODO: Implement anonymous sign in
      await Future.delayed(const Duration(milliseconds: 500));
      
      _currentUser = UserModel(
        id: _uuid.v4(),
        email: 'anonymous@hazardnet.com',
        displayName: 'Guest User',
        createdAt: DateTime.now(),
        vehicleType: 'car',
      );
      
      emit(Authenticated(_currentUser!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onSignOut(
    SignOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      // TODO: Sign out from Firebase
      await Future.delayed(const Duration(milliseconds: 300));
      
      _currentUser = null;
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onSendEmailVerification(
    SendEmailVerification event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // TODO: Send email verification
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AuthEmailVerificationSent());
      
      if (_currentUser != null) {
        emit(Authenticated(_currentUser!));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onSendPasswordResetEmail(
    SendPasswordResetEmail event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // TODO: Send password reset email
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  void _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<AuthState> emit,
  ) {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      displayName: event.displayName ?? _currentUser!.displayName,
      phoneNumber: event.phoneNumber ?? _currentUser!.phoneNumber,
      photoUrl: event.photoUrl ?? _currentUser!.photoUrl,
      vehicleType: event.vehicleType ?? _currentUser!.vehicleType,
    );
    
    emit(Authenticated(_currentUser!));
  }
  
  void _onIncrementDamageScore(
    IncrementDamageScore event,
    Emitter<AuthState> emit,
  ) {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      cumulativeDamageScore: _currentUser!.cumulativeDamageScore + event.points,
    );
    
    emit(Authenticated(_currentUser!));
  }
  
  void _onRecordMaintenanceCheck(
    RecordMaintenanceCheck event,
    Emitter<AuthState> emit,
  ) {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      lastMaintenanceCheck: DateTime.now(),
      cumulativeDamageScore: 0, // Reset damage score after maintenance
    );
    
    emit(Authenticated(_currentUser!));
  }
}
