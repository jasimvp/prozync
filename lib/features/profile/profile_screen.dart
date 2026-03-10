import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prozync/core/services/cloudinary_service.dart';
import 'package:prozync/features/profile/settings_screen.dart';
import 'package:prozync/features/profile/saved_posts_screen.dart';
import 'package:prozync/features/projects/project_details_screen.dart';
import 'package:prozync/core/services/project_service.dart';
import 'package:prozync/core/services/profile_service.dart';
import 'package:prozync/models/profile_model.dart';
import 'package:prozync/core/theme/app_theme.dart';
import 'package:prozync/features/profile/follow_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _profileService.fetchMyProfile();
    ProjectService().fetchPinnedProjects();
    ProjectService().fetchMyRepos();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _profileService,
      builder: (context, _) {
        final profile = _profileService.myProfile;

        return Scaffold(
          body: _profileService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : profile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load profile',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _profileService.fetchMyProfile(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(context, profile),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildStatsRow(context, profile),
                          const SizedBox(height: 32),
                          _buildAboutSection(context, profile),
                          const SizedBox(height: 32),
                          _buildRecentWorksSection(context),
                          const SizedBox(height: 32),
                          _buildWorksSection(context),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Profile profile) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
        ),
      ],
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
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor.withOpacity(0.8),
                  ],
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
            Positioned(
              bottom: 40,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
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
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(profile.fullProfilePic),
                        onBackgroundImageError: (exception, stackTrace) {
                          debugPrint('Error loading profile pic: $exception');
                        },
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: GestureDetector(
                        onTap: () =>
                            _showEditProfileBottomSheet(context, profile),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  profile.profession,
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
                      Icons.verified_user,
                      size: 14,
                      color: Colors.blue[300],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '@${profile.username}',
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

  Widget _buildStatsRow(BuildContext context, Profile profile) {
    return ListenableBuilder(
      listenable: ProjectService(),
      builder: (context, child) {
        final repos = ProjectService().myRepos;
        int totalStars = 0;
        for (final p in repos) {
          totalStars += p.likeCount;
        }

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
                child: _buildStatItem(context, profile.repoCount, 'Projects'),
              ),
              _buildVerticalDivider(),
              Expanded(
                child: _buildStatItem(
                  context,
                  profile.followerCount,
                  'Followers',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FollowListScreen(
                          userId: profile.id,
                          title: 'Followers',
                          isFollowers: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildVerticalDivider(),
              Expanded(
                child: _buildStatItem(
                  context,
                  profile.followingCount,
                  'Following',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FollowListScreen(
                          userId: profile.id,
                          title: 'Following',
                          isFollowers: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildVerticalDivider(),
              Expanded(
                child: _buildStatItem(context, totalStars.toString(), 'Stars'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.2));
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
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
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, Profile profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'About Me',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (profile.phone.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.phone_iphone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      profile.phone,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
            ],
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
            child: Text(
              profile.bio.isEmpty
                  ? 'Sharing my creative journey and technical projects.'
                  : profile.bio,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Saved Projects Tile
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedPostsScreen(),
                ),
              );
            },
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bookmark_rounded,
                color: Colors.amber,
                size: 24,
              ),
            ),
            title: const Text(
              'Saved Posts',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              'Posts you\'ve bookmarked for later',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWorksSection(BuildContext context) {
    return ListenableBuilder(
      listenable: ProjectService(),
      builder: (context, child) {
        final recentWorks = ProjectService().myRepos;
        final isLoading = ProjectService().isMyReposLoading;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Works',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (recentWorks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No repositories/projects yet.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentWorks.length,
                  itemBuilder: (context, index) {
                    final project = recentWorks[index];
                    return _buildProjectItem(context, project);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorksSection(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ProjectService(), ProfileService()]),
      builder: (context, child) {
        final pinnedWorks = ProjectService().pinnedProjects;
        final isLoading = ProjectService().isPinnedLoading;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pinned Projects',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (pinnedWorks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.push_pin_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No pinned projects',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pinnedWorks.length,
                  itemBuilder: (context, index) {
                    final project = pinnedWorks[index];
                    return _buildProjectItem(context, project);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectItem(BuildContext context, dynamic project) {
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
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.code_rounded, color: Colors.blue),
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
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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

  void _showEditProfileBottomSheet(BuildContext context, Profile profile) {
    final nameController = TextEditingController(text: profile.fullName);
    final professionController = TextEditingController(
      text: profile.profession,
    );
    final bioController = TextEditingController(text: profile.bio);
    final phoneController = TextEditingController(text: profile.phone);
    XFile? selectedImage;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Image Selector
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                backgroundImage: selectedImage != null
                                    ? (kIsWeb
                                              ? NetworkImage(
                                                  selectedImage!.path,
                                                )
                                              : FileImage(
                                                  File(selectedImage!.path),
                                                ))
                                          as ImageProvider
                                    : NetworkImage(profile.fullProfilePic),
                                onBackgroundImageError: (exception, stackTrace) {
                                  debugPrint(
                                    'Error loading profile pic in edit: $exception',
                                  );
                                },
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    final XFile? image = await _imagePicker
                                        .pickImage(
                                          source: ImageSource.gallery,
                                          imageQuality: 80,
                                        );
                                    if (image != null) {
                                      setModalState(() {
                                        selectedImage = image;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildStyledTextField(
                          'Full Name',
                          Icons.person_outline,
                          nameController,
                        ),
                        const SizedBox(height: 20),
                        _buildStyledTextField(
                          'Profession',
                          Icons.work_outline,
                          professionController,
                        ),
                        const SizedBox(height: 20),
                        _buildStyledTextField(
                          'Phone',
                          Icons.phone_outlined,
                          phoneController,
                        ),
                        const SizedBox(height: 20),
                        _buildStyledTextField(
                          'Bio',
                          Icons.info_outline,
                          bioController,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    setModalState(() => isSaving = true);

                                    String? profilePicUrl;
                                    if (selectedImage != null) {
                                      final cloudinary = CloudinaryService();
                                      if (kIsWeb) {
                                        final bytes = await selectedImage!
                                            .readAsBytes();
                                        profilePicUrl = await cloudinary
                                            .uploadImage(
                                              bytes,
                                              folder: 'profiles',
                                            );
                                      } else {
                                        profilePicUrl = await cloudinary
                                            .uploadImage(
                                              File(selectedImage!.path),
                                              folder: 'profiles',
                                            );
                                      }
                                    }

                                    final success = await _profileService
                                        .updateProfile({
                                          'full_name': nameController.text
                                              .trim(),
                                          'profession': professionController
                                              .text
                                              .trim(),
                                          'bio': bioController.text.trim(),
                                          'phone': phoneController.text.trim(),
                                        }, profilePic: profilePicUrl);

                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Profile updated successfully'
                                                : 'Failed to update profile',
                                          ),
                                          backgroundColor: success
                                              ? Colors.green
                                              : Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStyledTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue, size: 20),
            hintText: 'Enter your $label',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
