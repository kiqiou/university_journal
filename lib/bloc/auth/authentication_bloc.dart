import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/user/models/user.dart';
import '../services/user/user_repository.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({required this.userRepository}) : super(const AuthenticationState.unknown()) {

    on<AuthenticationUserChanged>((event, emit) {
      if (event.user != MyUser.empty) {
        emit(AuthenticationState.authenticated(event.user!));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    });

    on<AuthenticationLoginRequested>((event, emit) async {
      final loginSuccess = await userRepository.login(event.username, event.password);

      if (!loginSuccess) {
        emit(const AuthenticationState.unauthenticated());
        return;
      }

      MyUser? user = await userRepository.fetchUser();

      if (user == null) {
        final refreshed = await userRepository.refreshAccessToken();
        if (refreshed) {
          user = await userRepository.fetchUser();
        }
      }

      if (user != null) {
        emit(AuthenticationState.authenticated(user));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    });

    on<AuthenticationRegisterRequested>((event, emit) async {
      final user = await userRepository.signUp(
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
      await userRepository.logout();
      await userRepository.clearTokens();
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
