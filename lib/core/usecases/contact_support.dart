import 'package:url_launcher/url_launcher.dart';

void contactSupport(String message) {
   launchUrl(Uri.parse(
      "mailto:placeholder-support@disnetdev.co.za?subject=Support Request&body=Hi!\nI am getting this following error: \n\n\n $message"));
}