import 'package:url_launcher/url_launcher.dart';

class ChessUrlLauncher {
  static Future<void> launch<E extends Object>({
    required String? url,
    required Function(E) onError,
  }) async {
    try {
      if (url != null && url.isNotEmpty) {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          throw '$url da xatolik bor';
        }
      } else {
        throw "URL kiritilmagan";
      }
    } on E catch (e) {
      onError.call(e);
      throw e.toString();
    }
  }
}
