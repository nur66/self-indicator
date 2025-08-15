import 'package:flutter/foundation.dart';
import '../models/indicator_model.dart';
import '../models/indicator_template.dart';
import '../services/storage_service.dart';

class IndicatorProvider with ChangeNotifier {
  List<IndicatorModel> _indicators = [];
  List<IndicatorTemplate> _templates = [];
  bool _isLoading = false;

  List<IndicatorModel> get indicators => _indicators;
  List<IndicatorTemplate> get templates => _templates;
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
      
      await StorageService.createTemplateFromIndicator(indicator);
      await loadTemplates();
      
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

  Future<void> loadTemplates() async {
    try {
      _templates = await StorageService.getTemplates();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading templates: $e');
    }
  }

  Future<void> addTemplate(IndicatorTemplate template) async {
    try {
      await StorageService.saveTemplate(template);
      _templates.add(template);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding template: $e');
    }
  }

  Future<void> updateTemplate(IndicatorTemplate template) async {
    try {
      await StorageService.saveTemplate(template);
      final index = _templates.indexWhere((t) => t.id == template.id);
      if (index >= 0) {
        _templates[index] = template;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating template: $e');
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await StorageService.deleteTemplate(id);
      _templates.removeWhere((template) => template.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting template: $e');
    }
  }
}