import 'package:flutter/material.dart';
import '../../core/services/project_service.dart';
import '../../models/project_model.dart';

class SavedProjectsScreen extends StatelessWidget {
  const SavedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you'd likely depend on a specific 'saved' property or list.
    // Here we use the mock getter from ProjectService.
    final savedProjects = ProjectService().savedProjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Projects'),
      ),
      body: savedProjects.isEmpty
          ? const Center(child: Text('No saved projects yet.'))
          : ListView.separated(
              itemCount: savedProjects.length,
              padding: const EdgeInsets.all(16),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final project = savedProjects[index];
                return _buildSavedProjectCard(context, project);
              },
            ),
    );
  }

  Widget _buildSavedProjectCard(BuildContext context, Project project) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bookmark, color: Colors.blue)),
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
             Text(
              project.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(
                  radius: 10,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=dev_saved'),
                ),
                const SizedBox(width: 8),
                Text(
                  'by Owner',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.bookmark_remove),
          onPressed: () {
            // Implement remove logic
          },
        ),
      ),
    );
  }
}
