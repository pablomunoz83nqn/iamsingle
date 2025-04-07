import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:i_am_single/src/home/controller/field_controller.dart';
import 'package:i_am_single/src/home/controller/locaciones_bloc/locaciones_bloc.dart';
import 'package:i_am_single/src/home/controller/yacimiento_bloc/yacimiento_bloc.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  Position? position;
  var selectedYacimiento;
  var selectedLocacion;

  late TextEditingController textController;
  late TextEditingController numTextController;
  final _formKey = GlobalKey<FormState>();

  late File? _myImage = File('');
  late final picker = ImagePicker();

  String caption = '';
  String location = '';
  String name = '';
  String lat = '';
  String long = '';
  String description = '';
  String uploadedBy = '';
  Map<String, dynamic> category = {};
  String field = '';
  String categoria = '';
  String date = '';
  String modifiedBy = '';
  bool rescued = false;

  late String _uploadedImageURL;
  bool _isLoading = false;
  late HomeViewController crudMethods;

  @override
  void initState() {
    textController = TextEditingController();
    numTextController = TextEditingController();
    crudMethods = HomeViewController(context);
    BlocProvider.of<YacimientoBloc>(context).add(LoadYacimiento());
    getCurrentPosition();
    super.initState();
  }

  Future getImage(ImageSource imagesource) async {
    final XFile? pickedImage = await picker.pickImage(source: imagesource);

    setState(() {
      if (pickedImage != null) {
        _myImage = File(pickedImage.path);
      } else {
        debugPrint('No image selected.');
      }
    });
  }

  getCurrentPosition() async {
    Position position = await _determinePosition();

    setState(() {
      position = position;
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
// When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void uploadUserPost() async {
    setState(() {
      _isLoading = true;
      debugPrint('Uploading....');
    });
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('postedImages/${DateTime.now()}.jpg');

    final UploadTask uploadTask = storageRef.putFile(_myImage!);
    await uploadTask.whenComplete(() async {
      debugPrint('File Uploaded');

      final String url = await storageRef.getDownloadURL();
      setState(() {
        _uploadedImageURL = url;
      });
      debugPrint('File URL = $_uploadedImageURL');

      Map<String, dynamic> userPostDetails = {
        "imgURL": _uploadedImageURL,
        "caption": caption,
        "location": selectedLocacion,
        'name': selectedYacimiento,
        'lat': lat,
        'long': long,
        'description': description,
        'uploadedBy': uploadedBy,
        'category': category,
        'field': field,
        'date': DateTime.now().toString(),
        'modifiedBy': modifiedBy,
        'rescued': rescued,
      };
      crudMethods
          .addData(userPostDetails)
          .then((value) => Navigator.pop(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 220, 98),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nuevo',
              style: TextStyle(
                fontSize: 22.0,
              ),
            ),
            Text(
              ' registro',
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : Container(
              margin: const EdgeInsets.all(22.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Cargar imagen desde"),
                                  content:
                                      // ignore: deprecated_member_use
                                      Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // ignore: deprecated_member_use
                                      ElevatedButton(
                                        onPressed: () async {
                                          await getImage(ImageSource.camera);
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Camara"),
                                      ),
                                      // ignore: deprecated_member_use
                                      ElevatedButton(
                                        onPressed: () async {
                                          await getImage(ImageSource.gallery);
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Galeria"),
                                      ),
                                      // ignore: deprecated_member_use
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancelar"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: _myImage!.path != ""
                              ? SizedBox(
                                  height: 120,
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _myImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 120,
                                  width: MediaQuery.of(context).size.width / 3,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 250, 220, 98),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child:
                                      const Icon(Icons.add_a_photo, size: 80.0),
                                ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        _dropdownLocation(),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                    Row(
                      children: [
                        const Text(
                          "Categoria",
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () => agregarItem(context, "categorias"),
                          child: const Card(
                              elevation: 5,
                              child: Row(
                                children: [
                                  Icon(Icons.add),
                                ],
                              )),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    _dropdownCategoria(),
                    const SizedBox(height: 25.0),
                    SizedBox(
                      child: category.isNotEmpty
                          ? ListView(
                              shrinkWrap: true,
                              children: category.keys
                                  .map((key) => Card(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(key),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(category[key].toString()),
                                          ],
                                        ),
                                      ))
                                  .toList())
                          : const Text("Agregue elementos"),
                    ),
                    const SizedBox(height: 25.0),
                    _descripcionWidget(),
                    TextField(
                      readOnly: true,
                      decoration: const InputDecoration(hintText: 'En campo'),
                      onChanged: (String value) {
                        rescued = false;
                      },
                    ),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                          hintText: lat != ''
                              ? 'Ubicación actual: $lat $long'
                              : 'No location data'),
                      onChanged: (String value) {
                        lat = lat;
                        long = long;
                      },
                    ),
                    const SizedBox(height: 30.0),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
//hago check de los parametros que quiero comprobar
                          if (category.isNotEmpty &&
                              selectedLocacion != "" &&
                              selectedYacimiento != "" &&
                              _myImage!.existsSync()) {
                            return uploadUserPost();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                        'Debe completar todos los campos')));
                          }
                        },
                        child: const Text('Cargar',
                            style: TextStyle(fontSize: 30)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  TextField _descripcionWidget() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Input text',
        labelText: 'Descripcion',
      ),
      onChanged: (String value) {
        description = value;
      },
    );
  }

  Widget _dropdownLocation() {
    final YacimientoBloc yacimientoBloc =
        BlocProvider.of<YacimientoBloc>(context);
    return Column(
      children: [
        BlocBuilder<YacimientoBloc, YacimientoState>(builder: (context, state) {
          if (state is YacimientoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is YacimientoLoaded) {
            return Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 250, 220, 98),
                      borderRadius: BorderRadius.circular(10)),
                  child: DropdownButton(
                    hint: const Text("Yacimiento"),
                    isExpanded: false,
                    items: state.yacimiento
                        .map((item) => DropdownMenuItem<String>(
                            value: item.name, child: Text(item.name)))
                        .toList(),
                    value: selectedYacimiento,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 42,
                    underline: const SizedBox(),
                    onChanged: (value) {
                      setState(
                        () {
                          debugPrint('make selected: $value');

                          selectedYacimiento = value;
                          selectedLocacion = null;
                          BlocProvider.of<LocacionesBloc>(context)
                              .add(LoadLocaciones(selectedYacimiento));
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () => agregarItem(context, "yacimiento"),
                  child: const Card(
                      elevation: 5,
                      child: Row(
                        children: [
                          Icon(Icons.add),
                        ],
                      )),
                )
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
        }),
        const SizedBox(
          height: 10,
        ),
        BlocBuilder<LocacionesBloc, LocacionesState>(builder: (context, state) {
          if (state is LocacionesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LocacionesLoaded) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 250, 220, 98),
                      borderRadius: BorderRadius.circular(10)),
                  child: DropdownButton(
                    hint: const Text("Locacion"),
                    isExpanded: false,
                    items: state.locaciones
                        .map((item) => DropdownMenuItem<String>(
                            value: item.name, child: Text(item.name)))
                        .toList(),
                    value: selectedLocacion,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 42,
                    underline: const SizedBox(),
                    onChanged: (value) {
                      setState(
                        () {
                          debugPrint('make selected: $value');

                          selectedLocacion = value;
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () => agregarItem(context, "locaciones"),
                  child: const Card(
                      elevation: 5,
                      child: Row(
                        children: [
                          Icon(Icons.add),
                        ],
                      )),
                )
              ],
            );
          } else if (state is LocacionesError) {
            return Center(child: Text(state.errorMessage));
          } else {
            return Container();
          }
        })
      ],
    );
  }

  Widget _dropdownCategoria() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categorias')
          .orderBy('name')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Container();

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 250, 220, 98),
                  borderRadius: BorderRadius.circular(10)),
              child: DropdownButton(
                hint: const Text("Seleccionar"),
                isExpanded: false,
                value: categoria == "" ? null : categoria,
                items: snapshot.data!.docs.map((value) {
                  return DropdownMenuItem(
                    value: value.get('name'),
                    child: Text('${value.get('name')}'),
                  );
                }).toList(),
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 42,
                underline: const SizedBox(),
                onChanged: (value) {
                  debugPrint('selected onchange: $value');
                  setState(
                    () {
                      debugPrint('make selected: $value');

                      categoria = value.toString();
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
              width: 60,
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '0',
                  labelText: 'Cant',
                ),
                onChanged: (String value) {
                  numTextController.text = value;
                },
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                category.addAll({categoria: numTextController.text});
              }),
              child: const Card(
                  elevation: 5,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Agregar"),
                      )
                    ],
                  )),
            )
          ],
        );
      },
    );
  }

  agregarItem(BuildContext context, String item) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continuar"),
      onPressed: () {
        textController.text = textController.text.toLowerCase();
        _formKey.currentState!.validate();
        setState(() {
          _isLoading = true;
          FirebaseFirestore.instance.collection((item)).add(
              {'name': textController.text, 'yacimiento': selectedYacimiento});
          _isLoading = false;
          Navigator.pop(context);
        });
      },
    );

    // set up the AlertDialog
    Widget alert = _isLoading
        ? const CircularProgressIndicator()
        : AlertDialog(
            title: Text("Ingrese nombre de $item"),
            content: Form(
              key: _formKey,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nombre no puede estar vacío.';
                  }
                  return null;
                },
                controller: textController,
              ),
            ),
            actions: [
              cancelButton,
              continueButton,
            ],
          );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
