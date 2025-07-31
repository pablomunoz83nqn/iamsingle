// generated_list_controller.dart

import 'package:loveradar/src/home/view/edit_profile_view/edit_profile_form.dart';

class GeneratedListController {
  static final GeneratedListController _instance =
      GeneratedListController._internal();

  factory GeneratedListController() => _instance;

  GeneratedListController._internal();

  List<ImageDataProfile> generatedList = [];

  bool hasChanged = false;

  void dispose() {
    generatedList = [];
    hasChanged = false;
  }
}
