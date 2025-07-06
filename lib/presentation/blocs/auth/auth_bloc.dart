import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../domain/repositories/auth_repository.dart';

/// BLoC for handling authentication logic and state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) {
      final userId = authRepository.getCurrentUserId();
      final email = authRepository.getCurrentUserEmail();
      if (userId != null) {
        emit(AuthAuthenticated(userId: userId, email: email));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<AuthSignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signUp(
          email: event.email,
          password: event.password,
        );
        final userId = authRepository.getCurrentUserId();
        final email = authRepository.getCurrentUserEmail();
        if (userId != null) {
          emit(AuthAuthenticated(userId: userId, email: email));
        } else {
          emit(const AuthError('Sign up failed.'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.logIn(
          email: event.email,
          password: event.password,
        );
        final userId = authRepository.getCurrentUserId();
        final email = authRepository.getCurrentUserEmail();
        if (userId != null) {
          emit(AuthAuthenticated(userId: userId, email: email));
        } else {
          emit(const AuthError('Login failed.'));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.logOut();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
