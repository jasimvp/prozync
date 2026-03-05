import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prozync/core/services/post_service.dart';
import 'package:prozync/core/services/profile_service.dart';
import 'package:prozync/core/services/project_service.dart';
import 'package:prozync/core/theme/app_theme.dart';
import 'package:prozync/models/comment_model.dart';
import 'package:prozync/models/post_model.dart';
import 'package:prozync/widgets/mention_text.dart';

/// A full-screen post detail page with comments.
/// Navigated to with [Navigator.push], so back button works correctly.
class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _postService = PostService();
  final _commentController = TextEditingController();

  late Post _post;
  List<Comment> _comments = [];
  bool _isLoadingComments = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    final comments = await _postService.fetchComments(_post.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isPosting = true);
    final comment = await _postService.addComment(
      _post.id,
      _commentController.text.trim(),
    );
    if (mounted) {
      setState(() => _isPosting = false);
      if (comment != null) {
        _commentController.clear();
        setState(() {
          _comments.insert(0, comment);
          _post = _post.copyWith(commentCount: _post.commentCount + 1);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment')),
        );
      }
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _postService,
      builder: (context, _) {
        // Keep local post in sync with PostService (for like/save toggles from feed)
        final feedPost = _postService.posts.where((p) => p.id == _post.id).firstOrNull;
        if (feedPost != null) {
          _post = feedPost;
        }
        final savedPost = _postService.savedPosts.where((p) => p.id == _post.id).firstOrNull;
        if (savedPost != null) {
          _post = savedPost;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: () {
                  final text =
                      'Check out this post on Prozync by ${_post.username}:\n${_post.content}';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post content copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Author Row ──────────────────────────────────────
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(
                              'https://ui-avatars.com/api/?name=${_post.username}&background=random',
                            ),
                            // ignore: deprecated_member_use
                            onBackgroundImageError: (e, s) {},
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _post.username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _getTimeAgo(_post.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Post Content ────────────────────────────────────
                      if (_post.content.isNotEmpty)
                        MentionText(
                          text: _post.content,
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),

                      // ── Post Image ──────────────────────────────────────
                      if (_post.fullImageUrl != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _post.fullImageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ],

                      // ── Project Badge ───────────────────────────────────
                      if (_post.project != null &&
                          ProfileService().myProfile?.id != _post.user) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.withOpacity(0.12)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.folder_rounded, color: Colors.blue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Project #${_post.project}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final success = await ProjectService()
                                      .toggleInterested(_post.project!);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(success
                                            ? 'Interest sent!'
                                            : 'Failed to send interest.'),
                                        backgroundColor:
                                            success ? Colors.green : Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.orange[800],
                                ),
                                child: const Text('Interested',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ── Actions Row ─────────────────────────────────────
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Like
                          InkWell(
                            onTap: () => _postService.likePost(_post.id),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    _post.isLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color:
                                        _post.isLiked ? Colors.red : Colors.grey[600],
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _post.likeCount.toString(),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Comment count
                          Row(
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  color: Colors.grey[600], size: 22),
                              const SizedBox(width: 6),
                              Text(
                                _post.commentCount.toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Save/Bookmark
                          IconButton(
                            icon: Icon(
                              _post.isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color:
                                  _post.isSaved ? AppTheme.primaryColor : Colors.grey,
                            ),
                            onPressed: () async {
                              final success =
                                  await _postService.toggleSavePost(_post.id);
                              if (mounted && !success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Could not update save status')),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      // ── Comments Header ─────────────────────────────────
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Comments List ───────────────────────────────────
                      if (_isLoadingComments)
                        const Center(child: CircularProgressIndicator())
                      else if (_comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No comments yet.\nBe the first to say something!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                                    onBackgroundImageError: (e, s) {},
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
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
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      // Bottom padding so FAB doesn't cover last comment
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // ── Comment Input ───────────────────────────────────────────
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
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
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _postComment(),
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
      },
    );
  }
}
