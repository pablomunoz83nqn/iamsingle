import 'package:bloc/bloc.dart';
import 'package:i_am_single/src/home/controller/users_controller.dart';
import 'package:i_am_single/src/home/model/users_model.dart';
import 'package:meta/meta.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final FirestoreServiceUsers _firestoreService;

  UsersBloc(this._firestoreService) : super(UsersInitial()) {
    on<LoadAllUsers>((event, emit) async {
      try {
        emit(UsersLoading());
        final posts = await _firestoreService.getUsers().first;
        emit(UsersLoaded(posts));
      } catch (e) {
        emit(UsersError(e.toString()));
      }
    });

    on<AddUser>((event, emit) async {
      try {
        emit(UsersLoading());
        await _firestoreService.addUser(event.users);
        emit(UsersOperationSuccess('Users added successfully.'));
        emit(UsersLoading());
        final posts = await _firestoreService.getUsers().first;
        emit(UsersLoaded(posts));
      } catch (e) {
        emit(UsersError('Failed to add todo.'));
      }
    });

    on<UpdatePosition>((event, emit) async {
      try {
        emit(UsersLoading());
        await _firestoreService.updatePosition(event.user);
        emit(UsersOperationSuccess('Users updated successfully.'));
        emit(UsersLoading());
        final posts = await _firestoreService.getUsers().first;
        emit(UsersLoaded(posts));
      } catch (e) {
        if (e.toString().contains("not-found")) {
          emit(UsersLoading());
          await _firestoreService.addUser(event.user);
          final posts = await _firestoreService.getUsers().first;
          emit(UsersLoaded(posts));
        } else {
          emit(UsersError('Error en edicion, por favor reinicie la app'));
        }
      }
    });

    on<DeleteUser>((event, emit) async {
      try {
        emit(UsersLoading());
        await _firestoreService.deleteUser(event.postsId);
        emit(UsersOperationSuccess('Users deleted successfully.'));
        emit(UsersLoading());
        final posts = await _firestoreService.getUsers().first;
        emit(UsersLoaded(posts));
      } catch (e) {
        emit(UsersError('Failed to delete todo.'));
      }
    });
  }
}
