import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:placeholder/main.dart';
import 'package:uuid/uuid.dart';

Future<String> uploadImage(File file, {String? userId}) async {
  try {
    final multipartFile = await http.MultipartFile.fromPath(
      'avatar',
      file.path,
    );

    final record = await pb
        .collection('files')
        .create(
          body: {
            'id': Uuid().v4().split('-').join(),
            'author_id': pb.authStore.record?.id,
            'user_id': userId,
          },
          files: [multipartFile],
        );

    final fileUrl = pb.files.getUrl(record, record.getStringValue('avatar'));

    log(fileUrl.toString());
    return fileUrl.toString();
  } catch (e) {
    rethrow;
  }
}
