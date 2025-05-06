part of 'users_bloc.dart';

@immutable
abstract class UsersEvent {}

class LoadUsersEvent extends UsersEvent {
  LoadUsersEvent();
}

class ActivateRadarEvent extends UsersEvent {}

class DeactivateRadarEvent extends UsersEvent {}

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
