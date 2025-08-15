import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/indicator_model.dart';
import '../providers/indicator_provider.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetTimeController = TextEditingController();
  String _selectedCategory = 'Personal';
  int _score = 5;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay? _targetTime;
  bool _useCustomDateTime = false;
  bool _useAutoScoring = false;
  String _selectedLocation = 'Mesjid';
  String _selectedState = 'Berjamaah';

  final List<String> _categories = [
    'Personal',
    'Professional',
    'Health',
    'Education',
    'Social',
    'Financial',
    'Prayer'
  ];

  final List<String> _locations = ['Mesjid', 'Rumah'];
  final List<String> _states = ['Berjamaah', 'Sendiri'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetTimeController.dispose();
    super.dispose();
  }

  int _calculateAutoScore() {
    if (!_useAutoScoring) {
      return _score;
    }

    int totalScore = 0;

    // 1. Skor Lokasi
    totalScore += _selectedLocation == 'Mesjid' ? 2 : 0;

    // 2. Skor Keadaan
    totalScore += _selectedState == 'Berjamaah' ? 3 : 1;

    // 3. Skor Ketepatan Waktu
    if (_targetTime != null && _selectedTime != null) {
      final targetMinutes = _targetTime!.hour * 60 + _targetTime!.minute;
      final actualMinutes = _selectedTime!.hour * 60 + _selectedTime!.minute;
      final diffMinutes = actualMinutes - targetMinutes;

      if (diffMinutes <= 0) {
        totalScore += 5; // Tepat waktu atau lebih awal
      } else if (diffMinutes <= 10) {
        totalScore += 4; // 1-10 menit terlambat
      } else if (diffMinutes <= 15) {
        totalScore += 3; // 11-15 menit terlambat
      } else if (diffMinutes <= 30) {
        totalScore += 2; // 16-30 menit terlambat
      } else {
        totalScore += 1; // Lebih dari 30 menit terlambat
      }
    } else {
      totalScore += 3; // Default nilai jika waktu tidak diset
    }

    return totalScore.clamp(1, 10); // Pastikan skor antara 1-10
  }

  int _getTimeScore() {
    if (_targetTime == null || _selectedTime == null) return 3;
    
    final targetMinutes = _targetTime!.hour * 60 + _targetTime!.minute;
    final actualMinutes = _selectedTime!.hour * 60 + _selectedTime!.minute;
    final diffMinutes = actualMinutes - targetMinutes;

    if (diffMinutes <= 0) return 5;
    if (diffMinutes <= 10) return 4;
    if (diffMinutes <= 15) return 3;
    if (diffMinutes <= 30) return 2;
    return 1;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final finalScore = _useAutoScoring ? _calculateAutoScore() : _score;
      
      final indicator = IndicatorModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        score: finalScore,
        date: DateTime.now(),
        category: _selectedCategory,
        customDate: _useCustomDateTime ? _selectedDate : null,
        customTime: _selectedTime != null ? _selectedTime!.format(context) : null,
        targetTime: _targetTime != null ? _targetTime!.format(context) : null,
        scoreRules: _useAutoScoring ? {
          'autoScoring': true,
          'targetTime': _targetTime != null ? _targetTime!.format(context) : null,
          'actualTime': _selectedTime != null ? _selectedTime!.format(context) : null,
          'location': _selectedLocation,
          'state': _selectedState,
          'calculatedScore': finalScore,
          'locationScore': _selectedLocation == 'Mesjid' ? 2 : 0,
          'stateScore': _selectedState == 'Berjamaah' ? 3 : 1,
        } : null,
      );

      context.read<IndicatorProvider>().addIndicator(indicator);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Indicator berhasil ditambahkan! Skor: $finalScore')),
      );
      
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Indicator'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.green.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade400],
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_task, color: Colors.white, size: 30),
                        SizedBox(width: 12),
                        Text(
                          'Buat Indicator Baru',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Form Fields
                _buildFormCard(
                  title: 'Informasi Dasar',
                  icon: Icons.info_outline,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Judul Indicator',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: Icon(
                          _getCategoryIcon(_selectedCategory),
                          color: _getCategoryColor(_selectedCategory),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                color: _getCategoryColor(category),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Date Time Settings
                _buildFormCard(
                  title: 'Pengaturan Waktu',
                  icon: Icons.schedule,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SwitchListTile(
                        title: const Text('Gunakan Tanggal & Waktu Khusus'),
                        subtitle: const Text('Set tanggal dan waktu tertentu'),
                        value: _useCustomDateTime,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _useCustomDateTime = value;
                          });
                        },
                      ),
                    ),
                    if (_useCustomDateTime) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                }
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _selectedDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                    : 'Pilih Tanggal',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _selectedTime ?? TimeOfDay.now(),
                                );
                                if (time != null) {
                                  setState(() {
                                    _selectedTime = time;
                                  });
                                }
                              },
                              icon: const Icon(Icons.access_time),
                              label: Text(
                                _selectedTime != null
                                    ? _selectedTime!.format(context)
                                    : 'Pilih Waktu',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                
                // Scoring Settings
                _buildFormCard(
                  title: 'Mode Penilaian',
                  icon: Icons.score,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _useAutoScoring ? Colors.orange.shade300 : Colors.grey.shade300,
                        ),
                        color: _useAutoScoring ? Colors.orange.shade50 : null,
                      ),
                      child: SwitchListTile(
                        title: Row(
                          children: [
                            Icon(
                              _useAutoScoring ? Icons.auto_awesome : Icons.edit,
                              color: _useAutoScoring ? Colors.orange : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _useAutoScoring ? 'Penilaian Otomatis' : 'Penilaian Manual',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _useAutoScoring ? Colors.orange.shade700 : null,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          _useAutoScoring 
                              ? 'Skor dihitung otomatis berdasarkan ketepatan waktu'
                              : 'Tentukan skor secara manual (1-10)',
                        ),
                        value: _useAutoScoring,
                        activeColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _useAutoScoring = value;
                          });
                        },
                      ),
                    ),
                    if (_useAutoScoring) ...[
                      const SizedBox(height: 16),
                      
                      // Lokasi Selection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.blue.shade600, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Lokasi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '+${_selectedLocation == 'Mesjid' ? 2 : 0} poin',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: _locations.map((location) {
                                final isSelected = _selectedLocation == location;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _selectedLocation = location;
                                        });
                                      },
                                      icon: Icon(
                                        location == 'Mesjid' ? Icons.mosque : Icons.home,
                                        size: 18,
                                      ),
                                      label: Text(location),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isSelected 
                                            ? Colors.blue.shade600 
                                            : Colors.grey.shade200,
                                        foregroundColor: isSelected 
                                            ? Colors.white 
                                            : Colors.grey.shade700,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Keadaan Selection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people, color: Colors.green.shade600, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Keadaan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '+${_selectedState == 'Berjamaah' ? 3 : 1} poin',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: _states.map((state) {
                                final isSelected = _selectedState == state;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _selectedState = state;
                                        });
                                      },
                                      icon: Icon(
                                        state == 'Berjamaah' ? Icons.groups : Icons.person,
                                        size: 18,
                                      ),
                                      label: Text(state),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isSelected 
                                            ? Colors.green.shade600 
                                            : Colors.grey.shade200,
                                        foregroundColor: isSelected 
                                            ? Colors.white 
                                            : Colors.grey.shade700,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Target Waktu
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_alarm, color: Colors.orange.shade600, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Waktu Target',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                if (_targetTime != null && _selectedTime != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '+${_getTimeScore()} poin',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _targetTime ?? const TimeOfDay(hour: 5, minute: 0),
                                );
                                if (time != null) {
                                  setState(() {
                                    _targetTime = time;
                                  });
                                }
                              },
                              icon: const Icon(Icons.access_alarm),
                              label: Text(
                                _targetTime != null
                                    ? 'Target: ${_targetTime!.format(context)}'
                                    : 'Set Target Waktu',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade100,
                                foregroundColor: Colors.orange.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Scoring Rules
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.purple.shade600, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Aturan Penilaian:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '📍 Lokasi: Mesjid (+2), Rumah (+0)\n'
                              '👥 Keadaan: Berjamaah (+3), Sendiri (+1)\n'
                              '⏰ Waktu: Tepat (+5), <10 menit (+4), 11-15 menit (+3), 16-30 menit (+2), >30 menit (+1)',
                              style: TextStyle(fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                
                // Score Input/Display
                if (!_useAutoScoring) 
                  _buildFormCard(
                    title: 'Tentukan Skor',
                    icon: Icons.star_rate,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Skor:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(_score),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _score.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: _getScoreColor(_score),
                                thumbColor: _getScoreColor(_score),
                                overlayColor: _getScoreColor(_score).withOpacity(0.2),
                                valueIndicatorColor: _getScoreColor(_score),
                              ),
                              child: Slider(
                                value: _score.toDouble(),
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: _score.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _score = value.round();
                                  });
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('1', style: TextStyle(color: Colors.grey.shade600)),
                                Text('10', style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else if (_useAutoScoring)
                  _buildFormCard(
                    title: 'Skor Terhitung',
                    icon: Icons.auto_awesome,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calculate, color: Colors.green.shade600),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Skor otomatis berdasarkan 3 kriteria',
                                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(_calculateAutoScore()),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _calculateAutoScore().toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.location_on, color: Colors.blue.shade600, size: 16),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Lokasi',
                                          style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                                        ),
                                        Text(
                                          '+${_selectedLocation == 'Mesjid' ? 2 : 0}',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.people, color: Colors.green.shade600, size: 16),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Keadaan',
                                          style: TextStyle(fontSize: 10, color: Colors.green.shade700),
                                        ),
                                        Text(
                                          '+${_selectedState == 'Berjamaah' ? 3 : 1}',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.access_time, color: Colors.orange.shade600, size: 16),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Waktu',
                                          style: TextStyle(fontSize: 10, color: Colors.orange.shade700),
                                        ),
                                        Text(
                                          '+${_getTimeScore()}',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),
                
                // Submit Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade400],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade300,
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Simpan Indicator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.blue.shade600),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Personal':
        return Icons.person;
      case 'Professional':
        return Icons.work;
      case 'Health':
        return Icons.health_and_safety;
      case 'Education':
        return Icons.school;
      case 'Social':
        return Icons.people;
      case 'Financial':
        return Icons.attach_money;
      case 'Prayer':
        return Icons.mosque;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Personal':
        return Colors.blue;
      case 'Professional':
        return Colors.green;
      case 'Health':
        return Colors.red;
      case 'Education':
        return Colors.orange;
      case 'Social':
        return Colors.purple;
      case 'Financial':
        return Colors.teal;
      case 'Prayer':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }
}