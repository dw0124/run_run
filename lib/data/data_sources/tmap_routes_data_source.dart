import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:run_run/domain/entities/route.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class RouteDataSource {
  Future<Map<String, dynamic>> requestRoute(Route route);
}

class TmapRoutesDataSource extends RouteDataSource {
  TmapRoutesDataSource({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Future<Map<String, dynamic>> requestRoute(Route route) async {
    final appKey = dotenv.env['TMAP_APP_KEY']!;  // nullable 처리 해야함

    final header = {
      "appKey": appKey,
    };

    final query = {
      "version": "${1}",
      "format": "json",
      "callback": "result",
      "startX": "${route.startX}",
      "startY": "${route.startY}",
      "endX": "${route.endX}",
      "endY": "${route.endY}",
      "passList": "126.99696349525492,37.560590999574236_126.99696449525402,37.560590999574206",
      "startName": "시작점",
      "endName": "도착점",
      "searchOption": "${route.searchOption.code}",
      "sort": "index"
    };

    final url = Uri.https(
      "apis.openapi.sk.com",
      "/tmap/routes/pedestrian",
      query
    );

    var response = await _httpClient.post(url, headers: header);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse;
    } else {
      throw Exception('Failed to request TmapRoute: ${response.statusCode}');
    }
  }

  void close() { _httpClient.close(); }
}