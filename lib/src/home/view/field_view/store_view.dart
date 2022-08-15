import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:novedades_de_campo/src/home/controller/field_controller.dart';
import 'package:novedades_de_campo/src/home/view/field_view/create_image.dart';
import 'package:novedades_de_campo/src/home/view/field_view/post_file_widget.dart';

class StoreView extends StatefulWidget {
  const StoreView({Key? key}) : super(key: key);

  @override
  _StoreViewState createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  CRUDmethods crudMethods = CRUDmethods();
  CollectionReference userPostSnapshot =
      FirebaseFirestore.instance.collection('posts');

  Widget? userPostsList() {
    return StreamBuilder<QuerySnapshot>(
//Filter in collection only TRUE rescued elements
      stream: userPostSnapshot.where('rescued', isEqualTo: true).snapshots(),
      builder: (context, stream) {
        if (stream.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (stream.hasError) {
          return Center(child: Text(stream.error.toString()));
        }

        QuerySnapshot? querySnapshot = stream.data;

        return Container(
          child: querySnapshot != null
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  itemCount: querySnapshot.size,
                  itemBuilder: (context, index) {
                    return PostTile(
                      //.where('rescued', isEqualTo: false).get()
                      imgURL: querySnapshot.docs[index].get('imgURL'),
                      caption: querySnapshot.docs[index].get('caption'),
                      location: querySnapshot.docs[index].get('location'),
                    );
                  })
              : Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Materiales',
              style: TextStyle(
                fontSize: 22.0,
              ),
            ),
            Text(
              ' recuperados',
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
              label: const Text("Upload your photo"),
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
      body: userPostsList(),
    );
  }
}
