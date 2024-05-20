part of 'posts_bloc.dart';

@immutable
abstract class PostsEvent {}

class LoadRescuedPosts extends PostsEvent {
  String name;

  LoadRescuedPosts(this.name);
}

class LoadOnFieldPosts extends PostsEvent {
  String name;

  LoadOnFieldPosts(this.name);
}

class AddPosts extends PostsEvent {
  final Posts posts;

  AddPosts(this.posts);
}

class UpdatePosts extends PostsEvent {
  final Posts posts;

  UpdatePosts(this.posts);
}

class DeletePosts extends PostsEvent {
  final String postsId;

  DeletePosts(this.postsId);
}
