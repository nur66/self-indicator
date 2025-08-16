import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Map<String, dynamic>? _storageStats;
  String? _exportedJsonData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStorageStats();
  }

  Future<void> _loadStorageStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await StorageService.getStorageStats();
      setState(() => _storageStats = stats);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stats: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    try {
      final data = await StorageService.exportToJson();
      setState(() => _exportedJsonData = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data copied to clipboard!')),
      );
    }
  }

  Future<void> _debugPrintData() async {
    await StorageService.debugPrintStorageData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check console for debug output')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Storage'),
        backgroundColor: Colors.orange.shade100,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Storage Statistics Card
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                  
                  // Export Data Card
                  if (_exportedJsonData != null) _buildExportCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    if (_storageStats == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No storage stats available'),
        ),
      );
    }

    final stats = _storageStats!;
    final categories = stats['categories'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Storage Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildStatRow('Total Indicators', '${stats['total_indicators']}'),
            _buildStatRow('Data Size', '${stats['raw_data_size_kb']} KB'),
            _buildStatRow('Raw Bytes', '${stats['raw_data_size_bytes']}'),
            
            if (stats['oldest_indicator'] != null)
              _buildStatRow('Oldest Entry', stats['oldest_indicator']),
            if (stats['newest_indicator'] != null)
              _buildStatRow('Newest Entry', stats['newest_indicator']),
            
            const SizedBox(height: 12),
            const Text(
              'Categories:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...categories.entries.map((entry) => 
              _buildStatRow('  ${entry.key}', '${entry.value}')),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Debug Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadStorageStats,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Stats'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                      foregroundColor: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _debugPrintData,
                    icon: const Icon(Icons.print),
                    label: const Text('Print to Console'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade100,
                      foregroundColor: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportData,
                icon: const Icon(Icons.download),
                label: const Text('Export JSON Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.file_download, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Exported Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _copyToClipboard(_exportedJsonData!),
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy to Clipboard',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _exportedJsonData!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data length: ${_exportedJsonData!.length} characters',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}