import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:novedades_de_campo/src/home/controller/field_controller.dart';

class CreateImagePost extends StatefulWidget {
  @override
  _CreateImagePostState createState() => _CreateImagePostState();
}

class _CreateImagePostState extends State<CreateImagePost> {
  Position? position;
  var yacimiento, locacion;

  late TextEditingController textController;
  final _formKey = GlobalKey<FormState>();

  late File? _myImage = File(
      'https://c1.wallpaperflare.com/preview/989/1023/622/hand-holding-camera-old.jpg');
  late final picker = ImagePicker();
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

  late String _uploadedImageURL;
  bool _isLoading = false;
  late HomeViewController crudMethods;

  @override
  void initState() {
    textController = TextEditingController();
    crudMethods = HomeViewController(context);
    getCurrentPosition();
    super.initState();
  }

  String caption = '';
  String location = '';
  String name = '';
  String lat = '';
  String long = '';
  String description = '';
  String uploadedBy = '';
  String category = '';
  String field = '';
  String date = '';
  String modifiedBy = '';
  bool rescued = false;

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

  uploadUserPost() async {
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
        "location": locacion,
        'name': yacimiento,
        'lat': lat,
        'long': long,
        'description': description,
        'uploadedBy': uploadedBy,
        'category': category,
        'field': field,
        'date': date,
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
      backgroundColor: Colors.lightGreen[200],
      appBar: AppBar(
        backgroundColor: Colors.teal,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Upload Image"),
                              content:
                                  // ignore: deprecated_member_use
                                  Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // ignore: deprecated_member_use
                                  ElevatedButton(
                                    onPressed: () async {
                                      await getImage(ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Photo with Camera"),
                                  ),
                                  // ignore: deprecated_member_use
                                  ElevatedButton(
                                    onPressed: () async {
                                      await getImage(ImageSource.gallery);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Photo with Gallery"),
                                  ),
                                  // ignore: deprecated_member_use
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: _myImage!.existsSync()
                          ? SizedBox(
                              height: 180,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _myImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              height: 180,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_a_photo, size: 80.0),
                            ),
                    ),
                    const SizedBox(height: 25.0),
                    TextField(
                      decoration:
                          const InputDecoration(hintText: 'Descripción'),
                      onChanged: (String value) {
                        description = value;
                      },
                    ),
                    _dropdownLocation(),
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
                          if (description != "" &&
                              locacion != "" &&
                              yacimiento != "" &&
                              _myImage!.existsSync()) {
                            return uploadUserPost();
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

  Widget _dropdownLocation() {
    return SizedBox(
      height: 100,
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('yacimiento')
                    .orderBy('name')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Container();

                  return Row(
                    children: [
                      const Text('Yacimiento: '),
                      DropdownButton(
                        isExpanded: false,
                        value: yacimiento,
                        items: snapshot.data!.docs.map((value) {
                          return DropdownMenuItem(
                            value: value.get('name'),
                            child: Text('${value.get('name')}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          debugPrint('selected onchange: $value');
                          setState(
                            () {
                              debugPrint('make selected: $value');
                              // Selected value will be stored
                              yacimiento = value;
                              // Default dropdown value won't be displayed anymore
                              //setDefaultMake = false;
                              // Set makeModel to true to display first car from list
                              //setDefaultMakeModel = true;
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: yacimiento != null
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('locaciones')
                          .where('yacimiento', isEqualTo: yacimiento)
                          .orderBy('name')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          debugPrint('snapshot status: ${snapshot.error}');
                          return Text(
                              'snapshot empty yacimiento: $yacimiento locacion: $locacion');
                        }

                        return Row(
                          children: [
                            const Text('Pad o locación: '),
                            DropdownButton(
                              isExpanded: false,
                              value: locacion,
                              items: snapshot.data!.docs.map((value) {
                                debugPrint('Locacion: ${value.get('name')}');
                                return DropdownMenuItem(
                                  value: value.get('name'),
                                  child: Text(
                                    '${value.get('name')}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                debugPrint('Locacion selected: $value');
                                setState(
                                  () {
                                    locacion = value;
                                  },
                                );
                              },
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                              onTap: () => showAlertDialog(context),
                              child: const Card(
                                  elevation: 5,
                                  child: Row(
                                    children: [
                                      Text(
                                        'Agregar locación',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Icon(Icons.add),
                                    ],
                                  )),
                            )
                          ],
                        );
                      },
                    )
                  : const Text('Seleccione un yacimiento'),
            ),
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
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
          FirebaseFirestore.instance
              .collection('locaciones')
              .add({'name': textController.text, 'yacimiento': yacimiento});
          _isLoading = false;
          Navigator.pop(context);
        });
      },
    );

    // set up the AlertDialog
    Widget alert = _isLoading
        ? const CircularProgressIndicator()
        : AlertDialog(
            title: const Text("Ingrese nombre de locación"),
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
