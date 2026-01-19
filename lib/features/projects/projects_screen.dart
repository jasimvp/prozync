import 'package:flutter/material.dart';
import 'package:prozync/features/profile/other_user_profile_screen.dart';
import 'package:prozync/features/projects/project_details_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Projects'),
          actions: [
            IconButton(
              onPressed: () => _showUploadDialog(context),
              icon: const Icon(Icons.add_box_outlined),
              tooltip: 'New Project',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Repos'),
              Tab(text: 'Collaborations'),
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
          ),
        ),
        body: TabBarView(
          children: [
            _buildProjectList(context, isMyRepo: true),
            _buildProjectList(context, isMyRepo: false),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, {required bool isMyRepo}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isWide ? 1000 : double.infinity),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 0 : 16,
            vertical: 16,
          ),
          itemCount: 5,
          itemBuilder: (context, index) {
            return _buildProjectCard(context, index, isMyRepo);
          },
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, int index, bool isMyRepo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Icon(
              index % 2 == 0 ? Icons.lock_outline : Icons.public,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              isMyRepo ? 'my-awesome-project-${index + 1}' : 'collab-project-${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'A professional cross-platform mobile application built with Flutter and Firebase.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLanguageTag('Flutter', Colors.blue),
                const SizedBox(width: 8),
                Text('Updated 2h ago', style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserProfileScreen(
                          userName: 'DevUser ${index + 5}',
                          userDesignation: 'Flutter Contributor',
                          userImage: 'https://i.pravatar.cc/150?u=dev${index + 5}',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'by @dev${index + 5}',
                    style: const TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ],
        ),

        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (index % 2 == 0) const PopupMenuItem(child: Text('Download ZIP')),
            const PopupMenuItem(child: Text('Share')),
            if (isMyRepo) const PopupMenuItem(child: Text('Edit')),
          ],
        ),
        onTap: () {
          final isPublic = index % 2 != 0; // My logic for public/private in this mock
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(
                projectName: isMyRepo ? 'my-awesome-project-${index + 1}' : 'collab-project-${index + 1}',
                isPublic: isPublic,
                description: isPublic 
                    ? 'A professional cross-platform mobile application built with Flutter and Firebase.'
                    : 'Confidential development project. README and downloads restricted.',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageTag(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showRepoDetails(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'README.md',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('ZIP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                '# Awesome Flutter Project\n\n'
                'This is a sample README file for the project. It explains how to set up and run the application.\n\n'
                '## Features\n'
                '- Material 3 Design\n'
                '- Authentication\n'
                '- Collaboration Tools\n\n'
                '## Installation\n'
                '```bash\n'
                'flutter pub get\n'
                'flutter run\n'
                '```',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Project Name')),
            const TextField(decoration: InputDecoration(labelText: 'Description')),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text('Select ZIP File'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Create')),
        ],
      ),
    );
  }
}
