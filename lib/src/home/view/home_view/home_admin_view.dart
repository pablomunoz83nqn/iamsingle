import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:novedades_de_campo/src/home/controller/field_controller.dart';
import 'package:novedades_de_campo/src/home/controller/field_store.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final CRUDmethods controller;
  late StoreFieldView store;

  @override
  void initState() {
    super.initState();
    getElements();
    store = StoreFieldView();
  }

  bool isLoading = false;

  Future<void> getElements() async {
    isLoading = true;
    QuerySnapshot onfield = await FirebaseFirestore.instance
        .collection('posts')
        .where('rescued', isEqualTo: false)
        .get();
    List<DocumentSnapshot> fieldCount = onfield.docs;

    QuerySnapshot rescued = await FirebaseFirestore.instance
        .collection('posts')
        .where('rescued', isEqualTo: true)
        .get();
    List<DocumentSnapshot> rescuedCount = rescued.docs;

    setState(() {
      store.onFieldNum = fieldCount.length;
      store.rescuedNum = rescuedCount.length;
      isLoading = false;
    }); // Count of Documents in Collection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 31, 56),
        title: Text(widget.title),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 0, 16, 29)),
        child: Column(
          children: [
            Row(
              children: const [],
            ),
            onFieldCard(context),
            pickedMaterialCard(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Agregar nuevo',
        child: const Icon(Icons.add),
      ),
    );
  }

  onFieldCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/field');
      },
      child: SizedBox(
        height: 200,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 20,
              child: Card(
                  shadowColor: Colors.white.withOpacity(0.3),
                  color: Colors.transparent,
                  elevation: 15,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 0, 19, 35),
                          Colors.blueAccent,
                          Colors.blueGrey,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * .8,
                    height: 150,
                  )),
            ),
            const Positioned(
              top: 70,
              left: 60,
              child: Icon(
                Icons.circle,
                size: 75,
                color: Colors.amber,
              ),
            ),
            Positioned(
              left: 150,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            store.onFieldNum.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 40),
                          ),
                    const Text(
                      ' lote/s de materiales en campo',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 70,
              left: MediaQuery.of(context).size.width * .75,
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30)),
                  child: const Icon(
                    Icons.forward_rounded,
                    size: 50,
                    color: Colors.white,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  pickedMaterialCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/store'),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 20,
              child: Card(
                  shadowColor: Colors.white.withOpacity(0.3),
                  color: Colors.transparent,
                  elevation: 15,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 52, 3, 0),
                          Colors.red,
                          Color.fromARGB(255, 121, 24, 24),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * .8,
                    height: 150,
                  )),
            ),
            const Positioned(
              top: 70,
              left: 60,
              child: Icon(
                Icons.circle,
                size: 75,
                color: Colors.amber,
              ),
            ),
            Positioned(
              left: 150,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            store.rescuedNum.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 40),
                          ),
                    const Text(
                      ' lote/s recuperados',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 70,
              left: MediaQuery.of(context).size.width * .75,
              child: Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 195, 177, 40),
                      borderRadius: BorderRadius.circular(30)),
                  child: const Icon(
                    Icons.forward_rounded,
                    size: 50,
                    color: Colors.white,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
