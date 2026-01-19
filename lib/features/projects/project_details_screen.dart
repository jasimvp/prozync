import 'package:flutter/material.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectName;
  final bool isPublic;
  final String description;

  const ProjectDetailsScreen({
    super.key,
    required this.projectName,
    required this.isPublic,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          if (isPublic)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {},
            ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isPublic ? Icons.public : Icons.lock_outline,
                      color: isPublic ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPublic ? 'Public Project' : 'Private Project',
                      style: TextStyle(
                        color: isPublic ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  projectName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const Divider(height: 40),
                const Text(
                  'README.md',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    isPublic
                        ? '# $projectName\n\n'
                            'This is a professional project README.\n\n'
                            '## Getting Started\n'
                            '1. Clone the repo\n'
                            '2. Run `flutter pub get`\n'
                            '3. Run the app\n\n'
                            '## Features\n'
                            '- Responsive Design\n'
                            '- Firebase Integration\n'
                            '- Clean Architecture'
                        : 'This project is private. README content is restricted to authorized collaborators only.',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: isPublic ? Colors.black87 : Colors.grey[600],
                      fontStyle: isPublic ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (isPublic)
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading ZIP...')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download ZIP'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Downloads are disabled for private projects. Request collaboration access to download.',
                            style: TextStyle(color: Colors.orange, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
