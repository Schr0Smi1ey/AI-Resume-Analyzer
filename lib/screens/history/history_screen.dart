import 'package:flutter/material.dart';
import '../../services/history_service.dart';
import 'package:uuid/uuid.dart';
import '../../model/analysis_model.dart';
import '../resume_analysis/resume_analysis_screen.dart';

class HistoryScreen extends StatefulWidget {
  static const String routeName = '/history';
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<List<AnalysisModel>>? _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistory(); // Reload history when dependencies change (e.g., screen revisited)
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = HistoryService().getHistory();
    });
  }

  Future<void> _confirmAndDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => _buildConfirmationDialog(
            ctx,
            title: 'Confirm Clear All',
            content: 'Remove all analysis history?',
          ),
    );

    if (confirmed == true) {
      try {
        await HistoryService().clearHistory();
        _loadHistory();
        if (!mounted) return;
        _showSnackBar('Cleared all history');
      } catch (e) {
        if (!mounted) return;
        _showSnackBar(
          'Failed to clear history: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  Future<bool?> _confirmAndDeleteSingle(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => _buildConfirmationDialog(
            ctx,
            title: 'Confirm Delete',
            content: 'Remove this analysis from history?',
          ),
    );

    if (confirmed == true) {
      try {
        await HistoryService().deleteAnalysis(id);
        _loadHistory();
        if (!mounted) return true;
        _showSnackBar('Analysis deleted');
        return true;
      } catch (e) {
        if (!mounted) return false;
        _showSnackBar('Failed to delete: ${e.toString()}', isError: true);
        return false;
      }
    }
    return false;
  }

  Widget _buildConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);

    return AlertDialog(
      title: Text(title, style: TextStyle(color: textColor)),
      content: Text(
        content,
        style: TextStyle(color: textColor.withOpacity(0.8)),
      ),
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel', style: TextStyle(color: accentColor)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Confirm', style: TextStyle(color: accentColor)),
        ),
      ],
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final backgroundColor =
        isError
            ? Colors.red.withOpacity(0.8)
            : (isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50))
                .withOpacity(0.8);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define theme-dependent colors
    final primaryColor = const Color(0xFF00C853); // Motivating green
    final accentColor =
        isDark ? const Color(0xFF00E676) : const Color(0xFF4CAF50);
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFE8F5E9);
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final secondaryTextColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF757575);

    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis History', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            tooltip: 'Refresh History',
            onPressed: _loadHistory,
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep, color: accentColor),
            tooltip: 'Clear All History',
            onPressed: _confirmAndDeleteAll,
          ),
        ],
      ),
      body: Container(
        color: backgroundColor,
        child:
            _historyFuture == null
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : FutureBuilder<List<AnalysisModel>>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading history: ${snapshot.error}',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    }
                    final historyItems = snapshot.data ?? [];
                    if (historyItems.isEmpty) {
                      return Center(
                        child: Text(
                          'No analysis history available.',
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: historyItems.length,
                      itemBuilder: (context, index) {
                        final item = historyItems[index];
                        // Fallback for unexpected null ID
                        final itemId = item.id;
                        return Dismissible(
                          key: Key(itemId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await _confirmAndDeleteSingle(itemId);
                          },
                          onDismissed: (direction) {
                            // The deletion is already handled in confirmDismiss
                          },
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: accentColor.withOpacity(0.5),
                              ),
                            ),
                            color:
                                isDark
                                    ? const Color(0xFF1B5E20).withOpacity(0.3)
                                    : Colors.white,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: primaryColor,
                                child: Text(
                                  item.atsScore.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                item.metadata.name.isNotEmpty
                                    ? item.metadata.name
                                    : 'Unnamed Resume',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'ATS: ${item.atsScore} | Grammar: ${item.grammarScore} | Job Match: ${item.jobMatchScore}',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Analyzed: ${item.formattedTimestamp}',
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.open_in_new,
                                  color: accentColor,
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    ResumeAnalysisScreen.routeName,
                                    arguments: {
                                      'fileName':
                                          item.metadata.name.isNotEmpty
                                              ? item.metadata.name
                                              : 'Resume Analysis',
                                      'preloadedAnalysis': item,
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
    );
  }
}
