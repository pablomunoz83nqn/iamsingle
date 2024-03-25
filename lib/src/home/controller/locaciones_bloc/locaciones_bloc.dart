import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:novedades_de_campo/src/home/controller/locaciones_controller.dart';
import 'package:novedades_de_campo/src/home/model/locaciones_model.dart';

part 'locaciones_event.dart';
part 'locaciones_state.dart';

class LocacionesBloc extends Bloc<LocacionesEvent, LocacionesState> {
  final FirestoreService _firestoreService;

  LocacionesBloc(this._firestoreService) : super(LocacionesInitial()) {
    on<LoadLocaciones>((event, emit) async {
      try {
        emit(LocacionesLoading());
        final todos = await _firestoreService.getLocaciones().first;
        emit(LocacionesLoaded(todos));
      } catch (e) {
        emit(LocacionesError('Failed to load todos.'));
      }
    });

    on<AddLocacion>((event, emit) async {
      try {
        emit(LocacionesLoading());
        await _firestoreService.addLocacion(event.locaciones);
        emit(LocacionesOperationSuccess('Locaciones added successfully.'));
      } catch (e) {
        emit(LocacionesError('Failed to add todo.'));
      }
    });

    on<UpdateLocacion>((event, emit) async {
      try {
        emit(LocacionesLoading());
        await _firestoreService.updateLocacion(event.locaciones);
        emit(LocacionesOperationSuccess('Locaciones updated successfully.'));
      } catch (e) {
        emit(LocacionesError('Failed to update todo.'));
      }
    });

    on<DeleteLocacion>((event, emit) async {
      try {
        emit(LocacionesLoading());
        await _firestoreService.deleteLocacion(event.locacionId);
        emit(LocacionesOperationSuccess('Locaciones deleted successfully.'));
      } catch (e) {
        emit(LocacionesError('Failed to delete todo.'));
      }
    });
  }
}
