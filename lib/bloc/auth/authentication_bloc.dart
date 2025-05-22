import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:university_journal/bloc/user/authentication_user.dart';
import 'package:university_journal/bloc/user/user.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthRepository authRepository;

  AuthenticationBloc({required this.authRepository}) : super(const AuthenticationState.unknown()) {

    on<AuthenticationUserChanged>((event, emit) {
      if (event.user != MyUser.empty) {
        emit(AuthenticationState.authenticated(event.user!));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    });

    on<AuthenticationLoginRequested>((event, emit) async {
      final user = await authRepository.login(event.username, event.password);
      if (user != null) {
        print('👤 Пользователь успешно спарсен: $user');
        emit(AuthenticationState.authenticated(user));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    });

    on<AuthenticationRegisterRequested>((event, emit) async {
      final user = await authRepository.signUp(
        username: event.username,
        password: event.password,
        roleId: event.roleId,
        groupId: event.groupId,
        position: event.position,
        bio: event.bio,
      );
      if (user != null) {
        emit(AuthenticationState.authenticated(user));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    });

    on<AuthenticationLogoutRequested>((event, emit) async {
      print('🔄 Выход из аккаунта...');
      await authRepository.logout();
      emit(const AuthenticationState.unauthenticated());
    });

  }
}

class AuthenticationLogoutRequested extends AuthenticationEvent{
}

class AuthenticationLoginRequested extends AuthenticationEvent {
  final String username;
  final String password;

  const AuthenticationLoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class AuthenticationRegisterRequested extends AuthenticationEvent {
  final String username;
  final String password;
  final int roleId;
  final int? groupId;
  final String? position;
  final String? bio;

  const AuthenticationRegisterRequested({
    required this.username,
    required this.password,
    required this.roleId,
    this.groupId,
    this.position,
    this.bio,
  });

  @override
  List<Object> get props => [username, password, roleId];
}
