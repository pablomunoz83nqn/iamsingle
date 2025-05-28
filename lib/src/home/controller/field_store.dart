import 'package:flutter/material.dart';

class StoreFieldView {
  late BuildContext _context;
  int onFieldNum = 0;
  int rescuedNum = 0;
  bool isLoading = false;
  static final StoreFieldView _singleton = StoreFieldView._();

  factory StoreFieldView(BuildContext context) =>
      _singleton._instancia(context);

  StoreFieldView._();

  StoreFieldView _instancia(BuildContext context) {
    _singleton._context = context;

    return _singleton;
  }
}
