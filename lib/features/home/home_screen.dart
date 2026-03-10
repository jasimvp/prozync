import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:prozync/core/services/project_service.dart';
import 'package:prozync/models/comment_model.dart';
import 'package:prozync/models/profile_model.dart';
import 'package:prozync/widgets/mention_text.dart';

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
                    child: Center(
                      child: Text('No posts yet. Be the first to post!'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? (screenWidth - 800) / 2 : 16,
                      vertical: 20,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildPostCard(context, _postService.posts[index]),
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
            label: const Text(
              'New Post',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            child: Image.asset(
              'assets/icon/prozync.png',
              height: 22,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.code_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
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
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
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

    // Mention state
    List<Profile> mentionResults = [];
    bool showMentionList = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Text(
                        'Create Post',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
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
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: "What's on your mind?",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) async {
                            final cursorPosition = controller.selection.baseOffset;
                            if (cursorPosition <= 0) {
                              setModalState(() => showMentionList = false);
                              return;
                            }

                            final textBeforeCursor = value.substring(0, cursorPosition);
                            final lastAtIndex = textBeforeCursor.lastIndexOf('@');

                            if (lastAtIndex != -1 && !textBeforeCursor.substring(lastAtIndex).contains(' ')) {
                              final query = textBeforeCursor.substring(lastAtIndex + 1);
                              await ProfileService().fetchProfiles(search: query);
                              final myId = ProfileService().myProfile?.id;
                              setModalState(() {
                                mentionResults = ProfileService().profiles
                                    .where((p) => p.id != myId)
                                    .toList();
                                showMentionList = mentionResults.isNotEmpty;
                              });
                            } else {
                              setModalState(() => showMentionList = false);
                            }
                          },
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
                                const Icon(
                                  Icons.image,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectedFileName!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setModalState(
                                    () => selectedFileName = null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if (showMentionList)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: mentionResults.length,
                              itemBuilder: (context, index) {
                                final profile = mentionResults[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 15,
                                    backgroundImage: NetworkImage(profile.fullProfilePic),
                                    onBackgroundImageError: (e, s) => debugPrint('Mention avatar error'),
                                  ),
                                  title: Text(profile.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  subtitle: Text('@${profile.username}', style: const TextStyle(fontSize: 12)),
                                  onTap: () {
                                    final text = controller.text;
                                    final cursorPosition = controller.selection.baseOffset;
                                    final textBeforeCursor = text.substring(0, cursorPosition);
                                    final lastAtIndex = textBeforeCursor.lastIndexOf('@');
                                    
                                    final newText = text.replaceRange(
                                      lastAtIndex,
                                      cursorPosition,
                                      '@${profile.username} ',
                                    );
                                    
                                    controller.value = controller.value.copyWith(
                                      text: newText,
                                      selection: TextSelection.collapsed(
                                        offset: lastAtIndex + profile.username.length + 2,
                                      ),
                                    );
                                    
                                    setModalState(() => showMentionList = false);
                                  },
                                );
                              },
                            ),
                          ),

                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.image,
                                      withData: kIsWeb,
                                    );
                                if (result != null) {
                                  setModalState(() {
                                    selectedFileName = result.files.first.name;
                                    selectedFilePath = result.files.first.path;
                                    selectedFileBytes =
                                        result.files.first.bytes;
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.image_outlined,
                                color: Colors.blue,
                              ),
                              tooltip: 'Add Image',
                            ),
                            IconButton(
                              onPressed: () async {
                                final text = controller.text;
                                final selection = controller.selection;
                                final newText = text.replaceRange(
                                  selection.start == -1 ? text.length : selection.start,
                                  selection.end == -1 ? text.length : selection.end,
                                  '@',
                                );
                                controller.value = controller.value.copyWith(
                                  text: newText,
                                  selection: TextSelection.collapsed(
                                    offset: (selection.start == -1 ? text.length : selection.start) + 1,
                                  ),
                                );
                                
                                // Trigger user list
                                await ProfileService().fetchProfiles(search: '');
                                final myId = ProfileService().myProfile?.id;
                                setModalState(() {
                                  mentionResults = ProfileService().profiles
                                      .where((p) => p.id != myId)
                                      .toList();
                                  showMentionList = mentionResults.isNotEmpty;
                                });
                              },
                              icon: const Icon(
                                Icons.alternate_email_rounded,
                                color: Colors.blue,
                              ),
                              tooltip: 'Tag User',
                            ),
                            IconButton(
                              onPressed: () {
                                final text = controller.text;
                                final selection = controller.selection;
                                final newText = text.replaceRange(
                                  selection.start == -1 ? text.length : selection.start,
                                  selection.end == -1 ? text.length : selection.end,
                                  '#',
                                );
                                controller.value = controller.value.copyWith(
                                  text: newText,
                                  selection: TextSelection.collapsed(
                                    offset: (selection.start == -1 ? text.length : selection.start) + 1,
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.tag_rounded,
                                color: Colors.blue,
                              ),
                              tooltip: 'Hashtag',
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                onPressed: isPosting
                                    ? null
                                    : () async {
                                        if (controller.text.trim().isEmpty)
                                          return;

                                        setModalState(() => isPosting = true);

                                        http.MultipartFile? imageFile;
                                        if (kIsWeb &&
                                            selectedFileBytes != null) {
                                          imageFile =
                                              http.MultipartFile.fromBytes(
                                                'image',
                                                selectedFileBytes,
                                                filename: selectedFileName,
                                              );
                                        } else if (!kIsWeb &&
                                            selectedFilePath != null) {
                                          imageFile =
                                              await http.MultipartFile.fromPath(
                                                'image',
                                                selectedFilePath!,
                                              );
                                        }

                                        final result = await _postService
                                            .createPost(
                                              controller.text,
                                              imageFile: imageFile,
                                            );

                                        if (mounted) {
                                          Navigator.pop(context);
                                          if (result != null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Post published!',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: isPosting
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Post Now',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=${post.username}&background=random',
                    ),
                    onBackgroundImageError: (e, s) => debugPrint('Feed avatar error: $e'),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.grey[400],
                    ),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Post'),
                            content: const Text(
                              'Are you sure you want to delete this post?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
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
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: MentionText(
                text: post.content,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          if (post.image != null)
            Container(
              height: 300,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              child: Image.network(
                post.fullImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[100],
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
                  ),
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
                InkWell(
                  onTap: () => _showCommentsBottomSheet(context, post),
                  child: _buildInteractionItem(
                    Icons.chat_bubble_outline_rounded,
                    post.commentCount.toString(),
                    Colors.blue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    final success = await _postService.toggleSavePost(post.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? (post.isSaved
                                      ? 'Removed from saved'
                                      : 'Post saved!')
                                : 'Could not update save status',
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    post.isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: post.isSaved ? AppTheme.primaryColor : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final text =
                        'Check out this post on Prozync by ${post.username}:\n'
                        '${post.content}';
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post content copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.ios_share_rounded, color: Colors.grey),
                ),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Project ID: ${post.project}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.grey,
          ),
          if (post.project != null && ProfileService().myProfile?.id != post.user) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                final success = await ProjectService().toggleInterested(post.project!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? 'Interest sent for this project!' 
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
          ],
        ],
      ),
    );
  }

  Widget _buildLikeButton(Post post) {
    final bool isLiked = post.isLiked;
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
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
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
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
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
        final profile = ProfileService().profiles.firstWhere(
          (p) => p.user == post.user,
        );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not load profile')));
      }
    }
  }

  void _showCommentsBottomSheet(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsSheet(post: post),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final Post post;
  const _CommentsSheet({required this.post});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final PostService _postService = PostService();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final comments = await _postService.fetchComments(widget.post.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);
    final comment = await _postService.addComment(
      widget.post.id,
      _commentController.text.trim(),
    );

    if (mounted) {
      setState(() => _isPosting = false);
      if (comment != null) {
        _commentController.clear();
        _comments.insert(0, comment);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to post comment')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet.\nBe the first to say something!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                                backgroundImage: NetworkImage(
                                  'https://ui-avatars.com/api/?name=${comment.username}&background=random',
                                ),
                                onBackgroundImageError: (e, s) => debugPrint('Comment avatar error: $e'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                         MentionText(
                                           text: comment.content,
                                           style: const TextStyle(fontSize: 14),
                                         ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      top: 4,
                                    ),
                                    child: Text(
                                      'Just now',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _isPosting ? null : _postComment,
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  icon: _isPosting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
