import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> chooseImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? img = await picker.pickImage(
    source: ImageSource.gallery,
    maxHeight: 250,
    maxWidth: 250,
  );
  if (img != null) {
    return File(img.path);
  } else {
    return null;
  }
}
