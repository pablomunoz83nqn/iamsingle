import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novedades_de_campo/src/home/controller/posts_bloc/posts_bloc.dart';
import 'package:novedades_de_campo/src/home/view/field_view/create_image.dart';
import 'package:novedades_de_campo/src/home/view/field_view/post_file_widget.dart';

class FieldView extends StatefulWidget {
  String yacimiento;
  FieldView({Key? key, required this.yacimiento}) : super(key: key);

  @override
  _FieldViewState createState() => _FieldViewState();
}

class _FieldViewState extends State<FieldView> {
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
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          itemCount: state.posts.length,
          itemBuilder: (context, index) {
            return PostTile(
              imgURL: state.posts[index].imgURL,
              description: state.posts[index].description,
              location: state.posts[index].location,
              id: '',
              name: state.posts[index].name,
              lat: state.posts[index].lat,
              long: state.posts[index].long,
              uploadedBy: '',
              category: state.posts[index].category,
              field: '',
              date: '',
              modifiedBy: '',
              rescued: state.posts[index].rescued,
            );
          },
        );
      } else {
        return const Text("Nada cargado");
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
