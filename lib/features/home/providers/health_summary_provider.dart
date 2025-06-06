import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

class HealthSummaryProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  int _totalTests = 0;
  int _abnormalResults = 0;
  bool _isLoading = false;
  String? _error;

  HealthSummaryProvider(this._apiClient);

  int get totalTests => _totalTests;
  int get abnormalResults => _abnormalResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiClient.get('/lab-results/summary');
      _totalTests = response.data['totalTests'] ?? 0;
      _abnormalResults = 0; // Static for now
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 