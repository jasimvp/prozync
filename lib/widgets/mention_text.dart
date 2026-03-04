import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:prozync/core/services/profile_service.dart';
import 'package:prozync/features/profile/other_user_profile_screen.dart';
import 'package:prozync/core/theme/app_theme.dart';

class MentionText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const MentionText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> spans = [];
    final words = text.split(' ');

    for (int i = 0 ; i < words.length; i++) {
        final word = words[i];
      if (word.startsWith('@') && word.length > 1) {
        final username = word.substring(1).replaceAll(RegExp(r'[^\w]'), '');
        spans.add(
          TextSpan(
            text: word,
            style: (style ?? const TextStyle()).copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _handleMentionTap(context, username),
          ),
        );
      } else {
        spans.add(TextSpan(text: word, style: style));
      }
      
      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return RichText(
      text: TextSpan(children: spans, style: style ?? Theme.of(context).textTheme.bodyMedium),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  void _handleMentionTap(BuildContext context, String username) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ProfileService().fetchProfiles(search: username);
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        final profile = ProfileService().profiles.firstWhere(
          (p) => p.username.toLowerCase() == username.toLowerCase(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find user profile')),
        );
      }
    }
  }
}
