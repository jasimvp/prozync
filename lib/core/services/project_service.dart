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
  List<Project> _savedProjects = [];
  List<Invitation> _invitations = [];
  bool _isLoading = false; // used by fetchProjects (all projects feed)
  bool _isMyReposLoading = false;
  bool _isSavedLoading = false;
  bool _isPinnedLoading = false;

  List<Project> get projects => _projects;
  List<Project> get myRepos => _myRepos;
  bool get isSavedLoading => _isSavedLoading;
  bool get isMyReposLoading => _isMyReposLoading;
  bool get isPinnedLoading => _isPinnedLoading;

  /// Returns the current user's pinned projects.
  /// The API already filters to the current user, so no owner check needed.
  List<Project> get pinnedProjects => _pinnedProjects;

  // Saved projects (pinned projects from other users)
  List<Project> get savedProjects => _savedProjects;

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
        _projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      debugPrint('Error fetching projects: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches projects for a specific user without updating the global list.
  Future<List<Project>> getUserProjects(String username) async {
    try {
      final response = await _apiService.get('/projects/?search=$username');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Project.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching user projects: $e');
    }
    return [];
  }

  Future<void> fetchMyRepos() async {
    _isMyReposLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.get('/projects/my_repos/');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _myRepos = data.map((json) => Project.fromJson(json)).toList();
        _myRepos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      debugPrint('Error fetching my repos: $e');
    } finally {
      _isMyReposLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPinnedProjects() async {
    _isPinnedLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.get('/projects/pinned/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _pinnedProjects = data.map((json) => Project.fromJson(json)).toList();
        _pinnedProjects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      debugPrint('Error fetching pinned projects: $e');
    } finally {
      _isPinnedLoading = false;
      notifyListeners();
    }
  }

  /// Fetches all projects visible to the user and filters those the user has
  /// pinned/saved that belong to other users.
  Future<void> fetchSavedProjects() async {
    _isSavedLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final myId = ProfileService().myProfile?.id;

      // Fetch all projects
      final response = await _apiService.get('/projects/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final allProjects = data.map((json) => Project.fromJson(json)).toList();

        // Also try fetching user's pinned list to cross-reference
        final pinnedResp = await _apiService.get('/projects/pinned/');
        List<int> pinnedIds = [];
        if (pinnedResp.statusCode == 200) {
          final List<dynamic> pinnedData = jsonDecode(pinnedResp.body);
          pinnedIds = pinnedData.map<int>((j) => j['id'] as int).toList();
          // Persist pinned list for other uses
          _pinnedProjects = pinnedData.map((j) => Project.fromJson(j)).toList();
        }

        // A "saved" project = appears in pinned list AND belongs to someone else
        _savedProjects = allProjects.where((p) {
          final ownedByOther = myId == null || p.owner != myId;
          final isInPinnedList = p.isPinned || pinnedIds.contains(p.id);
          return ownedByOther && isInPinnedList;
        }).toList();
      } else {
        debugPrint(
          'fetchSavedProjects: projects/ returned ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching saved projects: $e');
    } finally {
      _isSavedLoading = false;
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
      if (response.statusCode == 201 || response.statusCode == 200) {
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

    // Keep _savedProjects in sync (projects saved from other users)
    final myId = ProfileService().myProfile?.id;
    final savedIndex = _savedProjects.indexWhere((p) => p.id == projectId);
    final isOthersProject = myId == null || project.owner != myId;
    if (isOthersProject) {
      if (project.isPinned) {
        if (savedIndex == -1) {
          _savedProjects.insert(0, project);
        } else {
          _savedProjects[savedIndex] = project;
        }
      } else {
        if (savedIndex != -1) _savedProjects.removeAt(savedIndex);
      }
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
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending invitation: $e');
      return false;
    }
  }

  Future<bool> respondToInvitation(int id, String status) async {
    try {
      final action = status.toLowerCase() == 'accepted' ? 'accept' : 'reject';
      final response = await _apiService.post('/invitations/$id/respond/', {
        'action': action,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
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

  Future<Project?> fetchProjectById(int id) async {
    try {
      final response = await _apiService.get('/projects/$id/');
      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching project $id: $e');
    }
    return null;
  }

  Future<Project?> updateProjectById(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/projects/$id/', data);
      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error updating project $id: $e');
    }
    return null;
  }

  Future<Project?> partialUpdateProjectById(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.patch('/projects/$id/', data);
      if (response.statusCode == 200) {
        return Project.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error partial updating project $id: $e');
    }
    return null;
  }

  Future<bool> toggleSaveProject(int projectId) async {
    // 1. Find the project in all lists
    int index = _projects.indexWhere((p) => p.id == projectId);
    int savedIndex = _savedProjects.indexWhere((p) => p.id == projectId);

    Project? original;
    if (index != -1)
      original = _projects[index];
    else if (savedIndex != -1)
      original = _savedProjects[savedIndex];

    if (original == null) return false;

    final wasSaved = original.isSaved;

    // 2. Perform Optimistic Update
    final optimistic = original.copyWith(isSaved: !wasSaved);

    // Update main lists
    if (index != -1) _projects[index] = optimistic;

    // Manage _savedProjects list based on new state
    if (!wasSaved) {
      if (savedIndex == -1) {
        _savedProjects.insert(0, optimistic);
      } else {
        _savedProjects[savedIndex] = optimistic;
      }
    } else {
      if (savedIndex != -1) {
        _savedProjects.removeAt(savedIndex);
      }
    }

    notifyListeners();

    try {
      final response = await _apiService.post(
        '/projects/$projectId/save_project/',
        {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        Project updated;
        if (body is Map && body.containsKey('id')) {
          updated = Project.fromJson(body as Map<String, dynamic>);
        } else {
          // If body is partial like {"is_saved": true}
          final serverState = body['is_saved'] ?? !wasSaved;
          updated = original.copyWith(isSaved: serverState);
        }
        _updateProjectInLists(projectId, updated);
        notifyListeners();
        return true;
      } else {
        // Rollback
        _updateProjectInLists(projectId, original);
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error toggling save for project $projectId: $e');
      _updateProjectInLists(projectId, original);
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveProject(int projectId) async {
    return toggleSaveProject(projectId);
  }

  Future<void> fetchMySavedProjects() async {
    _isSavedLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('/projects/my_saved/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _savedProjects = data.map((json) => Project.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching my saved projects: $e');
    } finally {
      _isSavedLoading = false;
      notifyListeners();
    }
  }

  Future<Invitation?> fetchInvitationById(int id) async {
    try {
      final response = await _apiService.get('/invitations/$id/');
      if (response.statusCode == 200) {
        return Invitation.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error fetching invitation $id: $e');
    }
    return null;
  }

  Future<Invitation?> updateInvitationById(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put('/invitations/$id/', data);
      if (response.statusCode == 200) {
        return Invitation.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error updating invitation $id: $e');
    }
    return null;
  }

  Future<Invitation?> partialUpdateInvitationById(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.patch('/invitations/$id/', data);
      if (response.statusCode == 200) {
        return Invitation.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error partial updating invitation $id: $e');
    }
    return null;
  }

  Future<bool> deleteInvitationById(int id) async {
    try {
      final response = await _apiService.delete('/invitations/$id/');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting invitation $id: $e');
      return false;
    }
  }

  Future<bool> inviteUser(int projectId, int userId) async {
    try {
      final response = await _apiService.post('/invitations/invite/', {
        'project': projectId,
        'user': userId,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error inviting user to project $projectId: $e');
      return false;
    }
  }

  Future<bool> toggleInterested(int projectId) async {
    // Find in all lists
    int index = _projects.indexWhere((p) => p.id == projectId);
    int myRepoIndex = _myRepos.indexWhere((p) => p.id == projectId);

    Project? original;
    if (index != -1)
      original = _projects[index];
    else if (myRepoIndex != -1)
      original = _myRepos[myRepoIndex];

    // If project is not cached (e.g., viewing from another user's profile),
    // still call the API directly
    if (original != null) {
      final wasInterested = original.isInterested;

      // Optimistic update
      final optimistic = original.copyWith(
        isInterested: !wasInterested,
        interestedCount: wasInterested
            ? original.interestedCount - 1
            : original.interestedCount + 1,
      );
      if (index != -1) _projects[index] = optimistic;
      if (myRepoIndex != -1) _myRepos[myRepoIndex] = optimistic;
      notifyListeners();
    }

    try {
      final response = await _apiService.post(
        '/projects/$projectId/interested/',
        {},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        // Only try to parse a full project if the response has an id field
        if (body is Map && body.containsKey('id')) {
          final updated = Project.fromJson(body as Map<String, dynamic>);
          _updateProjectInLists(projectId, updated);
        }
        notifyListeners();
        return true;
      } else {
        // Fallback: try different endpoint name if 404
        if (response.statusCode == 404) {
          final retryResponse = await _apiService.post(
            '/projects/$projectId/toggle_interested/',
            {},
          );
          if (retryResponse.statusCode == 200 ||
              retryResponse.statusCode == 201) {
            final body = jsonDecode(retryResponse.body);
            if (body is Map && body.containsKey('id')) {
              final updated = Project.fromJson(body as Map<String, dynamic>);
              _updateProjectInLists(projectId, updated);
            }
            notifyListeners();
            return true;
          }
        }
        // Rollback if we had an optimistic update
        if (original != null) {
          _updateProjectInLists(projectId, original);
          notifyListeners();
        }
        debugPrint(
          'toggleInterested failed: ${response.statusCode} ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error toggling interested for project $projectId: $e');
      if (original != null) {
        _updateProjectInLists(projectId, original);
        notifyListeners();
      }
      return false;
    }
  }

  void clear() {
    _projects = [];
    _myRepos = [];
    _pinnedProjects = [];
    _savedProjects = [];
    _invitations = [];
    _isLoading = false;
    _isPinnedLoading = false;
    _isMyReposLoading = false;
    notifyListeners();
  }
}
