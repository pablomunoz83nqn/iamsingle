import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:i_am_single/src/home/controller/posts_controller.dart';
import 'package:i_am_single/src/home/model/profile_model.dart';

part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final FirestoreServicePosts _firestoreService;

  PostsBloc(this._firestoreService) : super(PostsInitial()) {
    on<LoadRescuedPosts>((event, emit) async {
      try {
        emit(PostsLoading());
        final posts = await _firestoreService.getPosts(event.name, true).first;
        emit(PostsLoaded(posts));
      } catch (e) {
        emit(PostsError(e.toString()));
      }
    });

    on<LoadOnFieldPosts>((event, emit) async {
      try {
        emit(PostsLoading());
        final posts = await _firestoreService.getPosts(event.name, false).first;
        emit(PostsLoaded(posts));
      } catch (e) {
        emit(PostsError('Failed to load todos.'));
      }
    });

    on<AddPosts>((event, emit) async {
      try {
        emit(PostsLoading());
        await _firestoreService.addPosts(event.posts);
        emit(PostsOperationSuccess('Posts added successfully.'));
        emit(PostsLoading());
        final posts = await _firestoreService.getPosts("", false).first;
        emit(PostsLoaded(posts));
      } catch (e) {
        emit(PostsError('Failed to add todo.'));
      }
    });

    on<UpdatePosts>((event, emit) async {
      try {
        emit(PostsLoading());
        await _firestoreService.updatePosts(event.posts);
        emit(PostsOperationSuccess('Posts updated successfully.'));
        emit(PostsLoading());
        final posts = await _firestoreService.getPosts("", false).first;
        emit(PostsLoaded(posts));
      } catch (e) {
        emit(PostsError('Error en edicion, por favor reinicie la app'));
      }
    });

    on<DeletePosts>((event, emit) async {
      try {
        emit(PostsLoading());
        await _firestoreService.deletePosts(event.postsId);
        emit(PostsOperationSuccess('Posts deleted successfully.'));
        emit(PostsLoading());
        final posts = await _firestoreService.getPosts("", false).first;
        emit(PostsLoaded(posts));
      } catch (e) {
        emit(PostsError('Failed to delete todo.'));
      }
    });
  }
}
