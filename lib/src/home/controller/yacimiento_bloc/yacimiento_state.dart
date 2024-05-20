part of 'yacimiento_bloc.dart';

@immutable
abstract class YacimientoState {}

class YacimientoInitial extends YacimientoState {}

class YacimientoLoading extends YacimientoState {}

class YacimientoLoaded extends YacimientoState {
  final List<Yacimiento> yacimiento;

  YacimientoLoaded(this.yacimiento);
}

class YacimientoOperationSuccess extends YacimientoState {
  final String message;

  YacimientoOperationSuccess(this.message);
}

class YacimientoError extends YacimientoState {
  final String errorMessage;

  YacimientoError(this.errorMessage);
}
