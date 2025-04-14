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

class AddUser extends UsersEvent {
  final Users users;

  AddUser(this.users);
}

class UpdatePosition extends UsersEvent {
  final Users user;

  UpdatePosition(this.user);
}

class DeleteUser extends UsersEvent {
  final String postsId;

  DeleteUser(this.postsId);
}

class LoadProfileViews extends UsersEvent {
  final String email;

  LoadProfileViews(this.email);
}
