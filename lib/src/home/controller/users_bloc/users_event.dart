part of 'users_bloc.dart';

@immutable
abstract class UsersEvent {}

class LoadAllUsers extends UsersEvent {
  String name;

  LoadAllUsers(this.name);
}

class LoadOnFieldUsers extends UsersEvent {
  String name;

  LoadOnFieldUsers(this.name);
}

class UpdateUserEvent extends UsersEvent {
  Users user;

  UpdateUserEvent(this.user);
}

class AddUserEvent extends UsersEvent {
  final Users users;

  AddUserEvent(this.users);
}

class UpdatePositionEvent extends UsersEvent {
  final Users user;

  UpdatePositionEvent(this.user);
}

class DeleteUserEvent extends UsersEvent {
  final String postsId;

  DeleteUserEvent(this.postsId);
}

class LoadProfileViewsEvent extends UsersEvent {
  final String email;

  LoadProfileViewsEvent(this.email);
}
