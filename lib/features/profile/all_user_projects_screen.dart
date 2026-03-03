import 'package:flutter/material.dart';
import 'package:prozync/models/project_model.dart';
import 'package:prozync/models/profile_model.dart';
import 'package:prozync/core/theme/app_theme.dart';
import 'package:prozync/features/projects/project_details_screen.dart';

class AllUserProjectsScreen extends StatelessWidget {
  final Profile profile;
  final List<Project> projects;

  const AllUserProjectsScreen({
    super.key,
    required this.profile,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${profile.fullName}\'s Projects',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_rounded,
                      size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No projects yet',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return _buildProjectCard(context, projects[index]);
              },
            ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(project: project),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Project icon / thumbnail
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (project.isPrivate ? Colors.orange : AppTheme.primaryColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  image: project.coverImage != null
                      ? DecorationImage(
                          image: NetworkImage(project.coverImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: project.coverImage == null
                    ? Icon(
                        project.isPrivate
                            ? Icons.lock_outline
                            : Icons.code_rounded,
                        color: project.isPrivate
                            ? Colors.orange
                            : AppTheme.primaryColor,
                        size: 26,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Title & description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Technology badge
                    if (project.technology.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          project.technology,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
