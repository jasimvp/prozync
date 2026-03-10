import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../core/services/profile_service.dart';
import '../../core/theme/app_theme.dart';
import 'other_user_profile_screen.dart';

class FollowListScreen extends StatefulWidget {
  final String userId;
  final String title;
  final bool isFollowers;

  const FollowListScreen({
    super.key,
    required this.userId,
    required this.title,
    required this.isFollowers,
  });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  final ProfileService _profileService = ProfileService();
  List<Profile> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchList();
  }

  Future<void> _fetchList() async {
    List<Profile> result;
    if (widget.isFollowers) {
      result = await _profileService.getFollowers(widget.userId);
    } else {
      result = await _profileService.getFollowing(widget.userId);
    }

    if (mounted) {
      setState(() {
        _list = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isFollowers
                        ? Icons.group_outlined
                        : Icons.person_add_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${widget.title.toLowerCase()} yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _list.length,
              itemBuilder: (context, index) {
                final profile = _list[index];
                return ListTile(
                  onTap: () {
                    if (profile.id == _profileService.myProfile?.id) {
                      Navigator.pop(context);
                      // Maybe navigate to profile tab if needed
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OtherUserProfileScreen(profile: profile),
                        ),
                      );
                    }
                  },
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(profile.fullProfilePic),
                  ),
                  title: Text(
                    profile.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(profile.profession),
                  trailing: profile.id != _profileService.myProfile?.id
                      ? FollowButton(profile: profile)
                      : null,
                );
              },
            ),
    );
  }
}

class FollowButton extends StatefulWidget {
  final Profile profile;
  const FollowButton({super.key, required this.profile});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isFollowing = false;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.profile.connectionStatus.toLowerCase() == 'following';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: _isActionInProgress
            ? null
            : () async {
                setState(() => _isActionInProgress = true);

                final result = await ProfileService().followProfile(
                  widget.profile.id,
                );

                if (mounted && result != null) {
                  setState(() {
                    _isFollowing =
                        result.toLowerCase() == 'followed' ||
                        result.toLowerCase() == 'following';
                    _isActionInProgress = false;
                  });
                } else if (mounted) {
                  setState(() => _isActionInProgress = false);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing
              ? Colors.grey[200]
              : AppTheme.primaryColor,
          foregroundColor: _isFollowing ? Colors.black : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          _isFollowing ? 'Following' : 'Follow',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
