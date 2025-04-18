import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_am_single/src/home/controller/posts_bloc/posts_bloc.dart';
import 'package:i_am_single/src/home/model/profile_model.dart';

import 'package:i_am_single/src/home/view/field_view/update_profile.dart';
import 'package:i_am_single/src/home/view/field_view/post_file_widget.dart';
import 'package:i_am_single/src/home/view/home_view/search_screen.dart';

class FieldView extends StatefulWidget {
  final Object parametros;

  const FieldView({
    Key? key,
    required this.parametros,
  }) : super(key: key);

  @override
  FieldViewState createState() => FieldViewState();
}

class FieldViewState extends State<FieldView> {
  Map<String, int> listadoElementos = {};
  String sugerencias = "";
  String selectedYacimiento = "";
  late Set parametros;

  late bool rescued;
  @override
  void initState() {
    super.initState();
    parametros = widget.parametros as Set;
    selectedYacimiento = parametros.elementAt(0) as String;
    rescued = parametros.elementAt(1) as bool;
    if (rescued) {
      BlocProvider.of<PostsBloc>(context)
          .add(LoadRescuedPosts(selectedYacimiento));
    } else {
      BlocProvider.of<PostsBloc>(context)
          .add(LoadOnFieldPosts(selectedYacimiento));
    }
  }

  Widget? userPostsList() {
    return BlocBuilder<PostsBloc, PostsState>(builder: (context, state) {
      if (state is PostsLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is PostsLoaded) {
        final List<Map<String, dynamic>> categoryList = [];

        for (var category in state.posts) {
          categoryList.add(category.category);
        }

        Map<String, List<dynamic>> consolidatedMap = {};
        List<Map<String, dynamic>> consolidatedList = [];

        for (Map<String, dynamic> item in categoryList) {
          for (String key in item.keys) {
            if (consolidatedMap[key] == null) {
              consolidatedMap[key] = [item[key]];
            } else {
              (consolidatedMap[key] as List).add(item[key]);
            }
          }
        }

        for (String key in consolidatedMap.keys) {
          consolidatedList.add({key: consolidatedMap[key]!.toSet().toList()});
        }
        listadoElementos.clear();
        for (var element in consolidatedList) {
          var valueInString = element.values.first;
          var key = element.keys;
          var valueInInt = [];
          for (var element in valueInString) {
            valueInInt.add(int.parse(element));
          }
          var result = valueInInt.reduce((sum, element) => sum + element);

          listadoElementos[key.first] = result;
        }

        //NuevoMapa se puede graficar.

        return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              const SliverAppBar(
                backgroundColor: Colors.orange,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Materiales',
                      style: TextStyle(
                        fontSize: 22.0,
                      ),
                    ),
                    Text(
                      ' en campo',
                      style: TextStyle(
                        fontSize: 22.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchScreen(
                  selectedYacimiento:
                      selectedYacimiento == "" ? "" : selectedYacimiento,
                  onApply: (String name) {
                    selectedYacimiento = name;
                    BlocProvider.of<PostsBloc>(context)
                        .add(LoadRescuedPosts(name));
                    BlocProvider.of<PostsBloc>(context)
                        .add(LoadOnFieldPosts(name));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.filter_alt_outlined)),
                    onChanged: (value) {
                      searchItem(value, listadoElementos);
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  itemCount: state.posts.length,
                  itemBuilder: (context, index) {
                    List<bool> listForFilter = state
                        .posts[index].category.entries
                        .map((e) => e.key.contains(sugerencias))
                        .toList();

                    return Visibility(
                      visible: listForFilter.contains(true),
                      child: PostTile(
                          post: Profile(
                        imgURL: state.posts[index].imgURL,
                        description: state.posts[index].description,
                        id: state.posts[index].id,
                        name: state.posts[index].name,
                        lat: state.posts[index].lat,
                        long: state.posts[index].long,
                        uploadedBy: '',
                        category: state.posts[index].category,
                        email: '',
                      )),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      } else {
        return const Center(
            child: Text("No se encuentran registros del yacimiento"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent[100],
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UpdateProfile()));
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text("Nuevo registro"),
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
      body: userPostsList(),
    );
  }

  void searchItem(String query, Map<String, int> listadoElementos) {
    List<String> listado = listadoElementos.entries.map((u) => u.key).toList();
    if (query == "") {
      sugerencias = "";
    } else {
      sugerencias = "";

      final List<String?> suggestions = listado.where((name) {
        final nameTitle = name.toLowerCase();
        final input = query.toLowerCase();

        return nameTitle.contains(input);
      }).toList();

      setState(
        () {
          for (var string in suggestions) {
            sugerencias = string!;
          }
        },
      );
    }
  }
}
