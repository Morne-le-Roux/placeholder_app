import 'dart:developer';
import 'dart:io';

import 'package:placeholder/main.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

Future<String> uploadImage(File file) async {
  String fileId = Uuid().v4();
  String userId = sb.auth.currentUser?.id ?? "non_user";

  try {
    // Get the file extension from the original file
    String extension = path.extension(file.path);

    // Create a new file with UUID name and original extension
    String newFileName = '$fileId$extension';
    String newFilePath = path.join(path.dirname(file.path), newFileName);
    File renamedFile = await file.copy(newFilePath);

    // Upload the renamed file
    await sb.storage
        .from("media")
        .upload("$userId/$newFileName", renamedFile, retryAttempts: 3);

    // Clean up the temporary renamed file
    await renamedFile.delete();

    return newFileName;
  } catch (e) {
    rethrow;
  }
}

String getImageUrl(String fileId) {
  String userId = sb.auth.currentUser?.id ?? "non_user";
  String fileUrl = sb.storage.from("media").getPublicUrl("$userId/$fileId");
  log("fileUrl: ${fileUrl.toString()}");
  return fileUrl.toString();
}
