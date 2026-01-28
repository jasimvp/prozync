import 'package:flutter/material.dart';
import 'package:prozync/core/theme/app_theme.dart';
import 'package:prozync/core/services/profile_service.dart';
import 'package:prozync/core/services/project_service.dart';
import 'package:prozync/features/profile/other_user_profile_screen.dart';
import 'package:prozync/models/profile_model.dart';
import '../../models/project_model.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    bool isPublic = !widget.project.isPrivate;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final isOwner = ProfileService().myProfile?.id == widget.project.owner;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium Sliver App Bar with Image/Gradient
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.project.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.project.coverImage != null)
                    Image.network(
                      widget.project.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                    )
                  else
                    _buildPlaceholderImage(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {},
              ),
              if (isOwner)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) async {
                    if (value == 'delete') {
                      _handleDelete(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete Project', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                )
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Tags & Date
                    Row(
                      children: [
                        _buildBadge(
                          isPublic ? 'Public' : 'Private',
                          isPublic ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _buildBadge(widget.project.language, Colors.blue),
                        const Spacer(),
                        Text(
                          'Added ${widget.project.createdAt.day}/${widget.project.createdAt.month}/${widget.project.createdAt.year}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Owner Info & Collab Button
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${widget.project.ownerName}&background=random'),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.project.ownerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Project Owner',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (isOwner)
                          ElevatedButton.icon(
                            onPressed: () => _showCollabSheet(context),
                            icon: const Icon(Icons.person_add_outlined, size: 18),
                            label: const Text('Add Collab'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          )
                        else
                          OutlinedButton(
                            onPressed: () async {
                              await ProfileService().fetchProfiles(search: widget.project.ownerName);
                              final profile = ProfileService().profiles.firstWhere((p) => p.id == widget.project.owner);
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OtherUserProfileScreen(profile: profile),
                                  ),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('View Profile'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Collaborators Section (New)
                    if (widget.project.collaborators.isNotEmpty) ...[
                      const Text(
                        'Collaborators',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.project.collaborators.length,
                          itemBuilder: (context, index) {
                            final collab = widget.project.collaborators[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Tooltip(
                                message: collab['username'] ?? 'Collaborator',
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: collab['profile_pic'] != null 
                                      ? NetworkImage(collab['profile_pic']) 
                                      : null,
                                  child: collab['profile_pic'] == null 
                                      ? const Icon(Icons.person, size: 20) 
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Description
                    const Text(
                      'About this project',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.project.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // README Section
                    _buildReadmeSection(),
                    const SizedBox(height: 48),

                    // Action Button
                    if (widget.project.projectZip != null)
                      _buildDownloadButton(context)
                    else
                      _buildRestrictionInfo(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Image.network(
      'https://picsum.photos/seed/${widget.project.id + 100}/1200/800',
      fit: BoxFit.cover,
    );
  }

  Widget _buildReadmeSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.description_outlined, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'README.md',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              !widget.project.isPrivate
                  ? (widget.project.readme != null && widget.project.readme!.isNotEmpty
                      ? widget.project.readme!
                      : '# ${widget.project.name}\n\n'
                          'No README content provided for this project.')
                  : 'This project is private. README content is restricted to authorized collaborators only.',
              style: TextStyle(
                fontFamily: 'monospace',
                color: (!widget.project.isPrivate && widget.project.readme != null && widget.project.readme!.isNotEmpty) ? Colors.black87 : Colors.grey[600],
                fontStyle: (!widget.project.isPrivate && widget.project.readme != null && widget.project.readme!.isNotEmpty) ? FontStyle.normal : FontStyle.italic,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Starting download: ${widget.project.projectZip}')),
          );
        },
        icon: const Icon(Icons.file_download_outlined),
        label: const Text('Download Source Code (ZIP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildRestrictionInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Source code is restricted for this ${widget.project.isPrivate ? "private" : "protected"} project.',
              style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _handleDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ProjectService().deleteProject(widget.project.id);
      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project deleted')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete project')));
        }
      }
    }
  }

  void _showCollabSheet(BuildContext context) {
    final searchController = TextEditingController();
    List<Profile> searchResults = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Invite Collaborator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search developers...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                  onChanged: (value) async {
                    if (value.length > 1) {
                      setModalState(() => isSearching = true);
                      await ProfileService().fetchProfiles(search: value);
                      if (mounted) {
                        setModalState(() {
                          searchResults = ProfileService().profiles.where((p) => p.id != ProfileService().myProfile?.id).toList();
                          isSearching = false;
                        });
                      }
                    } else {
                      setModalState(() => searchResults = []);
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (isSearching)
                  const Center(child: CircularProgressIndicator())
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final profile = searchResults[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: profile.profilePic != null ? NetworkImage(profile.profilePic!) : null,
                            child: profile.profilePic == null ? const Icon(Icons.person) : null,
                          ),
                          title: Text(profile.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(profile.profession),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final success = await ProjectService().sendCollabInvitation(widget.project.id, profile.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Invitation sent to ${profile.username}!' : 'Invitation failed'),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Invite'),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
