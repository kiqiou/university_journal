import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:university_journal/bloc/user/authentication_user.dart';
import 'package:university_journal/bloc/user/user.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthRepository authRepository;

  AuthenticationBloc({required this.authRepository})
      : super(const AuthenticationState.unknown()) {

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
        emit(AuthenticationState.authenticated(user));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    });
  }

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

  const AuthenticationRegisterRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}
