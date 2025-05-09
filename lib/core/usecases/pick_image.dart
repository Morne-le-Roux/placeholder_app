import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:uuid/uuid.dart'; // Import Material package for UI components

Future<File?> pickImage(BuildContext context) async {
  File? filePicked;
  await showModalBottomSheet(
    backgroundColor: Colors.black,
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.only(top: 20, bottom: 40),
        height: MediaQuery.of(context).size.height / 4,
        child: Column(
          children: [
            Text("Pick an Image", style: Constants.textStyles.title2),
            const Expanded(child: SizedBox()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        XFile? pickedImage = await _pickAndCompress(
                          ImageSource.gallery,
                        );
                        if (pickedImage != null && context.mounted) {
                          filePicked = File(pickedImage.path);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.deepOrange),
                        ),
                        child: const Icon(Icons.photo),
                      ),
                    ),
                    const Text("Pick from Gallery"),
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        XFile? pickedImage = await _pickAndCompress(
                          ImageSource.camera,
                        );
                        if (pickedImage != null && context.mounted) {
                          filePicked = File(pickedImage.path);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.deepOrange),
                        ),
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                    const Text("Take a photo"),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  return filePicked;
}

Future<XFile?> _pickAndCompress(ImageSource source) async {
  ImagePicker picker = ImagePicker();
  XFile? xFile = await picker.pickImage(source: source);

  try {
    if (xFile != null) {
      File file = File(xFile.path);

      var dir = await getTemporaryDirectory();
      final String targetPath = "${dir.path}${const Uuid().v4()}.jpeg";

      XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 20,
        numberOfRetries: 5,
        format: CompressFormat.jpeg,
      );

      return compressedImage;
    }
  } on Exception catch (_) {
    rethrow;
  }

  return null;
}
