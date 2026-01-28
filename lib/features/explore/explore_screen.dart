import 'package:flutter/material.dart';

import 'package:prozync/features/profile/other_user_profile_screen.dart';
import 'package:prozync/features/projects/project_details_screen.dart';
import 'package:prozync/core/services/project_service.dart';
import 'package:prozync/core/services/profile_service.dart';
import 'package:prozync/models/project_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

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
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search projects or developers...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey[200],
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
          toolbarHeight: 100,
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
            child: TabBarView(
              children: [
                TrendingProjectsView(searchQuery: _searchQuery),
                DevelopersListView(searchQuery: _searchQuery),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrendingProjectsView extends StatefulWidget {
  final String searchQuery;
  const TrendingProjectsView({super.key, required this.searchQuery});

  @override
  State<TrendingProjectsView> createState() => _TrendingProjectsViewState();
}

class _TrendingProjectsViewState extends State<TrendingProjectsView> {
  final _projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    _projectService.fetchProjects(search: widget.searchQuery);
  }

  @override
  void didUpdateWidget(TrendingProjectsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _projectService.fetchProjects(search: widget.searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _projectService,
      builder: (context, _) {
        if (_projectService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final projects = _projectService.projects;
        if (projects.isEmpty) {
          return const Center(child: Text('No trending projects found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            return _buildProjectCard(context, projects[index]);
          },
        );
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
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
                    'https://picsum.photos/seed/${project.id + 100}/800/600'),
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
                          userName: project.ownerName,
                          userDesignation: 'Contributor',
                          userImage: 'https://ui-avatars.com/api/?name=${project.ownerName}&background=random',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage('https://ui-avatars.com/api/?name=${project.ownerName}&background=random'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
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
                                    project.language,
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
                                    'by ${project.ownerName} • Trending',
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
                Text(
                  project.description,
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
                            project: project,
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
}

class DevelopersListView extends StatefulWidget {
  final String searchQuery;
  const DevelopersListView({super.key, required this.searchQuery});

  @override
  State<DevelopersListView> createState() => _DevelopersListViewState();
}

class _DevelopersListViewState extends State<DevelopersListView> {
  final _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _profileService.fetchProfiles(search: widget.searchQuery);
  }

  @override
  void didUpdateWidget(DevelopersListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _profileService.fetchProfiles(search: widget.searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _profileService,
      builder: (context, _) {
        if (_profileService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final profiles = _profileService.profiles;
        if (profiles.isEmpty) {
          return const Center(child: Text('No developers found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(profile.profilePic ?? 'https://ui-avatars.com/api/?name=${profile.fullName}&background=random'),
                ),
                title: Text(profile.fullName),
                subtitle: Text('${profile.profession} • ${profile.repoCount} repos'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final success = await _profileService.followProfile(profile.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Following ${profile.fullName}' : 'Failed to follow')),
                      );
                    }
                  },
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
                        userName: profile.fullName,
                        userDesignation: profile.profession,
                        userImage: profile.profilePic ?? 'https://ui-avatars.com/api/?name=${profile.fullName}&background=random',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
