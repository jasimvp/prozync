import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:prozync/features/activity/activity_screen.dart';
import 'package:prozync/features/profile/other_user_profile_screen.dart';
import 'package:prozync/features/activity/chat_list_screen.dart';
import 'package:prozync/core/services/post_service.dart';
import 'package:prozync/models/post_model.dart';
import 'package:prozync/core/theme/app_theme.dart';
import 'package:prozync/core/services/profile_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _postService = PostService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _postService.fetchPosts();
    ProfileService().fetchMyProfile();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return ListenableBuilder(
      listenable: _postService,
      builder: (context, _) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => _postService.fetchPosts(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(context),
                if (_postService.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_postService.posts.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('No posts yet. Be the first to post!')),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? (screenWidth - 800) / 2 : 16,
                      vertical: 20,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPostCard(context, _postService.posts[index]),
                        childCount: _postService.posts.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreatePostBottomSheet(context),
            backgroundColor: AppTheme.primaryColor,
            elevation: 4,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('New Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.code_rounded, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prozync',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text(
                'Community Feed',
                style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ActivityScreen()),
            );
          },
          icon: const Icon(Icons.notifications_none_rounded, size: 26),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatListScreen()),
            );
          },
          icon: const Icon(Icons.messenger_outline_rounded, size: 24),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showCreatePostBottomSheet(BuildContext context) {
    final controller = TextEditingController();
    String? selectedFileName;
    String? selectedFilePath;
    dynamic selectedFileBytes;
    bool isPosting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Text('Create Post', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: controller,
                          maxLines: 5,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: "What's on your mind?",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (selectedFileName != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.image, color: Colors.blue, size: 20),
                                const SizedBox(width: 10),
                                Expanded(child: Text(selectedFileName!, style: const TextStyle(fontSize: 14))),
                                IconButton(
                                  icon: const Icon(Icons.cancel, size: 20, color: Colors.grey),
                                  onPressed: () => setModalState(() => selectedFileName = null),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                final result = await FilePicker.platform.pickFiles(
                                  type: FileType.image,
                                  withData: kIsWeb,
                                );
                                if (result != null) {
                                  setModalState(() {
                                    selectedFileName = result.files.first.name;
                                    selectedFilePath = result.files.first.path;
                                    selectedFileBytes = result.files.first.bytes;
                                  });
                                }
                              },
                              icon: const Icon(Icons.image_outlined, color: Colors.blue),
                              tooltip: 'Add Image',
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.alternate_email_rounded, color: Colors.grey),
                              tooltip: 'Tag User',
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.tag_rounded, color: Colors.grey),
                              tooltip: 'Hashtag',
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                onPressed: isPosting ? null : () async {
                                  if (controller.text.trim().isEmpty) return;
                                  
                                  setModalState(() => isPosting = true);
                                  
                                  http.MultipartFile? imageFile;
                                  if (kIsWeb && selectedFileBytes != null) {
                                    imageFile = http.MultipartFile.fromBytes(
                                      'image',
                                      selectedFileBytes,
                                      filename: selectedFileName,
                                    );
                                  } else if (!kIsWeb && selectedFilePath != null) {
                                    imageFile = await http.MultipartFile.fromPath(
                                      'image',
                                      selectedFilePath!,
                                    );
                                  }

                                  final result = await _postService.createPost(
                                    controller.text, 
                                    imageFile: imageFile,
                                    userId: ProfileService().myProfile?.id,
                                  );
                                  
                                  if (mounted) {
                                    Navigator.pop(context);
                                    if (result != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post published!')));
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: isPosting 
                                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Post Now', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildPostCard(BuildContext context, Post post) {
    final isOwner = ProfileService().myProfile?.id == post.user;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToProfile(context, post),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${post.username}&background=random'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToProfile(context, post),
                        child: Text(
                          post.username,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Text(
                        _getTimeAgo(post.createdAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz_rounded, color: Colors.grey[400]),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Post'),
                            content: const Text('Are you sure you want to delete this post?'),
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
                          await _postService.deletePost(post.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Post deleted')),
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
                            Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz_rounded, color: Colors.grey[400])),
              ],
            ),
          ),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          if (post.image != null)
            Container(
              height: 300,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(post.image!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (post.project != null)
            _buildProjectPreview(context, post),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildLikeButton(post),
                const SizedBox(width: 20),
                _buildInteractionItem(Icons.chat_bubble_outline_rounded, post.commentCount.toString(), Colors.blue),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border_rounded, color: Colors.grey)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share_rounded, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectPreview(BuildContext context, Post post) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.folder_rounded, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Associated Project',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Project ID: ${post.project}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLikeButton(Post post) {
    final bool isLiked = false; // Add to model if needed
    return InkWell(
      onTap: () => _postService.likePost(post.id),
      child: Row(
        children: [
          Icon(
            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isLiked ? Colors.red : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 6),
          Text(
            post.likeCount.toString(),
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 24),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'just now';
  }

  void _navigateToProfile(BuildContext context, Post post) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ProfileService().fetchProfiles(search: post.username);
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        final profile = ProfileService().profiles.firstWhere((p) => p.user == post.user);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherUserProfileScreen(profile: profile),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not load profile')));
      }
    }
  }
}
