import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../main.dart';

Future<void> initPB() async {
  FlutterSecureStorage storage = const FlutterSecureStorage();

  String? token = await storage.read(key: 'pb_auth_token');

  authStore = AsyncAuthStore(
    initial: token,
    save: saveToken,
    clear: deleteToken,
  );

  pb = PocketBase(dotenv.env['POCKETBASE_URL'] ?? '', authStore: authStore);
}

Future<void> saveToken(String token) async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  await storage.write(key: 'pb_auth_token', value: token);
}

Future<void> deleteToken() async {
  FlutterSecureStorage storage = const FlutterSecureStorage();
  await storage.delete(key: 'pb_auth_token');
}
