part of 'users_bloc.dart';

@immutable
abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<Users> users;
  final Users currentUser;

  UsersLoaded({
    required this.users,
    required this.currentUser,
  });
}

class UsersOperationSuccess extends UsersState {
  final String message;

  UsersOperationSuccess(this.message);
}

class UsersError extends UsersState {
  final String errorMessage;

  UsersError(this.errorMessage);
}

class ProfileViewsLoading extends UsersState {}

class ProfileViewsLoaded extends UsersState {
  final List<String> viewers;

  ProfileViewsLoaded(this.viewers);
}

class ProfileViewsError extends UsersState {
  final String message;

  ProfileViewsError(this.message);
}
