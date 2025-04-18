import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_am_single/src/home/controller/yacimiento_bloc/yacimiento_bloc.dart';
import 'package:i_am_single/src/home/model/yacimiento_model.dart';

class SearchScreen extends StatefulWidget {
  Function(String) onApply;
  String selectedYacimiento;
  SearchScreen({
    super.key,
    required this.onApply,
    required this.selectedYacimiento,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();

  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();

  bool emptyYacimiento = false;
  List<Yacimiento> originalYacimientoList = [];

  @override
  void initState() {
    BlocProvider.of<YacimientoBloc>(context).add(LoadYacimiento());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final YacimientoBloc yacimientoBloc =
        BlocProvider.of<YacimientoBloc>(context);
    return BlocBuilder<YacimientoBloc, YacimientoState>(
      builder: (context, state) {
        if (state is YacimientoLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is YacimientoLoaded) {
          originalYacimientoList = state.yacimiento;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(" Yacimiento"),
              const SizedBox(
                height: 2,
              ),
              SizedBox(height: 60, child: _searchBar(originalYacimientoList)),
            ],
          );
        } else if (state is YacimientoOperationSuccess) {
          yacimientoBloc.add(LoadYacimiento()); // Reload todos
          return Container(); // Or display a success message
        } else if (state is YacimientoError) {
          return Center(child: Text(state.errorMessage));
        } else {
          return Container();
        }
      },
    );
  }

  Widget _searchBar(List<Yacimiento> yacimientos) {
    var dropdownValue =
        widget.selectedYacimiento != "" ? widget.selectedYacimiento : "Todos";

    return DropDownSearchFormField(
      suggestionsBoxDecoration: const SuggestionsBoxDecoration(
          elevation: 1, borderRadius: BorderRadius.all(Radius.circular(15))),
      textFieldConfiguration: TextFieldConfiguration(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.0,
              )),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _dropdownSearchFieldController.text = "Todos";
              widget.onApply("");
              setState(() {});
            },
          ),
          prefixIcon: const Icon(Icons.search),
          hintText: dropdownValue == "" ? "Todos" : dropdownValue,
        ),
        controller: _dropdownSearchFieldController,
      ),
      suggestionsCallback: (pattern) {
        return getSuggestions(pattern);
      },
      noItemsFoundBuilder: (context) => Container(
        padding: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height / 5,
        child: const Column(
          children: [
            Text(
              "Sin coincidencias",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
      itemBuilder: (context, Yacimiento? suggestion) {
        Color colorizedSuggesion = _dropdownSearchFieldController.text != ""
            ? suggestion!.name
                    .toLowerCase()
                    .contains(_dropdownSearchFieldController.text)
                ? Colors.orange
                : Colors.black
            : Colors.black;
        return GestureDetector(
          onTap: () {
            print("tap on parent ${suggestion!.name}");

            _dropdownSearchFieldController.text = widget.selectedYacimiento;

            widget.onApply(suggestion.name);

            //suggestionBoxController.close();
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  color: Color(0xffDEDEDE),
                  height: 1,
                ),
                const SizedBox(height: 18.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, left: 5.0),
                  child: Text(
                    suggestion!.name,
                    style: TextStyle(fontSize: 17, color: colorizedSuggesion),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      onSuggestionSelected: (Yacimiento? suggestion) {
        _dropdownSearchFieldController.text = widget.selectedYacimiento;
      },
      suggestionsBoxController: suggestionBoxController,
      onSaved: (value) => widget.selectedYacimiento = value!,
      displayAllSuggestionWhenTap: true,
    );
  }

  List<Yacimiento?> getSuggestions(String query) {
    List<Yacimiento?> matches = [];

    if (query == "") {
      matches = originalYacimientoList;
    } else {
      matches = originalYacimientoList;

      final List<Yacimiento?> suggestions = matches.where((name) {
        final nameTitle = name!.name.toLowerCase();
        final input = query.toLowerCase();

        return nameTitle.contains(input);
      }).toList();

      setState(
        () {
          matches = suggestions;
        },
      );
    }

    return matches;
  }
}
