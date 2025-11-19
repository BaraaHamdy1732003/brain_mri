import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadHistoryFromSupabase();
  }

  Future<void> _loadHistoryFromSupabase() async {
    setState(() {
      _loading = true;
    });

    try {
      _items = await _supabaseService.getHistory();
    } catch (e) {
      debugPrint('❌ Error loading history from Supabase: $e');
      // Optionally fall back to local storage here
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _deleteItem(int index) async {
    final item = _items[index];
    final String id = item['id']?.toString() ?? '';

    try {
      await _supabaseService.deleteHistoryItem(id);
      setState(() {
        _items.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History item deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No history yet'))
              : RefreshIndicator(
                  onRefresh: _loadHistoryFromSupabase,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (_, idx) {
                      final r = _items[idx];
                      return Dismissible(
                        key: Key(r['id']?.toString() ?? idx.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteItem(idx),
                        child: ListTile(
                          leading: r['image_url'] != null && r['image_url'] != ''
                              ? CachedNetworkImage(
                                  imageUrl: r['image_url'],
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => 
                                      const CircularProgressIndicator(),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.image),
                          title: Text(r['predicted_label'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (r['confidence'] != null)
                                Text(
                                  'Confidence: ${((r['confidence'] as double) * 100).toStringAsFixed(2)}%',
                                ),
                              Text(
                                _formatDate(r['created_at']),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final DateTime dateTime = DateTime.parse(date.toString()).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date.toString();
    }
  }
}