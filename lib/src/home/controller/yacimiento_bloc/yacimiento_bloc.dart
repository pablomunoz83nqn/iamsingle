import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:novedades_de_campo/src/home/controller/yacimiento_controller.dart';
import 'package:novedades_de_campo/src/home/model/yacimiento_model.dart';

part 'yacimiento_event.dart';
part 'yacimiento_state.dart';

class YacimientoBloc extends Bloc<YacimientoEvent, YacimientoState> {
  final FirestoreServiceYacimiento _firestoreService;

  YacimientoBloc(this._firestoreService) : super(YacimientoInitial()) {
    on<LoadYacimiento>((event, emit) async {
      try {
        emit(YacimientoLoading());
        final todos = await _firestoreService.getYacimientos().first;
        emit(YacimientoLoaded(todos));
      } catch (e) {
        emit(YacimientoError('Failed to load todos.'));
      }
    });

    on<AddYacimiento>((event, emit) async {
      try {
        emit(YacimientoLoading());
        await _firestoreService.addYacimiento(event.yacimiento);
        emit(YacimientoOperationSuccess('Yacimiento added successfully.'));
      } catch (e) {
        emit(YacimientoError('Failed to add todo.'));
      }
    });

    on<UpdateYacimiento>((event, emit) async {
      try {
        emit(YacimientoLoading());
        await _firestoreService.updateYacimiento(event.yacimiento);
        emit(YacimientoOperationSuccess('Yacimiento updated successfully.'));
      } catch (e) {
        emit(YacimientoError('Failed to update todo.'));
      }
    });

    on<DeleteYacimiento>((event, emit) async {
      try {
        emit(YacimientoLoading());
        await _firestoreService.deleteYacimiento(event.yacimientoId);
        emit(YacimientoOperationSuccess('Yacimiento deleted successfully.'));
      } catch (e) {
        emit(YacimientoError('Failed to delete todo.'));
      }
    });
  }
}
