import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/indicator_model.dart';

class StorageService {
  static const String _key = 'indicators';

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

  // Debug function untuk melihat raw data
  static Future<void> debugPrintStorageData() async {
    final prefs = await SharedPreferences.getInstance();
    print('=== DEBUG SHARED PREFERENCES ===');
    print('Storage key: $_key');
    
    final rawData = prefs.getString(_key);
    if (rawData == null) {
      print('No data found in SharedPreferences');
      return;
    }
    
    print('Raw JSON length: ${rawData.length} characters');
    print('Raw JSON data:');
    print(rawData);
    
    try {
      final decoded = json.decode(rawData);
      print('Decoded data count: ${decoded.length} items');
      print('First item: ${decoded.isNotEmpty ? decoded[0] : 'None'}');
    } catch (e) {
      print('Error decoding JSON: $e');
    }
    print('================================');
  }

  // Function untuk export data ke string yang bisa di-copy
  static Future<String> exportToJson() async {
    final indicators = await getIndicators();
    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'total_indicators': indicators.length,
      'indicators': indicators.map((e) => e.toMap()).toList(),
    };
    
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  // Function untuk melihat statistik storage
  static Future<Map<String, dynamic>> getStorageStats() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_key);
    final indicators = await getIndicators();
    
    return {
      'total_indicators': indicators.length,
      'raw_data_size_bytes': rawData?.length ?? 0,
      'raw_data_size_kb': ((rawData?.length ?? 0) / 1024).toStringAsFixed(2),
      'categories': indicators.fold<Map<String, int>>({}, (map, indicator) {
        map[indicator.category] = (map[indicator.category] ?? 0) + 1;
        return map;
      }),
      'oldest_indicator': indicators.isEmpty ? null : indicators.last.date.toIso8601String(),
      'newest_indicator': indicators.isEmpty ? null : indicators.first.date.toIso8601String(),
    };
  }
}