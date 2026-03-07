import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/language_provider.dart';

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
    if (!mounted) return;

    setState(() => _loading = true);

    try {
      final data = await _supabaseService.getHistory();
      if (!mounted) return;

      setState(() {
        _items = data;
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteItem(int index) async {
    if (index >= _items.length) return;

    final item = _items[index];
    final String id = item['id']?.toString() ?? '';
    final t = AppLocalizations.of(context);

    try {
      await _supabaseService.deleteHistoryItem(id);
      if (!mounted) return;

      setState(() {
        _items.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.text('history_deleted'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t.text('delete_failed')}: $e'),
        ),
      );
    }
  }

  String _localizeLabel(BuildContext context, String? rawLabel) {
    if (rawLabel == null) return AppLocalizations.of(context).text('unknown');
    return AppLocalizations.of(context).text(rawLabel);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.text('history')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              // Cycle EN → RU → AR → EN
              if (provider.isEnglish) {
                provider.setRussian();
              } else if (provider.isRussian) {
                provider.setArabic();
              } else {
                provider.setEnglish();
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(child: Text(t.text('no_history')))
              : RefreshIndicator(
                  onRefresh: _loadHistoryFromSupabase,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, idx) {
                      final r = _items[idx];

                      return Dismissible(
                        key: Key(r['id']?.toString() ?? idx.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) => _deleteItem(idx),
                        child: ListTile(
                          leading: (r['image_url'] != null &&
                                  r['image_url'].toString().isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: r['image_url'],
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget:
                                      (context, url, error) =>
                                          const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.image),
                          title: Text(
                            _localizeLabel(
                                context, r['predicted_label']),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              if (r['confidence'] != null)
                                Text(
                                  '${t.text('confidence')}: '
                                  '${((r['confidence'] as num) * 100).toStringAsFixed(2)}%',
                                ),
                              Text(
                                _formatDate(r['created_at']),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
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
      final DateTime dateTime =
          DateTime.parse(date.toString()).toLocal();

      return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
          '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return date.toString();
    }
  }
}