import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_session_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final VerifySessionUseCase _verifySessionUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required VerifySessionUseCase verifySessionUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _verifySessionUseCase = verifySessionUseCase,
        _authRepository = authRepository,
        super(const AuthState.initial()) {
    on<AppStartedEvent>(_onAppStarted);
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onAppStarted(
    AppStartedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final sessionResult = await _verifySessionUseCase(const NoParams());
    
    await sessionResult.fold(
      onSuccess: (hasSession) async {
        if (hasSession) {
          final profileResult = await _authRepository.getUserProfile();
          profileResult.fold(
            onSuccess: (profile) {
              final user = User(
                id: profile.id,
                email: profile.email,
                token: '',
              );
              emit(AuthState.authenticated(user: user));
            },
            onError: (failure) {
              emit(const AuthState.unauthenticated());
            },
          );
        } else {
          emit(const AuthState.unauthenticated());
        }
      },
      onError: (failure) async {
        emit(const AuthState.unauthenticated());
      },
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      onSuccess: (user) => emit(AuthState.authenticated(user: user)),
      onError: (failure) => emit(AuthState.error(message: failure.message)),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _registerUseCase(
      RegisterParams(name: event.name, email: event.email, password: event.password),
    );

    result.fold(
      onSuccess: (user) => emit(AuthState.authenticated(user: user)),
      onError: (failure) => emit(AuthState.error(message: failure.message)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _authRepository.logout();
    
    result.fold(
      onSuccess: (_) => emit(const AuthState.unauthenticated()),
      onError: (failure) => emit(AuthState.error(message: failure.message)),
    );
  }
}
