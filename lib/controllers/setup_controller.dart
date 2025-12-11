import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';
import '../services/storage_service.dart';

class SetupController extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  final _logger = LoggerService('SetupController');

  bool _isLoading = false;
  String? _errorMessage;

  SetupController(this._apiService, this._storageService) {
    _logger.info('Initialized');
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> validateAndSaveToken(String token) async {
    _logger.info('Starting token validation and save process');

    if (token.trim().isEmpty) {
      _logger.warning('Token validation failed: empty token');
      _errorMessage = 'Please enter an API token';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isValid = await _apiService.validateToken(token);

      if (isValid) {
        _logger.info('Token valid, saving to storage');
        await _storageService.saveToken(token);
        _apiService.updateToken(token);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _logger.warning('Token validation failed: invalid token');
        _errorMessage = 'Invalid API token. Please check and try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _logger.error('Token validation error', e);
      _errorMessage = 'Failed to validate token: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
