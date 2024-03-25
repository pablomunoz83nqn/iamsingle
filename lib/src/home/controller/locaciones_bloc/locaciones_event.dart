part of 'locaciones_bloc.dart';

@immutable
abstract class LocacionesEvent {}

class LoadLocaciones extends LocacionesEvent {}

class AddLocacion extends LocacionesEvent {
  final Locaciones locaciones;

  AddLocacion(this.locaciones);
}

class UpdateLocacion extends LocacionesEvent {
  final Locaciones locaciones;

  UpdateLocacion(this.locaciones);
}

class DeleteLocacion extends LocacionesEvent {
  final String locacionId;

  DeleteLocacion(this.locacionId);
}
