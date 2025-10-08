import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thought_box/data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<PasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<ValidationErrorTriggered>(_onValidationErrorTriggered);
    on<ValidationErrorCleared>(_onValidationErrorCleared);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = authRepository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.signIn(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.signUp(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.signOut();
    emit(const AuthUnauthenticated());
  }

  // NEW: Toggle password visibility
  void _onPasswordVisibilityToggled(
    PasswordVisibilityToggled event,
    Emitter<AuthState> emit,
  ) {
    final newObscure = !state.obscurePassword;

    if (state is AuthUnauthenticated) {
      emit(AuthUnauthenticated(
        obscurePassword: newObscure,
        showValidationError: state.showValidationError,
      ));
    } else if (state is AuthError) {
      final currentState = state as AuthError;
      emit(AuthError(
        currentState.message,
        obscurePassword: newObscure,
        showValidationError: state.showValidationError,
      ));
    } else {
      emit(AuthInitial(
        obscurePassword: newObscure,
        showValidationError: state.showValidationError,
      ));
    }
  }

  // NEW: Trigger validation error
  void _onValidationErrorTriggered(
    ValidationErrorTriggered event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthUnauthenticated) {
      emit(AuthUnauthenticated(
        obscurePassword: state.obscurePassword,
        showValidationError: true,
      ));
    } else if (state is AuthError) {
      final currentState = state as AuthError;
      emit(AuthError(
        currentState.message,
        obscurePassword: state.obscurePassword,
        showValidationError: true,
      ));
    } else {
      emit(AuthInitial(
        obscurePassword: state.obscurePassword,
        showValidationError: true,
      ));
    }
  }

  // NEW: Clear validation error
  void _onValidationErrorCleared(
    ValidationErrorCleared event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthUnauthenticated) {
      emit(AuthUnauthenticated(
        obscurePassword: state.obscurePassword,
        showValidationError: false,
      ));
    } else if (state is AuthError) {
      final currentState = state as AuthError;
      emit(AuthError(
        currentState.message,
        obscurePassword: state.obscurePassword,
        showValidationError: false,
      ));
    } else {
      emit(AuthInitial(
        obscurePassword: state.obscurePassword,
        showValidationError: false,
      ));
    }
  }
}