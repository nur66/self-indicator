import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/indicator_template.dart';
import '../models/indicator_model.dart';
import '../providers/indicator_provider.dart';

class QuickLogScreen extends StatefulWidget {
  const QuickLogScreen({super.key});

  @override
  State<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends State<QuickLogScreen> {
  final Map<String, bool> _checkedTemplates = {};
  final Map<String, DateTime> _selectedDates = {};
  final Map<String, TimeOfDay> _selectedTimes = {};
  final Map<String, int> _calculatedScores = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IndicatorProvider>().loadTemplates();
    });
  }

  int _calculateScore(IndicatorTemplate template, TimeOfDay? actualTime) {
    if (!template.useAutoScoring || template.targetTime == null || actualTime == null) {
      return 5;
    }

    final targetParts = template.targetTime!.split(':');
    final targetHour = int.parse(targetParts[0]);
    final targetMinute = int.parse(targetParts[1].replaceAll(RegExp(r'[^0-9]'), ''));
    
    final targetMinutes = targetHour * 60 + targetMinute;
    final actualMinutes = actualTime.hour * 60 + actualTime.minute;
    final diffMinutes = actualMinutes - targetMinutes;

    if (diffMinutes <= 0) return 10;
    if (diffMinutes <= 5) return 9;
    if (diffMinutes <= 10) return 8;
    if (diffMinutes <= 15) return 7;
    if (diffMinutes <= 30) return 6;
    if (diffMinutes <= 60) return 5;
    if (diffMinutes <= 120) return 4;
    if (diffMinutes <= 180) return 3;
    if (diffMinutes <= 240) return 2;
    return 1;
  }

  void _updateScore(String templateId, IndicatorTemplate template) {
    final time = _selectedTimes[templateId];
    final score = _calculateScore(template, time);
    setState(() {
      _calculatedScores[templateId] = score;
    });
  }

  Future<void> _submitCheckedIndicators() async {
    final provider = context.read<IndicatorProvider>();
    final checkedTemplates = provider.templates.where((template) => _checkedTemplates[template.id] ?? false);

    for (final template in checkedTemplates) {
      final selectedDate = _selectedDates[template.id] ?? DateTime.now();
      final selectedTime = _selectedTimes[template.id];
      final score = _calculatedScores[template.id] ?? 5;

      DateTime finalDateTime = selectedDate;
      if (selectedTime != null) {
        finalDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      }

      final indicator = IndicatorModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + template.id,
        title: template.title,
        description: template.description,
        score: score,
        date: DateTime.now(),
        category: template.category,
        customDate: selectedDate,
        customTime: selectedTime?.format(context),
        targetTime: template.targetTime,
        scoreRules: template.useAutoScoring ? {
          'autoScoring': true,
          'targetTime': template.targetTime,
          'actualTime': selectedTime?.format(context),
          'calculatedScore': score,
        } : null,
      );

      await provider.addIndicator(indicator);
    }

    if (checkedTemplates.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${checkedTemplates.length} indicator berhasil dicatat!')),
      );

      setState(() {
        _checkedTemplates.clear();
        _selectedDates.clear();
        _selectedTimes.clear();
        _calculatedScores.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Log'),
        backgroundColor: Colors.green.shade100,
        actions: [
          IconButton(
            onPressed: _submitCheckedIndicators,
            icon: const Icon(Icons.save),
            tooltip: 'Simpan yang dicentang',
          ),
        ],
      ),
      body: Consumer<IndicatorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.templates.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada template indicator.\nTambahkan indicator baru terlebih dahulu.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final activeTemplates = provider.templates.where((t) => t.isActive).toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Centang indicator yang ingin dicatat, atur tanggal dan waktu, lalu klik simpan.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: activeTemplates.length,
                  itemBuilder: (context, index) {
                    final template = activeTemplates[index];
                    return _buildTemplateCard(template);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(IndicatorTemplate template) {
    final isChecked = _checkedTemplates[template.id] ?? false;
    final selectedDate = _selectedDates[template.id] ?? DateTime.now();
    final selectedTime = _selectedTimes[template.id];
    final calculatedScore = _calculatedScores[template.id];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: isChecked ? 4 : 2,
      color: isChecked ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      _checkedTemplates[template.id] = value ?? false;
                      if (value == true) {
                        _selectedDates[template.id] = DateTime.now();
                        if (template.useAutoScoring) {
                          _updateScore(template.id, template);
                        }
                      }
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        template.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(template.category),
                  backgroundColor: _getCategoryColor(template.category).withOpacity(0.2),
                ),
              ],
            ),
            
            if (isChecked) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDates[template.id] = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedTimes[template.id] = time;
                          });
                          _updateScore(template.id, template);
                        }
                      },
                      icon: const Icon(Icons.access_time, size: 16),
                      label: Text(
                        selectedTime?.format(context) ?? 'Pilih Waktu',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              if (template.useAutoScoring) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Target: ${template.targetTime}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      if (calculatedScore != null) ...[
                        const Text('Skor: ', style: TextStyle(fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getScoreColor(calculatedScore),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            calculatedScore.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Personal': Colors.blue,
      'Professional': Colors.green,
      'Health': Colors.red,
      'Education': Colors.orange,
      'Social': Colors.purple,
      'Financial': Colors.teal,
      'Prayer': Colors.indigo,
    };
    return colors[category] ?? Colors.grey;
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }
}