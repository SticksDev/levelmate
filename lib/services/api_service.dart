import 'package:dio/dio.dart';
import 'logger_service.dart';

class ApiService {
  static const String baseUrl = 'https://api.level.io/v2';
  late final Dio _dio;
  final _logger = LoggerService('ApiService');

  ApiService({String? token}) {
    _logger.info(
      'Initializing with ${token != null ? "existing" : "no"} token',
    );
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'LevelMate/1.0',
          if (token != null) 'Authorization': token,
        },
      ),
    );
  }

  void updateToken(String token) {
    _logger.info('Updating API token');
    _dio.options.headers['Authorization'] = token;
  }

  Future<bool> validateToken(String token) async {
    _logger.info('Validating API token');
    try {
      final response = await _dio.get(
        '/devices',
        options: Options(headers: {'Authorization': token}),
      );
      final isValid = response.statusCode == 200;
      _logger.info('Token validation ${isValid ? "successful" : "failed"}');
      return isValid;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        _logger.warning('Token validation failed: Unauthorized');
        _logger.info('Remote error: ${e.response?.data}');
        return false;
      }
      _logger.error('Token validation error', e);
      rethrow;
    }
  }

  Future<Response> getDevices() async {
    _logger.debug('Fetching devices from API');
    return await _dio.get('/devices');
  }
}
