import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/indicator_provider.dart';
import '../models/indicator_model.dart';
import 'indicator_list_screen.dart';
import 'form_screen.dart';
import 'debug_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DebugScreen()),
              );
            },
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Storage',
          ),
        ],
      ),
      body: Consumer<IndicatorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.indicators.isNotEmpty) ...[
                  _buildSummaryCard(provider),
                  const SizedBox(height: 20),
                ],
                _buildCategoryMenu(context, provider),
                if (provider.indicators.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildScoreChart(provider.indicators),
                  const SizedBox(height: 20),
                  _buildCategoryChart(provider.indicators),
                  const SizedBox(height: 20),
                  _buildRecentIndicators(provider.indicators),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryMenu(BuildContext context, IndicatorProvider provider) {
    final categories = [
      {'name': 'Personal', 'icon': Icons.person, 'color': Colors.blue},
      {'name': 'Professional', 'icon': Icons.work, 'color': Colors.green},
      {'name': 'Health', 'icon': Icons.health_and_safety, 'color': Colors.red},
      {'name': 'Education', 'icon': Icons.school, 'color': Colors.orange},
      {'name': 'Social', 'icon': Icons.people, 'color': Colors.purple},
      {'name': 'Financial', 'icon': Icons.attach_money, 'color': Colors.teal},
      {'name': 'Prayer', 'icon': Icons.mosque, 'color': Colors.indigo},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  child: Icon(Icons.category, color: Colors.blue.shade600),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kategori Indicator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryName = category['name'] as String;
                final categoryIcon = category['icon'] as IconData;
                final categoryColor = category['color'] as Color;
                
                final indicatorCount = provider.indicators
                    .where((indicator) => indicator.category == categoryName)
                    .length;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        categoryColor.withOpacity(0.1),
                        categoryColor.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Header dengan icon dan count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                categoryIcon,
                                color: categoryColor,
                                size: 20,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                indicatorCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Category name
                        Text(
                          categoryName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getDarkerColor(categoryColor),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        // Buttons
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // View indicators button
                              if (indicatorCount > 0)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => IndicatorListScreen(
                                            categoryFilter: categoryName,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.list, size: 16),
                                    label: const Text(
                                      'Lihat',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: categoryColor.withOpacity(0.1),
                                      foregroundColor: categoryColor,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              if (indicatorCount > 0) const SizedBox(height: 6),
                              
                              // Add indicator button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => FormScreen(
                                          preSelectedCategory: categoryName,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text(
                                    'Tambah',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: categoryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(IndicatorProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Total Indicator',
                  provider.indicators.length.toString(),
                  Colors.blue,
                ),
                _buildSummaryItem(
                  'Rata-rata Skor',
                  provider.getAverageScore().toStringAsFixed(1),
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildScoreChart(List<IndicatorModel> indicators) {
    final groupedByDate = <String, List<IndicatorModel>>{};
    for (final indicator in indicators) {
      final dateKey = indicator.displayDate;
      groupedByDate.putIfAbsent(dateKey, () => []).add(indicator);
    }

    final sortedDates = groupedByDate.keys.toList()..sort();
    final dailyAverages = sortedDates.map((date) {
      final dayIndicators = groupedByDate[date]!;
      final average = dayIndicators.fold(0.0, (sum, indicator) => sum + indicator.score) / dayIndicators.length;
      return average;
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trend Skor Harian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedDates.length) {
                            final date = DateTime.parse(sortedDates[index]);
                            return Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                DateFormat('dd/MM').format(date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: sortedDates.isNotEmpty ? (sortedDates.length - 1).toDouble() : 0,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyAverages.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total ${indicators.length} indicator dalam ${sortedDates.length} hari',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(List<IndicatorModel> indicators) {
    final categoryMap = <String, int>{};
    for (final indicator in indicators) {
      categoryMap[indicator.category] = (categoryMap[indicator.category] ?? 0) + 1;
    }

    final sections = categoryMap.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribusi Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
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

  Color _getDarkerColor(Color color) {
    // Create a darker version of the color by reducing the lightness
    final hsl = HSLColor.fromColor(color);
    final darkHsl = hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0));
    return darkHsl.toColor();
  }

  Widget _buildRecentIndicators(List<IndicatorModel> indicators) {
    final recentIndicators = indicators.take(5).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Indicator Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...recentIndicators.map((indicator) => ListTile(
              title: Text(indicator.title),
              subtitle: Text(indicator.category),
              trailing: CircleAvatar(
                backgroundColor: _getScoreColor(indicator.score),
                child: Text(
                  indicator.score.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }
}