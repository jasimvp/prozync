import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:prozync/features/activity/activity_screen.dart';
import 'package:prozync/features/profile/other_user_profile_screen.dart';
import 'package:prozync/features/activity/chat_list_screen.dart';
import 'package:prozync/core/services/post_service.dart';
import 'package:prozync/models/post_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _postService = PostService();

  @override
  void initState() {
    super.initState();
    _postService.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return ListenableBuilder(
      listenable: _postService,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.code, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prozync'),
                    Text(
                      'Discover & Collaborate',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 10,
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
                icon: const Icon(Icons.notifications_none_outlined),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChatListScreen()),
                  );
                },
                icon: const Icon(Icons.messenger_outline),
              ),
            ],
          ),
          body: _postService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: isWide ? 800 : double.infinity),
                    child: _postService.posts.isEmpty 
                        ? const Center(child: Text('No posts yet. Be the first to post!'))
                        : ListView.builder(
                            itemCount: _postService.posts.length,
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 0 : 16,
                              vertical: 16,
                            ),
                            itemBuilder: (context, index) {
                              return _buildPostCard(context, _postService.posts[index]);
                            },
                          ),
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreatePostDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final controller = TextEditingController();
    String? selectedFileName;
    String? selectedFilePath;
    dynamic selectedFileBytes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Create Post'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: "What's on your mind?"),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        withData: kIsWeb,
                      );
                      if (result != null) {
                        setDialogState(() {
                          selectedFileName = result.files.first.name;
                          selectedFilePath = result.files.first.path;
                          selectedFileBytes = result.files.first.bytes;
                        });
                      }
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(selectedFileName ?? 'Add Image'),
                  ),
                  if (selectedFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Selected: $selectedFileName',
                        style: const TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
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

                    await _postService.createPost(controller.text, imageFile: imageFile);
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Post'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.image != null)
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(post.image!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (post.project != null)
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage('https://picsum.photos/seed/${post.id + 50}/800/600'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserProfileScreen(
                          userName: post.username,
                          userDesignation: 'Developer',
                          userImage: 'https://ui-avatars.com/api/?name=${post.username}&background=random',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${post.username}&background=random'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.username,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                            ),
                            Text(
                              '${DateTime.now().difference(post.createdAt).inHours}h ago',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(post.content),

                const SizedBox(height: 12),
                const Divider(height: 32),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  runSpacing: 12,
                  children: [
                    _buildActionButton(Icons.favorite_border, post.likeCount.toString(), Colors.red, () {
                      _postService.likePost(post.id);
                    }),
                    _buildActionButton(Icons.chat_bubble_outline, post.commentCount.toString(), Colors.blue, () {}),
                    _buildActionButton(Icons.share_outlined, 'Share', Colors.grey, () {}),
                    _buildActionButton(Icons.bookmark_border, 'Save', Colors.grey, () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }
}
