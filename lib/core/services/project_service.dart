import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../models/social_model.dart';
import 'api_service.dart';
import 'profile_service.dart';

class ProjectService extends ChangeNotifier {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  final ApiService _apiService = ApiService();
  List<Project> _projects = [];
  List<Project> _myRepos = [];
  List<Project> _pinnedProjects = [];
  List<Invitation> _invitations = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  List<Project> get myRepos => _myRepos;

  // My pinned projects (own work)
  List<Project> get pinnedProjects {
    final myId = ProfileService().myProfile?.id;
    if (myId == null) return [];

    final all = [..._myRepos, ..._pinnedProjects, ..._projects];
    final seen = <int>{};
    return all.where((p) {
      if (seen.contains(p.id)) return false;
      seen.add(p.id);
      return p.isPinned && p.owner == myId;
    }).toList();
  }

  // Saved projects (others' work)
  List<Project> get savedProjects {
    final myId = ProfileService().myProfile?.id;
    if (myId == null) return [];

    final all = [..._pinnedProjects, ..._projects, ..._myRepos];
    final seen = <int>{};
    return all.where((p) {
      if (seen.contains(p.id)) return false;
      seen.add(p.id);
      return p.isPinned && p.owner != myId;
    }).toList();
  }

  List<Invitation> get invitations => _invitations;
  bool get isLoading => _isLoading;

