import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(errorMsg));
    }
  }

  Future<void> register(String email, String password, String name) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(errorMsg));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      await _authService.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(errorMsg));
    }
  }
}
