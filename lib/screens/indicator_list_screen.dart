import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/indicator_provider.dart';
import '../models/indicator_model.dart';

class IndicatorListScreen extends StatelessWidget {
  const IndicatorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Indicator'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Consumer<IndicatorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.indicators.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada indicator.\nTambahkan indicator dengan menekan tombol +',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.indicators.length,
            itemBuilder: (context, index) {
              final indicator = provider.indicators[index];
              return _buildIndicatorCard(context, indicator, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildIndicatorCard(BuildContext context, IndicatorModel indicator, IndicatorProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: ListTile(
        title: Text(
          indicator.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(indicator.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    indicator.category,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getCategoryColor(indicator.category).withOpacity(0.2),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(indicator.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _getScoreColor(indicator.score),
              child: Text(
                indicator.score.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, indicator, provider),
            ),
          ],
        ),
        onTap: () => _showIndicatorDetail(context, indicator),
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

  void _showDeleteDialog(BuildContext context, IndicatorModel indicator, IndicatorProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Indicator'),
        content: Text('Apakah Anda yakin ingin menghapus indicator "${indicator.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteIndicator(indicator.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Indicator berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showIndicatorDetail(BuildContext context, IndicatorModel indicator) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(indicator.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kategori: ${indicator.category}'),
            const SizedBox(height: 8),
            Text('Skor: ${indicator.score}/10'),
            const SizedBox(height: 8),
            Text('Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(indicator.date)}'),
            const SizedBox(height: 8),
            Text('Deskripsi: ${indicator.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}