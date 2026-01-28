import 'package:flutter/material.dart';
import '../../models/project_model.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final Project project;

  ProjectDetailsScreen({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    bool isPublic = !project.isPrivate;
    
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
                  project.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  project.description,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Technology: ${project.language}',
                  style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w500),
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
                        ? '# ${project.name}\n\n'
                            'Slug: ${project.slug}\n\n'
                            'This is a professional project README sync\'d from ProSync.\n\n'
                            '## Getting Started\n'
                            '1. Clone the repo\n'
                            '2. Run `flutter pub get`\n'
                            '3. Run the app\n\n'
                            '## Stats\n'
                            '- Collaborators: ${project.collaboratorCount}'
                        : 'This project is private. README content is restricted to authorized collaborators only.',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: isPublic ? Colors.black87 : Colors.grey[600],
                      fontStyle: isPublic ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (project.projectZip != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading: ${project.projectZip}')),
                      );
                      // In a real app, use url_launcher or similar
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Project Source (ZIP)'),
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
                            'No ZIP file available for this project or access is restricted.',
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
