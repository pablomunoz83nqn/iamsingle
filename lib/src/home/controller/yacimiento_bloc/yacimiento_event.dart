part of 'yacimiento_bloc.dart';

@immutable
abstract class YacimientoEvent {}

class LoadYacimiento extends YacimientoEvent {}

class AddYacimiento extends YacimientoEvent {
  final Yacimiento yacimiento;

  AddYacimiento(this.yacimiento);
}

class UpdateYacimiento extends YacimientoEvent {
  final Yacimiento yacimiento;

  UpdateYacimiento(this.yacimiento);
}

class DeleteYacimiento extends YacimientoEvent {
  final String yacimientoId;

  DeleteYacimiento(this.yacimientoId);
}
