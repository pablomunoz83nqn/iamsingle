import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_am_single/src/home/controller/locaciones_controller.dart';
import 'package:i_am_single/src/home/model/locaciones_model.dart';

part 'locaciones_event.dart';
part 'locaciones_state.dart';

class LocacionesBloc extends Bloc<LocacionesEvent, LocacionesState> {
  final FirestoreServiceLocaciones _firestoreService;

  LocacionesBloc(this._firestoreService) : super(LocacionesInitial()) {
    on<LoadLocaciones>((event, emit) async {
      try {
        emit(LocacionesLoading());
        final locaciones =
            await _firestoreService.getLocaciones(event.name).first;
        emit(LocacionesLoaded(locaciones));
      } catch (e) {
        emit(LocacionesError('Failed to load locaciones.'));
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
