import 'package:dio/dio.dart';
import 'api_config.dart';

class ApiService {
  final Dio dio = Dio();

  Future<Response> get(String path, String? token, {Map<String, dynamic>? queryParameters} ) async {
    final url = '${ApiConfig.localBaseUrl}$path';
    // Create Dio options with authorization headers
    final options = Options(headers: {
      'Authorization': token,
      // Add any other headers you need
    });
    return await dio.get(url, queryParameters: queryParameters, options: options );
  }

  Future<Response> post(String path, String? token, {Map<String, dynamic>? data} ) async {
    final url = '${ApiConfig.localBaseUrl}$path';

    final options = Options(headers: {
      'Authorization': token,
      // Add any other headers you need
    });
    final a = await dio.post(url, data: data, options: options);
    print(a.statusMessage);
    return a;

  }

  Future<Response> put(String path, String? token, {Map<String, dynamic>? data} ) async {
    final url = '${ApiConfig.localBaseUrl}$path';

    final options = Options(headers: {
      'Authorization': token,
      // Add any other headers you need
    });
    final a = await dio.put(url, data: data, options: options);
    print(a.statusMessage);
    return a;

  }

// Add more methods for different HTTP operations as needed (PUT, DELETE, etc.).
}
