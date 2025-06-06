import 'package:flutter/material.dart';
import '../models/lab_result.dart';
import '../services/lab_results_service.dart';

class LabResultsProvider extends ChangeNotifier {
  final LabResultsService _service;
  List<LabResult> _labResults = [];
  bool _isLoading = false;
  String? _error;

  LabResultsProvider(this._service);

  List<LabResult> get labResults => _labResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLabResults() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _labResults = await _service.fetchLabResults();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 