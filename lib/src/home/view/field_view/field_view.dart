import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novedades_de_campo/src/home/controller/posts_bloc/posts_bloc.dart';
import 'package:novedades_de_campo/src/home/model/posts_model.dart';
import 'package:novedades_de_campo/src/home/view/field_view/create_image.dart';
import 'package:novedades_de_campo/src/home/view/field_view/post_file_widget.dart';

class FieldView extends StatefulWidget {
  final String yacimiento;
  const FieldView({Key? key, required this.yacimiento}) : super(key: key);

  @override
  FieldViewState createState() => FieldViewState();
}

class FieldViewState extends State<FieldView> {
  Map<String, int> listadoElementos = {};
  @override
  void initState() {
    super.initState();
    BlocProvider.of<PostsBloc>(context).add(LoadPosts(widget.yacimiento));
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

        return Column(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                ...listadoElementos.entries
                    .map((u) => <Widget>[
                          Row(
                            children: [
                              Text(u.key),
                              SizedBox(
                                width: 10,
                              ),
                              Text(u.value.toString()),
                            ],
                          )
                        ])
                    .expand((element) => element)
                    .toList(),
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  return PostTile(
                      post: Posts(
                    imgURL: state.posts[index].imgURL,
                    description: state.posts[index].description,
                    location: state.posts[index].location,
                    id: state.posts[index].id,
                    name: state.posts[index].name,
                    lat: state.posts[index].lat,
                    long: state.posts[index].long,
                    uploadedBy: '',
                    category: state.posts[index].category,
                    field: '',
                    date: state.posts[index].date,
                    modifiedBy: '',
                    rescued: state.posts[index].rescued,
                  ));
                },
              ),
            ),
          ],
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
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Row(
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
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateImagePost()));
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
}
