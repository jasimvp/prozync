import 'package:flutter/material.dart';
import 'package:prozync/features/profile/other_user_profile_screen.dart';
import 'package:prozync/features/projects/project_details_screen.dart';
import 'package:prozync/models/project_model.dart';
import 'package:prozync/core/services/project_service.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _projectService = ProjectService();

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
    
    // Filter projects from the service
    final projects = _projectService.projects.where((p) => p.isMyRepo == isMyRepo).toList();

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isWide ? 1000 : double.infinity),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 0 : 16,
            vertical: 16,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            return _buildProjectCard(context, projects[index]);
          },
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Icon(
              project.isMyRepo ? Icons.lock_outline : Icons.public, // Simplified logic
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              project.name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
             const Spacer(),
            if (project.isMyRepo) // Only allow pinning my repos
              IconButton(
                icon: Icon(
                  project.isPinned ? Icons.star : Icons.star_border,
                  color: project.isPinned ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _projectService.togglePin(project.id);
                  });
                },
                tooltip: project.isPinned ? 'Unpin' : 'Pin to Profile',
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLanguageTag(project.language, _getLanguageColor(project.language)),
                const SizedBox(width: 8),
                Text('Updated recently', style: Theme.of(context).textTheme.bodySmall), // simplified time
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserProfileScreen(
                          userName: 'DevUser',
                          userDesignation: 'Flutter Contributor',
                          userImage: 'https://i.pravatar.cc/150?u=dev1',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'by @owner',
                    style: TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ],
        ),

        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(child: Text('Download ZIP')),
            const PopupMenuItem(child: Text('Share')),
            if (project.isMyRepo) const PopupMenuItem(child: Text('Edit')),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(
                projectName: project.name,
                isPublic: !project.isMyRepo,
                description: project.description,
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

  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'flutter': return Colors.blue;
      case 'javascript': return Colors.yellow[700]!;
      case 'python': return Colors.blue[800]!;
      case 'react': return Colors.cyan;
      default: return Colors.grey;
    }
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
