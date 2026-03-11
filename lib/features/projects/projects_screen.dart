import 'package:flutter/material.dart';
import 'package:prozync/features/profile/other_user_profile_screen.dart';
import 'package:prozync/features/projects/project_details_screen.dart';
import 'package:prozync/models/project_model.dart';
import 'package:prozync/core/services/project_service.dart';
import 'package:prozync/core/theme/app_theme.dart';
import 'package:prozync/core/services/profile_service.dart';
import 'package:prozync/features/projects/upload_project_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    _projectService.fetchProjects();
    _projectService.fetchMyRepos();
    _projectService.fetchInvitations();
    ProfileService().fetchMyProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_projectService, ProfileService()]),
      builder: (context, _) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Projects Explorer'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UploadProjectScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 28),
                  tooltip: 'New Project',
                ),
                const SizedBox(width: 8),
              ],
              bottom: TabBar(
                tabs: [
                  Tab(text: 'My Portfolio'),
                  Tab(text: 'Collaborations'),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Invitations'),
                        if (_projectService.invitations
                            .where((i) => i.status.toUpperCase() == 'PENDING')
                            .isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _projectService.invitations
                                  .where(
                                    (i) => i.status.toUpperCase() == 'PENDING',
                                  )
                                  .length
                                  .toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                indicatorColor: AppTheme.primaryColor,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                onTap: (index) {
                  // Refresh invitations when the Invitations tab is tapped
                  if (index == 2) {
                    _projectService.fetchInvitations();
                  }
                },
              ),
            ),
            body: _projectService.isMyReposLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _buildProjectList(
                        context,
                        projects: _projectService.myRepos,
                      ),
                      _buildProjectList(
                        context,
                        projects: _projectService.projects
                            .where(
                              (p) =>
                                  p.owner != ProfileService().myProfile?.id &&
                                  p.collaborators.any(
                                    (c) =>
                                        (c is Map
                                            ? (c['uid']?.toString() ??
                                                  c['id']?.toString() ??
                                                  '')
                                            : c.toString()) ==
                                        ProfileService().myProfile?.id,
                                  ),
                            )
                            .toList(),
                      ),
                      _buildInvitationsList(context),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildProjectList(
    BuildContext context, {
    required List<Project> projects,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No projects yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your journey by creating one.',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _projectService.fetchProjects(),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Refresh Feed'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isWide ? 1000 : double.infinity),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 0 : 20,
            vertical: 20,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            return _buildProjectCard(context, projects[index]);
          },
        ),
      ),
    );
  }

  Widget _buildInvitationsList(BuildContext context) {
    final invitations = _projectService.invitations
        .where((i) => i.status.toUpperCase() == 'PENDING')
        .toList();

    if (_projectService.isLoading && invitations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No pending invitations',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final invite = invitations[index];
        return _buildInviteItem(context, invite);
      },
    );
  }

  Widget _buildInviteItem(BuildContext context, dynamic invite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.group_add_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.projectName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'from @${invite.senderName}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleInviteResponse(invite.id, 'REJECTED'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleInviteResponse(invite.id, 'ACCEPTED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    final isOwner = ProfileService().myProfile?.id == project.owner;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailsScreen(project: project),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (project.isPrivate ? Colors.orange : Colors.blue)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        project.isPrivate
                            ? Icons.lock_outline
                            : Icons.code_rounded,
                        color: project.isPrivate ? Colors.orange : Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              _buildLanguageDot(
                                _getLanguageColor(project.language),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                project.language,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildTypeTag(project.projectType),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListenableBuilder(
                          listenable: Listenable.merge([
                            _projectService,
                            ProfileService(),
                          ]),
                          builder: (context, _) {
                            final currentProject = _projectService
                                .getProjectById(project.id, project);
                            final isOwner =
                                ProfileService().myProfile?.id ==
                                currentProject.owner;

                            return IconButton(
                              icon: Icon(
                                currentProject.isPinned
                                    ? (isOwner
                                          ? Icons.push_pin
                                          : Icons.bookmark_rounded)
                                    : (isOwner
                                          ? Icons.push_pin_outlined
                                          : Icons.bookmark_border_rounded),
                                color: currentProject.isPinned
                                    ? (isOwner ? Colors.blue : Colors.amber)
                                    : Colors.grey[400],
                              ),
                              onPressed: () async {
                                final success = await _projectService.togglePin(
                                  project.id,
                                );
                                if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to update pin status',
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                        if (isOwner)
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.grey[400],
                            ),
                            onSelected: (value) async {
                              if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Project'),
                                    content: const Text(
                                      'Are you sure you want to delete this project?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await _projectService.deleteProject(
                                    project.id,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Project deleted'),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    project.fullCoverImage,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.grey[300],
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  project.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          await ProfileService().fetchProfiles(
                            search: project.ownerName,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            final profile = ProfileService().profiles
                                .firstWhere((p) => p.id == project.owner);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OtherUserProfileScreen(profile: profile),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not load profile'),
                              ),
                            );
                          }
                        }
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(
                              'https://ui-avatars.com/api/?name=${project.ownerName}&background=random',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '@${project.ownerName}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ListenableBuilder(
                      listenable: _projectService,
                      builder: (context, _) {
                        final currentProject = _projectService.getProjectById(
                          project.id,
                          project,
                        );
                        return Row(
                          children: [
                            InkWell(
                              onTap: () =>
                                  _projectService.likeProject(project.id),
                              child: Row(
                                children: [
                                  Icon(
                                    currentProject.isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 16,
                                    color: currentProject.isLiked
                                        ? Colors.red
                                        : Colors.grey[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    currentProject.likeCount.toString(),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Updated recently',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildTypeTag(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'flutter':
        return Colors.blue;
      case 'javascript':
        return Colors.yellow[700]!;
      case 'python':
        return Colors.blue[800]!;
      case 'react':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleInviteResponse(String id, String status) async {
    final success = await _projectService.respondToInvitation(id, status);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Invitation ${status.toLowerCase()} successfully'
              : 'Failed to respond to invitation',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
