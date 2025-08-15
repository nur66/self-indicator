import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/indicator_model.dart';
import '../models/indicator_template.dart';

class StorageService {
  static const String _key = 'indicators';
  static const String _templatesKey = 'indicator_templates';

  static Future<List<IndicatorModel>> getIndicators() async {
    final prefs = await SharedPreferences.getInstance();
    final String? indicatorsJson = prefs.getString(_key);
    
    if (indicatorsJson == null) return [];
    
    final List<dynamic> indicatorsList = json.decode(indicatorsJson);
    return indicatorsList.map((json) => IndicatorModel.fromMap(json)).toList();
  }

  static Future<void> saveIndicator(IndicatorModel indicator) async {
    final prefs = await SharedPreferences.getInstance();
    final indicators = await getIndicators();
    
    indicators.add(indicator);
    
    final String indicatorsJson = json.encode(
      indicators.map((indicator) => indicator.toMap()).toList()
    );
    
    await prefs.setString(_key, indicatorsJson);
  }

  static Future<void> deleteIndicator(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final indicators = await getIndicators();
    
    indicators.removeWhere((indicator) => indicator.id == id);
    
    final String indicatorsJson = json.encode(
      indicators.map((indicator) => indicator.toMap()).toList()
    );
    
    await prefs.setString(_key, indicatorsJson);
  }

  static Future<List<IndicatorTemplate>> getTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? templatesJson = prefs.getString(_templatesKey);
    
    if (templatesJson == null) return [];
    
    final List<dynamic> templatesList = json.decode(templatesJson);
    return templatesList.map((json) => IndicatorTemplate.fromMap(json)).toList();
  }

  static Future<void> saveTemplate(IndicatorTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = await getTemplates();
    
    final existingIndex = templates.indexWhere((t) => t.id == template.id);
    if (existingIndex >= 0) {
      templates[existingIndex] = template;
    } else {
      templates.add(template);
    }
    
    final String templatesJson = json.encode(
      templates.map((template) => template.toMap()).toList()
    );
    
    await prefs.setString(_templatesKey, templatesJson);
  }

  static Future<void> deleteTemplate(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = await getTemplates();
    
    templates.removeWhere((template) => template.id == id);
    
    final String templatesJson = json.encode(
      templates.map((template) => template.toMap()).toList()
    );
    
    await prefs.setString(_templatesKey, templatesJson);
  }

  static Future<void> createTemplateFromIndicator(IndicatorModel indicator) async {
    final template = IndicatorTemplate(
      id: 'template_${indicator.title.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
      title: indicator.title,
      description: indicator.description,
      category: indicator.category,
      targetTime: indicator.targetTime,
      useAutoScoring: indicator.scoreRules?['autoScoring'] ?? false,
    );
    
    await saveTemplate(template);
  }
}