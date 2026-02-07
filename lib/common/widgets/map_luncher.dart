import 'package:url_launcher/url_launcher.dart';

class MapLauncherUtil {
  static Future<void> openDirections({
    required double latitude,
    required double longitude,
  }) async {
    final Uri googleMapsWebUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );

    final launched = await launchUrl(
      googleMapsWebUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('Could not open Google Maps');
    }
  }
}
