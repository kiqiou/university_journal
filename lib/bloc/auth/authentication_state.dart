part of 'authentication_bloc.dart';

enum AuthenticationStatus { authenticated, unauthenticated, unknown }

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final MyUser? user;
  final String? error;

  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user,
    this.error,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(MyUser myUser) :
        this._(status: AuthenticationStatus.authenticated, user: myUser);

  const AuthenticationState.unauthenticated({String? error}) :
        this._(status: AuthenticationStatus.unauthenticated, error: error);

  @override
  List<Object?> get props => [status, user, error];
}