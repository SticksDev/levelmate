import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';

class DeviceController extends ChangeNotifier {
  final ApiService _apiService;
  final _logger = LoggerService('DeviceController');

  List<Device> _devices = [];
  bool _isLoading = false;
  String? _errorMessage;

  DeviceController(this._apiService) {
    _logger.info('Initialized');
    fetchDevices();
  }

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDevices() async {
    _logger.info('Starting device fetch');
    _isLoading = true;
    _errorMessage = null;

    // Notify listeners before making the API call
    notifyListeners();

    try {
      final response = await _apiService.getDevices(
        null,
        null,
        null,
        true, // includeOperatingSystem
        false,
        false,
        false,
        false,
      );
      _devices = response.devices;
      _logger.info('Fetched ${_devices.length} devices');
      _isLoading = false;
    } catch (e) {
      _logger.error('Failed to fetch devices', e);
      _errorMessage = 'Failed to load devices: ${e.toString()}';
      _isLoading = false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _logger.info('Refreshing devices');
    await fetchDevices();
  }
}
