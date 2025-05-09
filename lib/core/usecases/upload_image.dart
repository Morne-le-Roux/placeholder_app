import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:placeholder/main.dart';

Future<String> uploadImage(File file) async {
  try {
    final multipartFile = await http.MultipartFile.fromPath('file', file.path);
    final record = await pb
        .collection('files')
        .create(
          body: {
            'name': file.path.split('/').last,
            'author_id': pb.authStore.record?.id,
          },
          files: [multipartFile],
        );

    final fileUrl = pb.files.getUrl(record, record.getStringValue('name'));
    return fileUrl.toString();
  } catch (e) {
    throw Exception('Failed to upload image: $e');
  }
}
