// ✨ Rediseño completo de EditProfilePage con estilo LoveRadar

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loveradar/src/home/controller/users_bloc/users_bloc.dart';
import 'package:loveradar/src/home/model/users_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loveradar/src/home/view/edit_profile_view/edit_profile_form.dart';
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
  List<File> _imageFiles = [];
  final List<String> _pendingDeletes = [];

  final _user = FirebaseAuth.instance.currentUser;
  Users? _currentUser;

  bool _isSaving = false;

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
          .get(const GetOptions(source: Source.server));

      final data = doc.data();
      if (data != null) {
        _currentUser = Users.fromMap(data, _user!.email!);
        _nameCtrl.text = _currentUser?.name ?? '';
        _lastNameCtrl.text = _currentUser?.lastName ?? '';
        _ageCtrl.text = _currentUser?.age ?? '';
        _bioCtrl.text = _currentUser?.bio ?? '';
        _gender = _currentUser?.gender;
        setState(() {
          _imageFiles = [];
        });
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
          imageUrls.add(null);
        }
      } catch (e) {
        print('❌ Error al subir imagen: $e');
        imageUrls.add(null);
      }
    }
    return imageUrls;
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final int currentTotal =
        (_currentUser?.profileImages?.length ?? 0) + _imageFiles.length;
    final int remainingSlots = 9 - currentTotal;

    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Solo se pueden subir hasta 9 fotos."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final picked = await picker.pickMultiImage(limit: remainingSlots);

    if (picked.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(picked.map((file) => File(file.path)));
      });
    }
  }

  void _saveProfileFromOrder(List<ImageDataProfile> orderedImages) async {
    setState(() => _isSaving = true);

    if (_formKey.currentState!.validate()) {
      List<String> imageUrls = [];

      for (final img in orderedImages) {
        if (img.url != null) {
          imageUrls.add(img.url!);
        } else if (img.file != null) {
          final newUrls = await _uploadImages([img.file!]);
          imageUrls.addAll(newUrls.whereType<String>());
        }
      }

      if (imageUrls.isEmpty) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Necesitás al menos una foto para que los demás puedan encontrarte ❤️"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      for (final url in _pendingDeletes) {
        try {
          await FirebaseStorage.instance.refFromURL(url).delete();
        } catch (e) {
          print('❌ Error al eliminar imagen: $e');
        }
      }

      _pendingDeletes.clear();

      final updatedUser = Users(
        id: _user!.uid,
        email: _currentUser?.email,
        name: _nameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        age: _ageCtrl.text.trim(),
        birthDate: _currentUser?.birthDate,
        gender: _gender,
        bio: _bioCtrl.text.trim(),
        profileImages: imageUrls,
        lat: _currentUser?.lat,
        long: _currentUser?.long,
        isPremium: _currentUser?.isPremium,
        visitedBy: _currentUser?.visitedBy,
      );

      BlocProvider.of<UsersBloc>(context).add(UpdateUserEvent(updatedUser));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is UsersOperationSuccess || state is UsersError) {
          setState(() => _isSaving = false);
        }
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
                child: Container(color: Colors.deepPurple),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Editar Perfil')),
          body: EditProfileForm(
            formKey: _formKey,
            nameCtrl: _nameCtrl,
            lastNameCtrl: _lastNameCtrl,
            ageCtrl: _ageCtrl,
            bioCtrl: _bioCtrl,
            gender: _gender,
            imageFiles: _imageFiles,
            currentUser: _currentUser,
            pendingDeletes: _pendingDeletes,
            isSaving: _isSaving,
            onPickImages: _pickImages,
            onSave: _saveProfileFromOrder,
            onGenderChanged: (value) => setState(() => _gender = value),
            onRemoveLocalImage: (index) =>
                setState(() => _imageFiles.removeAt(index)),
            onRemoveOnlineImage: (index, url) => setState(() {
              _pendingDeletes.add(url);
              _currentUser?.profileImages?.removeAt(index);
            }),
          ),
        );
      },
    );
  }
}

// 🔥 EditProfileForm vendrá modularizado, estilizado y con UX top.
// Lo implementamos en el siguiente paso.
