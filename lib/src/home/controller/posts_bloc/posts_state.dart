part of 'posts_bloc.dart';

@immutable
abstract class PostsState {}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  final List<Posts> posts;

  PostsLoaded(this.posts);
}

class PostsOperationSuccess extends PostsState {
  final String message;

  PostsOperationSuccess(this.message);
}

class PostsError extends PostsState {
  final String errorMessage;

  PostsError(this.errorMessage);
}
