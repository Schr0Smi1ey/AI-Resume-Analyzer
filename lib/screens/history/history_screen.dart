import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> historyItems = [
      {
        'date': '2023-06-15',
        'filename': 'my_resume_v3.pdf',
        'score': 85,
        'summary': 'Strong technical skills, could add more metrics',
      },
      {
        'date': '2023-05-28',
        'filename': 'resume_final.docx',
        'score': 78,
        'summary': 'Good structure, needs more projects',
      },
      {
        'date': '2023-04-10',
        'filename': 'old_resume.pdf',
        'score': 62,
        'summary': 'Basic resume, needs improvement',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyItems.length,
        itemBuilder: (context, index) {
          final item = historyItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: _getScoreColor(item['score']),
                child: Text('${item['score']}'),
              ),
              title: Text(item['filename']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(item['date']),
                  const SizedBox(height: 8),
                  Text(
                    item['summary'],
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    return Colors.orange;
  }
}
