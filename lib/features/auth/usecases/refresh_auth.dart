import 'package:placeholder/main.dart';

void refreshAuth() {
  pb.collection("users").authRefresh();
}
