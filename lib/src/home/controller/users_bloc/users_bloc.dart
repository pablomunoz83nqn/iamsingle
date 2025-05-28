import 'package:bloc/bloc.dart';
import 'package:loveradar/src/home/controller/users_controller.dart';
import 'package:loveradar/src/home/model/users_model.dart';
import 'package:loveradar/src/home/view/login_register/auth.dart';
import 'package:meta/meta.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final FirestoreServiceUsers _firestoreService;

  UsersBloc(this._firestoreService) : super(UsersInitial()) {
    on<ActivateRadarEvent>((event, emit) async {
      if (state is UsersLoaded) {
        final currentState = state as UsersLoaded;
        final user = currentState.currentUser;

        final now = DateTime.now();
        final until =
            now.add(const Duration(hours: 1)); // Radar activo por 1 hora

        final updatedUser = Users(
          id: user.id,
          radarMood: user.radarMood,
          email: user.email,
          bio: user.bio,
          name: user.name,
          lastName: user.lastName,
          age: user.age,
          birthDate: user.birthDate,
          gender: user.gender,
          profileImages: user.profileImages,
          lat: user.lat,
          long: user.long,
          isPremium: user.isPremium,
          visitedBy: user.visitedBy,
          radarActive: true,
          radarActivatedAt: now,
          radarDeactivatedAt: null,
          radarUntil: until, // NUEVO CAMPO
        );

        await _firestoreService.editUser(updatedUser);

        emit(UsersLoaded(
          users: currentState.users
              .map((u) => u.id == updatedUser.id ? updatedUser : u)
              .toList(),
          currentUser: updatedUser,
        ));
      }
    });

    on<DeactivateRadarEvent>((event, emit) async {
      if (state is UsersLoaded) {
        final currentState = state as UsersLoaded;
        final user = currentState.currentUser;

        final now = DateTime.now();

        final updatedUser = Users(
          radarMood: user.radarMood,
          id: user.id,
          email: user.email,
          bio: user.bio,
          name: user.name,
          lastName: user.lastName,
          age: user.age,
          birthDate: user.birthDate,
          gender: user.gender,
          profileImages: user.profileImages,
          lat: user.lat,
          long: user.long,
          isPremium: user.isPremium,
          visitedBy: user.visitedBy,
          radarActive: false,
          radarActivatedAt: user.radarActivatedAt,
          radarDeactivatedAt: now,
          radarUntil: null,
        );

        await _firestoreService.editUser(updatedUser);

        emit(UsersLoaded(
          users: currentState.users
              .map((u) => u.id == updatedUser.id ? updatedUser : u)
              .toList(),
          currentUser: updatedUser,
        ));
      }
    });
    on<LoadUsersEvent>((event, emit) async {
      try {
        emit(UsersLoading());
        final users = await _firestoreService.getUsers().first;
        final currentEmail = Auth().currentUser?.email;

        final currentUser = users.firstWhere(
          (u) => u.email == currentEmail,
          orElse: () => throw Exception('Current user not found'),
        );

        // Verificamos si radarUntil ya expiró
        if (currentUser.radarActive == true &&
            currentUser.radarUntil != null &&
            currentUser.radarUntil!.isBefore(DateTime.now())) {
          final updatedUser = Users(
            id: currentUser.id,
            radarMood: currentUser.radarMood,
            email: currentUser.email,
            bio: currentUser.bio,
            name: currentUser.name,
            lastName: currentUser.lastName,
            age: currentUser.age,
            birthDate: currentUser.birthDate,
            gender: currentUser.gender,
            profileImages: currentUser.profileImages,
            lat: currentUser.lat,
            long: currentUser.long,
            isPremium: currentUser.isPremium,
            visitedBy: currentUser.visitedBy,
            radarActive: false,
            radarActivatedAt: currentUser.radarActivatedAt,
            radarDeactivatedAt: DateTime.now(),
            radarUntil: null,
          );

          await _firestoreService.editUser(updatedUser);

          emit(UsersLoaded(
              users: users
                  .map((u) => u.id == updatedUser.id ? updatedUser : u)
                  .toList(),
              currentUser: updatedUser));
        } else {
          emit(UsersLoaded(users: users, currentUser: currentUser));
        }
      } catch (e) {
        emit(UsersError(e.toString()));
      }
    });

    on<AddUserEvent>((event, emit) async {
      try {
        emit(UsersLoading());
        await _firestoreService.addUser(event.users);
        emit(UsersOperationSuccess('Users added successfully.'));
        emit(UsersLoading());
        final users = await _firestoreService.getUsers().first;
        final currentEmail = Auth().currentUser?.email;

        final currentUser = users.firstWhere(
          (u) => u.email == currentEmail,
          orElse: () => throw Exception('Current user not found'),
        );

        emit(UsersLoaded(users: users, currentUser: currentUser));
      } catch (e) {
        emit(UsersError('Failed to add todo.'));
      }
    });

    on<UpdateUserEvent>((event, emit) async {
      try {
        emit(UsersLoading());
        await _firestoreService.editUser(event.user);
        emit(UsersOperationSuccess('Users Updated successfully.'));
        emit(UsersLoading());
        final users = await _firestoreService.getUsers().first;
        final currentEmail = Auth().currentUser?.email;

        final currentUser = users.firstWhere(
          (u) => u.email == currentEmail,
          orElse: () => throw Exception('Current user not found'),
        );

        emit(UsersLoaded(users: users, currentUser: currentUser));
      } catch (e) {
        emit(UsersError('Failed to add todo.'));
      }
    });

    on<UpdatePositionEvent>((event, emit) async {
      try {
        emit(UsersLoading());
        await _firestoreService.updatePosition(event.user);
      } catch (e) {
        if (e.toString().contains("not-found")) {
          emit(UsersLoading());
          await _firestoreService.addUser(event.user);
          final users = await _firestoreService.getUsers().first;
          final currentEmail = Auth().currentUser?.email;

          final currentUser = users.firstWhere(
            (u) => u.email == currentEmail,
            orElse: () => throw Exception('Current user not found'),
          );

          emit(UsersLoaded(users: users, currentUser: currentUser));
        } else {
          emit(UsersError('Error en edicion, por favor reinicie la app'));
        }
      }
    });

    on<DeleteUserEvent>(
      (event, emit) async {
        try {
          emit(UsersLoading());
          await _firestoreService.deleteUser(event.postsId);
          emit(UsersOperationSuccess('Users deleted successfully.'));
          emit(UsersLoading());
          final users = await _firestoreService.getUsers().first;
          final currentEmail = Auth().currentUser?.email;

          final currentUser = users.firstWhere(
            (u) => u.email == currentEmail,
            orElse: () => throw Exception('Current user not found'),
          );

          emit(UsersLoaded(users: users, currentUser: currentUser));
        } catch (e) {
          emit(UsersError('Failed to delete todo.'));
        }
      },
    );
  }
}
