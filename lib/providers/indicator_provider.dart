import 'package:flutter/foundation.dart';
import '../models/indicator_model.dart';
import '../services/storage_service.dart';

class IndicatorProvider with ChangeNotifier {
  List<IndicatorModel> _indicators = [];
  bool _isLoading = false;

  List<IndicatorModel> get indicators => _indicators;
  bool get isLoading => _isLoading;

  Future<void> loadIndicators() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _indicators = await StorageService.getIndicators();
    } catch (e) {
      debugPrint('Error loading indicators: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addIndicator(IndicatorModel indicator) async {
    try {
      await StorageService.saveIndicator(indicator);
      _indicators.add(indicator);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding indicator: $e');
    }
  }

  Future<void> deleteIndicator(String id) async {
    try {
      await StorageService.deleteIndicator(id);
      _indicators.removeWhere((indicator) => indicator.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting indicator: $e');
    }
  }

  List<IndicatorModel> getIndicatorsByCategory(String category) {
    return _indicators.where((indicator) => indicator.category == category).toList();
  }

  double getAverageScore() {
    if (_indicators.isEmpty) return 0.0;
    final totalScore = _indicators.fold(0, (sum, indicator) => sum + indicator.score);
    return totalScore / _indicators.length;
  }
}