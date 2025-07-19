import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'dart:io';
import 'package:loveradar/src/home/model/users_model.dart';

class EditProfileForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController ageCtrl;
  final TextEditingController bioCtrl;
  final String? gender;
  final List<File> imageFiles;
  final Users? currentUser;
  final List<String> pendingDeletes;
  final bool isSaving;
  final VoidCallback onPickImages;

  final void Function(List<ImageDataProfile> orderedImages) onSave;
  final Function(String?) onGenderChanged;
  final Function(int index) onRemoveLocalImage;
  final Function(int index, String url) onRemoveOnlineImage;

  const EditProfileForm({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.lastNameCtrl,
    required this.ageCtrl,
    required this.bioCtrl,
    required this.gender,
    required this.imageFiles,
    required this.currentUser,
    required this.pendingDeletes,
    required this.isSaving,
    required this.onPickImages,
    required this.onSave,
    required this.onGenderChanged,
    required this.onRemoveLocalImage,
    required this.onRemoveOnlineImage,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();

  var generatedList = [];

  @override
  Widget build(BuildContext context) {
    final onlineImages =
        widget.currentUser?.profileImages?.asMap().entries.map((entry) {
              final index = entry.key;
              final url = entry.value;
              return ImageDataProfile(
                url: url,
                widget: Image.network(url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity),
                label: "Foto online",
                onDelete: () => widget.onRemoveOnlineImage(index, url),
              );
            }).toList() ??
            [];

    final newImages = widget.imageFiles
        .map((file) => ImageDataProfile(
              file: file,
              widget: Image.file(file, fit: BoxFit.cover),
              label: "Foto seleccionada",
              onDelete: () =>
                  widget.onRemoveLocalImage(widget.imageFiles.indexOf(file)),
            ))
        .toList();

    List<ImageDataProfile> allImages = [...onlineImages, ...newImages];
    if (generatedList.isEmpty || generatedList.length != allImages.length) {
      generatedList = allImages;
    }

    final generatedChildren = List.generate(
      generatedList.length,
      (index) {
        final img = generatedList[index];
        return Container(
            key: Key(generatedList.elementAt(index).hashCode.toString()),
            child: Stack(
              children: [
                _imagePreview(
                  context,
                  image: img.widget,
                  label: img.label,
                  onDelete: img.onDelete,
                ),
                if (index == 0)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Principal",
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ));
      },
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tus fotos",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 400,
              width: 400,
              child: ReorderableBuilder(
                scrollController: _scrollController,
                onReorder: (ReorderedListFunction reorderedListFunction) {
                  setState(() {
                    generatedList = reorderedListFunction(generatedList)
                        as List<ImageDataProfile>;
                  });
                },
                builder: (children) {
                  return GridView(
                    key: _gridViewKey,
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 8,
                    ),
                    children: children,
                  );
                },
                children: generatedChildren,
              ),
            ),
            /* GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final img = allImages[index];
                return _imagePreview(
                  context,
                  image: img.widget,
                  label: img.label,
                  onDelete: img.onDelete,
                );
              },
            ), */
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: widget.onPickImages,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text("Agregar o reemplazar fotos"),
            ),
            const SizedBox(height: 24),
            _styledInput(widget.nameCtrl, "Nombre"),
            const SizedBox(height: 12),
            _styledInput(widget.lastNameCtrl, "Apellido"),
            const SizedBox(height: 12),
            _styledInput(widget.ageCtrl, "Edad",
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _styledInput(widget.bioCtrl, "Bio", maxLines: 3),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: widget.gender,
              decoration: _inputDecoration("Género"),
              items: const [
                DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                DropdownMenuItem(value: 'Otro', child: Text('Otro')),
              ],
              onChanged: widget.onGenderChanged,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: widget.isSaving
                    ? null
                    : () =>
                        widget.onSave(generatedList.cast<ImageDataProfile>()),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: widget.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Guardar cambios"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledInput(TextEditingController ctrl, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  Widget _imagePreview(
    BuildContext context, {
    required Widget image,
    required String label,
    required VoidCallback onDelete,
  }) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[200],
            child: image,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}

class ImageDataProfile {
  final Widget widget;
  final String label;
  final VoidCallback onDelete;
  final String? url;
  final File? file;

  ImageDataProfile({
    required this.widget,
    required this.label,
    required this.onDelete,
    this.url,
    this.file,
  });
}
