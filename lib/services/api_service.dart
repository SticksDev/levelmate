import 'package:dio/dio.dart';
import 'package:levelmate/models/api/device_response.dart';
import 'package:levelmate/models/device_model.dart';
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

  Future<DeviceResponse> getDevices(
    String? groupId,
    String? ancestorGroupdId,
    String? tagId,
    bool? includeOperatingSystem,
    bool? includeCPUs,
    bool? includeMemory,
    bool? includeDisks,
    bool? includeNetworks,
  ) async {
    _logger.info('Fetching devices');
    try {
      final response = await _dio.get(
        '/devices',
        queryParameters: {
          if (groupId != null) 'group_id': groupId,
          if (ancestorGroupdId != null) 'ancestor_group_id': ancestorGroupdId,
          if (tagId != null) 'tag_id': tagId,
          if (includeOperatingSystem != null)
            'include_operating_system': includeOperatingSystem,
          if (includeCPUs != null) 'include_cpus': includeCPUs,
          if (includeMemory != null) 'include_memory': includeMemory,
          if (includeDisks != null) 'include_disks': includeDisks,
          if (includeNetworks != null) 'include_networks': includeNetworks,
        },
      );
      final deviceResponse = DeviceResponse.fromJson(response.data);
      _logger.info('Devices fetched successfully');
      return deviceResponse;
    } on DioException catch (e) {
      _logger.error('Failed to fetch devices', e);
      rethrow;
    }
  }

  Future<Device> getDevice(String deviceId) async {
    _logger.info('Fetching device details for $deviceId');
    try {
      final response = await _dio.get(
        '/devices/$deviceId',
        queryParameters: {
          'include_operating_system': true,
          'include_cpus': true,
          'include_memory': true,
          'include_disks': true,
          'include_disk_partitions': true,
          'include_network_interfaces': true,
        },
      );
      final device = Device.fromJson(response.data);
      _logger.info('Device details fetched successfully');
      return device;
    } on DioException catch (e) {
      _logger.error('Failed to fetch device details', e);
      rethrow;
    }
  }
}
