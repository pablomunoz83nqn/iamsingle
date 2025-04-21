import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_am_single/src/home/controller/users_bloc/users_bloc.dart';
import 'package:i_am_single/src/home/model/users_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  File? _imageFile;
  String? _profileImageUrl;

  final _user = FirebaseAuth.instance.currentUser;
  Users? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    if (_user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.email)
          .get();
      final data = doc.data();
      if (data != null) {
        _currentUser = Users.fromMap(data, _user!.email!);
        _nameCtrl.text = _currentUser?.name ?? '';
        _lastNameCtrl.text = _currentUser?.lastName ?? '';
        _ageCtrl.text = _currentUser?.age ?? '';
        _bioCtrl.text = _currentUser?.bio ?? '';
        _gender = _currentUser?.gender;
        _profileImageUrl = _currentUser?.profileImage;
        setState(() {});
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('images/${_user!.email}.jpg');
      final uploadTask = await ref.putFile(file);

      // Esperar a que se complete y verificar estado
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        print('❌ Falló la subida. Estado: ${snapshot.state}');
        return null;
      }
    } catch (e) {
      print('❌ Error al subir o descargar imagen: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl = _profileImageUrl;

      if (_imageFile != null) {
        final uploadedUrl = await _uploadImage(_imageFile!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          // Manejar error visual
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Error al subir la imagen de perfil.")),
          );
          return;
        }
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
        profileImage: imageUrl,
        lat: _currentUser?.lat,
        long: _currentUser?.long,
        isPremium: _currentUser?.isPremium,
        visitedBy: _currentUser?.visitedBy,
      );

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
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
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
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : null) as ImageProvider<Object>?,
                      child: _imageFile == null && _profileImageUrl == null
                          ? const Icon(Icons.add_a_photo, size: 40)
                          : null,
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
