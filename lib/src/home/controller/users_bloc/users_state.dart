part of 'users_bloc.dart';

@immutable
abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<Users> users;

  UsersLoaded(this.users);
}

class UsersOperationSuccess extends UsersState {
  final String message;

  UsersOperationSuccess(this.message);
}

class UsersError extends UsersState {
  final String errorMessage;

  UsersError(this.errorMessage);
}
