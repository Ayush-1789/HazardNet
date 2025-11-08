import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:event_safety_app/models/user_model.dart';
import 'package:event_safety_app/data/services/auth_api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing user authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Uuid _uuid = const Uuid();
  final AuthApiService _authService = AuthApiService();
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
      
      // Check if user is already authenticated via stored token
      final user = await _authService.checkAuthStatus();
      
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }
  
  Future<void> _onSignInWithEmail(
    SignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      // Call backend API for login
      final user = await _authService.login(
        email: event.email,
        password: event.password,
      );
      
      _currentUser = user;
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }
  
  Future<void> _onSignUpWithEmail(
    SignUpWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      // Call backend API for registration
      final user = await _authService.register(
        email: event.email,
        password: event.password,
        displayName: event.displayName ?? event.email.split('@')[0],
        vehicleType: event.vehicleType,
      );
      
      _currentUser = user;
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError('Registration failed: ${e.toString()}'));
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
      
      // Call backend API to logout
      await _authService.logout();
      
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
  
  Future<void> _onIncrementDamageScore(
    IncrementDamageScore event,
    Emitter<AuthState> emit,
  ) async {
    if (_currentUser == null) return;
    
    try {
      final newScore = _currentUser!.cumulativeDamageScore + event.points;
      
      // Update damage score via API
      await _authService.updateDamageScore(newScore);
      
      _currentUser = _currentUser!.copyWith(
        cumulativeDamageScore: newScore,
      );
      
      emit(Authenticated(_currentUser!));
    } catch (e) {
      // If API call fails, emit error but keep current state
      emit(AuthError('Failed to update damage score: ${e.toString()}'));
      if (_currentUser != null) {
        emit(Authenticated(_currentUser!));
      }
    }
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
