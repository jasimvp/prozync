import 'package:flutter/material.dart';

import 'package:prozync/features/profile/other_user_profile_screen.dart';
import 'package:prozync/features/projects/project_details_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Explore', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              const SizedBox(height: 8),
              Container(
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
            ],
          ),
          toolbarHeight: 100, // Increased height for title and search field
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
                              'Project Name ${index + 1}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    index % 2 == 0 ? 'Web' : 'App',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'by Developer $index • Trending',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Text(
                  'An amazing project that solves real-world problems using advanced algorithms and clean architecture.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailsScreen(
                            projectName: 'Project Name ${index + 1}',
                            isPublic: true,
                            description:
                                'An amazing project that solves real-world problems using advanced algorithms and clean architecture.',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      foregroundColor: Colors.blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
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
