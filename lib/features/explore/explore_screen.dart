import 'package:flutter/material.dart';

import 'package:prozync/features/profile/other_user_profile_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
                    Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Trending Projects'),
              Tab(text: 'Developers'),
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
          ),
        ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [

              const Expanded(
                child: TabBarView(
                  children: [
                    TrendingProjectsView(),
                    DevelopersListView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class TrendingProjectsView extends StatelessWidget {
  const TrendingProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (context, index) {
        return _buildProjectCard(context, index);
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(
                    'https://picsum.photos/seed/${index + 100}/800/600'),
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
                          userName: 'Developer $index',
                          userDesignation: 'Full Stack Engineer',
                          userImage: 'https://i.pravatar.cc/150?u=$index',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage('https://i.pravatar.cc/150?u=$index'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Developer $index',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Just now • Trending',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Project Name ${index + 1}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'An amazing project that solves real-world problems using advanced algorithms and clean architecture.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildIconText(Icons.star_border, '${(index + 1) * 50}'),
                    const SizedBox(width: 16),
                    _buildIconText(Icons.fork_right, '${(index + 1) * 10}'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'View Project',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class DevelopersListView extends StatelessWidget {
  const DevelopersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=dev$index'),
            ),
            title: Text('Developer ${index + 10}'),
            subtitle: Text('Expert in Flutter • ${index * 5} repos'),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 32),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Follow', style: TextStyle(fontSize: 12)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherUserProfileScreen(
                    userName: 'Developer ${index + 10}',
                    userDesignation: 'Flutter Expert',
                    userImage: 'https://i.pravatar.cc/150?u=dev$index',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
