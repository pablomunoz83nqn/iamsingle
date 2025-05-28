import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loveradar/src/home/controller/users_bloc/users_bloc.dart';
import 'package:loveradar/src/home/model/users_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loveradar/src/home/model/users_model.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();

  String? _gender;
  List<File> _imageFiles = []; // Lista de imágenes seleccionadas

  final _user = FirebaseAuth.instance.currentUser;
  Users? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    if (_user != null) {
      // Fuerza la obtención de datos directamente desde el servidor
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.email)
          .get(const GetOptions(
              source: Source.server)); // Carga directa desde el servidor

      final data = doc.data();
      if (data != null) {
        // Cargar los datos del usuario
        _currentUser = Users.fromMap(data, _user!.email!);
        _nameCtrl.text = _currentUser?.name ?? '';
        _lastNameCtrl.text = _currentUser?.lastName ?? '';
        _ageCtrl.text = _currentUser?.age ?? '';
        _bioCtrl.text = _currentUser?.bio ?? '';
        _gender = _currentUser?.gender;

        // Cargar las imágenes de perfil, si existen
        if (_currentUser?.profileImages != null &&
            _currentUser!.profileImages!.isNotEmpty) {
          setState(() {
            // Mantener solo las URLs de las imágenes
            _imageFiles = [];
          });
        } else {
          // Si no hay imágenes, asigna un valor de placeholder vacío o una imagen predeterminada
          setState(() {
            _imageFiles = [];
          });
        }

        // Actualizar la interfaz de usuario
        setState(() {});
      }
    }
  }

  Future<List<String?>> _uploadImages(List<File> files) async {
    List<String?> imageUrls = [];

    for (var file in files) {
      try {
        final ref = FirebaseStorage.instance.ref().child(
            'images/${_user!.email}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = await ref.putFile(file);
        final snapshot = uploadTask;

        if (snapshot.state == TaskState.success) {
          final url = await ref.getDownloadURL();
          imageUrls.add(url);
        } else {
          imageUrls.add(null); // Agregar un valor null si la carga falla
        }
      } catch (e) {
        print('❌ Error al subir imagen: $e');
        imageUrls.add(null); // Agregar un valor null en caso de error
      }
    }

    return imageUrls;
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickMultiImage(); // Permite seleccionar múltiples imágenes

    if (picked.isNotEmpty) {
      setState(() {
        // Verifica si ya hay 5 imágenes, si es así, pregunta cuál reemplazar
        if (_currentUser?.profileImages?.length == 5) {
          _showReplaceImageDialog(picked);
        } else {
          // Si no hay 5 imágenes, simplemente las agrega
          _imageFiles = picked.map((file) => File(file.path)).toList();
        }
      });
    }
  }

  void _showReplaceImageDialog(List<XFile> pickedImages) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Qué imagen quieres reemplazar?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return ListTile(
                title: Text('Reemplazar imagen ${index + 1}'),
                onTap: () {
                  _replaceImage(index, pickedImages);
                  Navigator.pop(context); // Cierra el diálogo
                },
              );
            }),
          ),
        );
      },
    );
  }

  void _replaceImage(int index, List<XFile> pickedImages) async {
    // Asegúrate de que la lista tenga al menos una imagen seleccionada
    if (pickedImages.isNotEmpty) {
      try {
        final file = File(pickedImages[0]
            .path); // Obtiene el archivo de la imagen seleccionada

        // Subir la imagen a Firebase Storage
        final ref = FirebaseStorage.instance.ref().child(
            'images/${_user!.email}/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = await ref.putFile(file);
        final snapshot = uploadTask;

        if (snapshot.state == TaskState.success) {
          // Obtener la URL de la imagen subida
          final url = await ref.getDownloadURL();

          setState(() {
            // Reemplazar el URL de la imagen en la posición seleccionada
            _currentUser?.profileImages?[index] = url;
          });
        } else {
          throw Exception("Error al subir la imagen");
        }
      } catch (e) {
        print('Error al subir la imagen: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      List? imageUrls = [];

      // Si el usuario seleccionó nuevas imágenes, las subimos
      if (_imageFiles.isNotEmpty) {
        imageUrls = await _uploadImages(_imageFiles);
      } else {
        // Si no se seleccionaron imágenes, mantenemos las anteriores
        imageUrls = _currentUser?.profileImages ?? [];
      }

      Users updatedUser = Users(
        id: _user!.uid,
        email: _currentUser?.email,
        name: _nameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        age: _ageCtrl.text.trim(),
        birthDate: _currentUser?.birthDate,
        gender: _gender,
        bio: _bioCtrl.text.trim(),
        profileImages: imageUrls, // Actualizamos con la lista de imágenes
        lat: _currentUser?.lat,
        long: _currentUser?.long,
        isPremium: _currentUser?.isPremium,
        visitedBy: _currentUser?.visitedBy,
      );

      // Disparar el evento para actualizar el usuario
      BlocProvider.of<UsersBloc>(context).add(UpdateUserEvent(updatedUser));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is UsersOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Perfil actualizado")),
          );
          Navigator.pop(context);
        } else if (state is UsersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${state.errorMessage}")),
          );
        }
      },
      builder: (context, state) {
        if (state is UsersLoading) {
          return Scaffold(
            body: Center(
              child: Shimmer(
                child: Container(
                  color: Colors.deepPurple,
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Editar Perfil')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImages,
                    child: _currentUser?.profileImages?.isNotEmpty ?? false
                        ? SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  _currentUser?.profileImages?.length ?? 0,
                              itemBuilder: (context, index) {
                                final imageUrl =
                                    _currentUser!.profileImages![index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : const CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.add_a_photo, size: 40),
                          ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextFormField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(labelText: 'Apellido'),
                  ),
                  TextFormField(
                    controller: _ageCtrl,
                    decoration: const InputDecoration(labelText: 'Edad'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _bioCtrl,
                    decoration: const InputDecoration(labelText: 'Bio'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: 'Género'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Masculino', child: Text('Masculino')),
                      DropdownMenuItem(
                          value: 'Femenino', child: Text('Femenino')),
                      DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                    ],
                    onChanged: (value) => setState(() => _gender = value),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Guardar Cambios'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