  Future<void> fetchProjects({String? search}) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final endpoint = search != null
          ? '/projects/?search=$search'
          : '/projects/';
      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _projects = data.map((json) => Project.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyRepos() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.get('/projects/my_repos/');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _myRepos = data.map((json) => Project.fromJson(json)).toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPinnedProjects() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.get('/projects/pinned/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _pinnedProjects = data.map((json) => Project.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching pinned projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Project?> createProject(
    Map<String, String> data, {
    List<http.MultipartFile>? files,
  }) async {
    try {
      final response = await _apiService.postMultipart(
        '/projects/',
        data,
        files: files,
      );
      if (response.statusCode == 201) {
        final project = Project.fromJson(jsonDecode(response.body));
        _projects.insert(0, project);
        _myRepos.insert(0, project);
        notifyListeners();
        return project;
      } else {
        debugPrint('Failed to create project: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating project: $e');
    }
    return null;
  }

  Future<bool> deleteProject(int id) async {
    try {
      final response = await _apiService.delete('/projects/$id/');
      if (response.statusCode == 204) {
        _projects.removeWhere((p) => p.id == id);
        _myRepos.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting project: $e');
    }
    return false;
  }

  Project getProjectById(int id, Project fallback) {
    return [
      ..._projects,
      ..._myRepos,
      ..._pinnedProjects,
    ].firstWhere((p) => p.id == id, orElse: () => fallback);
  }

  Future<bool> togglePin(int projectId) async {
    // 1. Find the project in all lists
    int index = _projects.indexWhere((p) => p.id == projectId);
    int myRepoIndex = _myRepos.indexWhere((p) => p.id == projectId);
    int pinnedIndex = _pinnedProjects.indexWhere((p) => p.id == projectId);

    Project? originalProject;
    if (index != -1)
      originalProject = _projects[index];
    else if (myRepoIndex != -1)
      originalProject = _myRepos[myRepoIndex];
    else if (pinnedIndex != -1)
      originalProject = _pinnedProjects[pinnedIndex];

    if (originalProject == null) return false;

    final bool wasPinned = originalProject.isPinned;
    final bool newPinnedState = !wasPinned;

    // 2. Perform Optimistic Update
    final optimisticProject = originalProject.copyWith(
      isPinned: newPinnedState,
    );

    // Update all lists where the project exists
    if (index != -1) _projects[index] = optimisticProject;
    if (myRepoIndex != -1) _myRepos[myRepoIndex] = optimisticProject;

    // Manage _pinnedProjects list based on newPinnedState
    if (newPinnedState) {
      if (pinnedIndex == -1) {
        _pinnedProjects.add(optimisticProject);
      } else {
        _pinnedProjects[pinnedIndex] = optimisticProject;
      }
    } else {
      if (pinnedIndex != -1) {
        _pinnedProjects.removeAt(pinnedIndex);
      }
    }

    notifyListeners();

    try {
      final response = await _apiService.post('/projects/$projectId/pin/', {});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        Project updatedProject;
        if (body.containsKey('id')) {
          // Full object returned
          updatedProject = Project.fromJson(body);
        } else {
          // Partial object returned (like just {"is_pinned": true})
          final bool serverPinnedState = body['is_pinned'] ?? newPinnedState;
          updatedProject = originalProject.copyWith(
            isPinned: serverPinnedState,
          );
        }

        // Final sync with server truth
        _updateProjectInLists(projectId, updatedProject);
        notifyListeners();
        return true;
      } else {
        // Rollback
        _updateProjectInLists(projectId, originalProject);
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error toggling pin: $e');
      // Rollback
      _updateProjectInLists(projectId, originalProject);
      notifyListeners();
      return false;
    }
  }

  void _updateProjectInLists(int projectId, Project project) {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) _projects[index] = project;

    final myRepoIndex = _myRepos.indexWhere((p) => p.id == projectId);
    if (myRepoIndex != -1) _myRepos[myRepoIndex] = project;

    final pinnedIndex = _pinnedProjects.indexWhere((p) => p.id == projectId);
    if (project.isPinned) {
      if (pinnedIndex == -1)
        _pinnedProjects.add(project);
      else
        _pinnedProjects[pinnedIndex] = project;
    } else {
      if (pinnedIndex != -1) _pinnedProjects.removeAt(pinnedIndex);
    }
  }

  Future<void> fetchInvitations() async {
    try {
      final response = await _apiService.get('/invitations/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _invitations = data.map((json) => Invitation.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching invitations: $e');
    }
  }

  Future<bool> sendInvitation(int projectId, int receiverId) async {
    try {
      final response = await _apiService.post('/invitations/', {
        'project': projectId,
        'receiver': receiverId,
        'status': 'PENDING',
      });
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error sending invitation: $e');
      return false;
    }
  }

  Future<bool> respondToInvitation(int id, String status) async {
    try {
      final response = await _apiService.post('/invitations/$id/respond/', {
        'status': status,
      });
      if (response.statusCode == 200) {
        fetchInvitations();
        return true;
      }
    } catch (e) {
      debugPrint('Error responding to invitation: $e');
    }
    return false;
  }

  Future<bool> likeProject(int projectId) async {
    int index = _projects.indexWhere((p) => p.id == projectId);
    int myRepoIndex = _myRepos.indexWhere((p) => p.id == projectId);

    if (index == -1 && myRepoIndex == -1) return false;

    Project originalProject = index != -1
        ? _projects[index]
        : _myRepos[myRepoIndex];
    final bool wasLiked = originalProject.isLiked;

    // Optimistic state update
    final optimisticProject = originalProject.copyWith(
      isLiked: !wasLiked,
      likeCount: wasLiked
          ? originalProject.likeCount - 1
          : originalProject.likeCount + 1,
    );

    if (index != -1) _projects[index] = optimisticProject;
    if (myRepoIndex != -1) _myRepos[myRepoIndex] = optimisticProject;
    notifyListeners();

    try {
      final response = await _apiService.post('/projects/$projectId/like/', {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final updatedProject = Project.fromJson(body);

        // Final update with real data
        index = _projects.indexWhere((p) => p.id == projectId);
        if (index != -1) _projects[index] = updatedProject;

        myRepoIndex = _myRepos.indexWhere((p) => p.id == projectId);
        if (myRepoIndex != -1) _myRepos[myRepoIndex] = updatedProject;

        notifyListeners();
        return true;
      } else {
        // Rollback
        if (index != -1) _projects[index] = originalProject;
        if (myRepoIndex != -1) _myRepos[myRepoIndex] = originalProject;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error liking project: $e');
      if (index != -1) _projects[index] = originalProject;
      if (myRepoIndex != -1) _myRepos[myRepoIndex] = originalProject;
      notifyListeners();
    }
    return false;
  }
}
