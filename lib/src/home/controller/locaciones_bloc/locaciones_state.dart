part of 'locaciones_bloc.dart';

@immutable
abstract class LocacionesState {}

class LocacionesInitial extends LocacionesState {}

class LocacionesLoading extends LocacionesState {}

class LocacionesLoaded extends LocacionesState {
  final List<Locaciones> locaciones;

  LocacionesLoaded(this.locaciones);
}

class LocacionesOperationSuccess extends LocacionesState {
  final String message;

  LocacionesOperationSuccess(this.message);
}

class LocacionesError extends LocacionesState {
  final String errorMessage;

  LocacionesError(this.errorMessage);
}
