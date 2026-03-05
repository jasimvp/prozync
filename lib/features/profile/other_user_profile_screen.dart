import 'package:flutter/material.dart';
import 'package:prozync/features/activity/chat_screen.dart';
import 'package:prozync/features/projects/project_details_screen.dart';
import 'package:prozync/features/profile/all_user_projects_screen.dart';
import 'package:prozync/models/project_model.dart';
import 'package:prozync/models/profile_model.dart';
import 'package:prozync/core/theme/app_theme.dart';
import 'package:prozync/core/services/profile_service.dart';
import 'package:prozync/core/services/project_service.dart';
import 'package:prozync/widgets/mention_text.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final Profile profile;

  OtherUserProfileScreen({super.key, required this.profile});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}
class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  late Profile _currentProfile;
  bool isFollowing = false;
  List<Project> userProjects = [];
  bool isLoadingProjects = true;
  bool _isLoadingProfile = true;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    final status = _currentProfile.connectionStatus.toLowerCase();
    isFollowing = status == 'following' || status == 'followed';
    _loadUserProjects();
    _fetchFullProfile();
  }

  Future<void> _fetchFullProfile({bool updateFollowStatus = true}) async {
    try {
      final profile = await ProfileService().fetchProfileById(_currentProfile.id);
      if (profile != null && mounted) {
        setState(() {
          _currentProfile = profile;
          
          if (updateFollowStatus) {
            final status = profile.connectionStatus.toLowerCase();
            isFollowing = status == 'following' || status == 'followed';
          }
          
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _loadUserProjects() async {
    try {
      // Fetch projects for this user using their user ID (not profile ID)
      // project.owner is the Django User ID, which matches profile.user
      await ProjectService().fetchProjects(
        search: widget.profile.username,
      );
      if (mounted) {
        setState(() {
          // Compare against profile.user (User ID), not profile.id (Profile ID)
          userProjects = ProjectService().projects
              .where((p) => p.owner == widget.profile.user)
              .toList();
          isLoadingProjects = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingProjects = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildActionButtons(context),
                const SizedBox(height: 32),
                _buildStatsRow(context),
                const SizedBox(height: 32),
                _buildAboutSection(context),
                const SizedBox(height: 32),
                _buildWorksSection(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.indigo[900]!, Colors.indigo[600]!],
                ),
              ),
            ),
            // Abstract Circles for style
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Profile Info
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: NetworkImage(_currentProfile.fullProfilePic),
                    onBackgroundImageError: (exception, stackTrace) {
                      debugPrint('Error loading other user profile pic: $exception');
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentProfile.fullName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _currentProfile.profession,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.blue[200],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Remote', // You might want to add location to Profile model if available
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isActionInProgress ? null : () async {
                  setState(() {
                    _isActionInProgress = true;
                  });

                  // Optimistic UI update
                  bool previouslyFollowing = isFollowing;
                  setState(() {
                    isFollowing = !isFollowing;
                  });

                  final result = await ProfileService().followProfile(
                    _currentProfile.id,
                  );
                  
                  if (result != null && mounted) {
                    // result will be "Followed" or "Unfollowed"
                    setState(() {
                      isFollowing = result.toLowerCase() == 'followed' || result.toLowerCase() == 'following';
                      _currentProfile = _currentProfile.copyWith(
                        connectionStatus: isFollowing ? 'following' : '',
                      );
                      _isActionInProgress = false;
                    });
                    // Refresh counts but DON'T let it overwrite our new status
                    _fetchFullProfile(updateFollowStatus: false);
                  } else if (mounted) {
                    // Revert on failure
                    setState(() {
                      isFollowing = previouslyFollowing;
                      _isActionInProgress = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update follow status')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? Colors.grey[200]
                      : AppTheme.primaryColor,
                  foregroundColor: isFollowing ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: _currentProfile.user,
                        userName: _currentProfile.fullName,
                        userImage:
                            _currentProfile.profilePic ??
                            'https://ui-avatars.com/api/?name=${_currentProfile.fullName}',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                ),
                child: const Text(
                  'Message',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              _currentProfile.repoCount,
              'Projects',
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatItem(
              context,
              _currentProfile.followerCount,
              'Followers',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.2));
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
              child: MentionText(
                text: _currentProfile.bio.isNotEmpty
                    ? _currentProfile.bio
                    : 'No bio provided.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorksSection(BuildContext context) {
    const int previewLimit = 3;
    final previewProjects = userProjects.take(previewLimit).toList();
    final hasMore = userProjects.length > previewLimit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Works',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (hasMore)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllUserProjectsScreen(
                          profile: _currentProfile,
                          projects: userProjects,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: AppTheme.primaryColor.withOpacity(0.3)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All (${userProjects.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoadingProjects)
            const Center(child: CircularProgressIndicator())
          else if (userProjects.isEmpty)
            Text(
              'No works published yet.',
              style: TextStyle(color: Colors.grey[500]),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: previewProjects.length,
              itemBuilder: (context, index) {
                return _buildProjectItem(context, previewProjects[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(BuildContext context, Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (project.isPrivate ? Colors.orange : Colors.blue)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            image: project.coverImage != null
                ? DecorationImage(
                    image: NetworkImage(project.coverImage!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: project.coverImage == null
              ? Icon(
                  project.isPrivate ? Icons.lock_outline : Icons.code_rounded,
                  color: project.isPrivate ? Colors.orange : Colors.blue,
                )
              : null,
        ),
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            project.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ProfileService().myProfile?.id != project.owner)
              TextButton(
                onPressed: () async {
                  final success = await ProjectService().toggleInterested(project.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success 
                          ? 'Interest sent for ${project.name}!' 
                          : 'Failed to send interest.'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange[800],
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Interested', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(project: project),
            ),
          );
        },
      ),
    );
  }
}
