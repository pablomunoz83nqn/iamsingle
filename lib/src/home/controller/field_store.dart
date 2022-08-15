class StoreFieldView {
  static final StoreFieldView _singleton = StoreFieldView._();
  factory StoreFieldView() => _singleton;
  StoreFieldView._();

  int onFieldNum = 0;
  int rescuedNum = 0;

  void reset() {
    onFieldNum = 0;
    rescuedNum = 0;
  }
}
