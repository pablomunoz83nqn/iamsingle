part of 'locaciones_bloc.dart';

abstract class LocacionesEvent {}

class LoadLocaciones extends LocacionesEvent {
  String name;

  LoadLocaciones(this.name);
}

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
