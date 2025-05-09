import 'package:url_launcher/url_launcher.dart';

void contactSupport(String message, {bool isError = false}) {
  launchUrl(
    Uri.parse(
      "mailto:placeholder-support@disnetdev.co.za?subject=Support Request&body=Hi!\n${isError ? "I am getting this following error:" : ""} \n\n\n $message",
    ),
  );
}
