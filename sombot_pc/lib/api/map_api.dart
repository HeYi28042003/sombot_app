import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sombot_pc/data/models/map_model.dart';

class MapApi {
  Future<PlaceModel?> reverseGeocode({
    required double lat,
    required double lon,
    void Function(bool isLoading)? onLoading,
  }) async {
    onLoading?.call(true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SombotPC/1.0 (contact@sombot.com)', // Change to real contact
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['display_name'] != null) {
          final place = PlaceModel.fromJson(responseBody);
          print('[✔] Reverse geocode success: ${place.displayName}');
          return place;
        } else {
          print('[⚠] No display_name in response');
          return null;
        }
      } else {
        print('[❌] HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[❗] Exception during reverse geocode: $e');
      return null;
    } finally {
      onLoading?.call(false);
    }
  }
}
 