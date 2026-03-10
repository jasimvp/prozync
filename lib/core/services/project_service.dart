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

    await Future.delayed(const Duration(milliseconds: 500));
    _projects = [
      Project(
        id: 1,
        owner: 1,
        ownerName: 'jasim_dev',
        projectName: 'Prozync',
        slug: 'prozync',
        description: 'Advanced Agentic Coding Platform',
        technology: 'Flutter',
        isPrivate: false,
        collaboratorCount: '3',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        likeCount: 45,
        isLiked: true,
        isPinned: true,
      ),
      Project(
        id: 2,
        owner: 2,
        ownerName: 'alice_smith',
        projectName: 'E-commerce API',
        slug: 'ecommerce-api',
        description: 'Scalable backend for online stores',
        technology: 'Python/Django',
        isPrivate: false,
        collaboratorCount: '5',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        likeCount: 120,
        isLiked: false,
        isPinned: false,
      ),
    ];

    if (search != null && search.isNotEmpty) {
      _projects = _projects.where((p) => p.projectName.toLowerCase().contains(search.toLowerCase()) || p.technology.toLowerCase().contains(search.toLowerCase())).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Project>> getUserProjects(String username) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _projects.where((p) => p.ownerName == username).toList();
  }

  Future<void> fetchMyRepos() async {
    _isMyReposLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _myRepos = [
      Project(
        id: 1,
        owner: 1,
        ownerName: 'jasim_dev',
        projectName: 'Prozync',
        slug: 'prozync',
        description: 'Advanced Agentic Coding Platform',
        technology: 'Flutter',
        isPrivate: false,
        collaboratorCount: '3',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        likeCount: 45,
        isLiked: true,
        isPinned: true,
      ),
      Project(
        id: 3,
        owner: 1,
        ownerName: 'jasim_dev',
        projectName: 'Personal Budgeter',
        slug: 'budgeter',
        description: 'Track your expenses locally',
        technology: 'Dart',
        isPrivate: true,
        collaboratorCount: '0',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        likeCount: 12,
        isLiked: false,
        isPinned: false,
      ),
    ];

    _isMyReposLoading = false;
    notifyListeners();
  }

  Future<void> fetchPinnedProjects() async {
    _isPinnedLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _pinnedProjects = _projects.where((p) => p.isPinned).toList();
    
    _isPinnedLoading = false;
    notifyListeners();
  }

  Future<void> fetchSavedProjects() async {
    _isSavedLoading = true;
    Future.microtask(() => notifyListeners());

    await Future.delayed(const Duration(milliseconds: 500));
    _savedProjects = _projects.where((p) => p.isSaved).toList();

    _isSavedLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createProject(
    Map<String, String> data, {
    List<http.MultipartFile>? files,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final newProject = Project(
      id: DateTime.now().millisecondsSinceEpoch,
      owner: 1,
      ownerName: 'jasim_dev',
      projectName: data['project_name'] ?? 'New Project',
      slug: (data['project_name'] ?? 'new').toLowerCase().replaceAll(' ', '-'),
      description: data['description'] ?? '',
      technology: data['technology'] ?? '',
      isPrivate: data['is_private'] == 'true',
      collaboratorCount: '0',
      createdAt: DateTime.now(),
    );
    _projects.insert(0, newProject);
    _myRepos.insert(0, newProject);
    notifyListeners();
    return {'success': true, 'project': newProject};
  }

  Future<bool> deleteProject(int id) async {
    await Future.delayed(const Duration(seconds: 1));
    _projects.removeWhere((p) => p.id == id);
    _myRepos.removeWhere((p) => p.id == id);
    notifyListeners();
    return true;
  }

  Project getProjectById(int id, Project fallback) {
    try {
      return [..._projects, ..._myRepos, ..._pinnedProjects]
          .firstWhere((p) => p.id == id);
    } catch (_) {
      return fallback;
    }
  }

  Future<bool> togglePin(int projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    void updateList(List<Project> list) {
      final idx = list.indexWhere((p) => p.id == projectId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(isPinned: !list[idx].isPinned);
      }
    }

    updateList(_projects);
    updateList(_myRepos);
    
    final p = getProjectById(projectId, _projects[0]);
    if (p.isPinned) {
      if (!_pinnedProjects.any((item) => item.id == projectId)) {
        _pinnedProjects.add(p);
      }
    } else {
      _pinnedProjects.removeWhere((item) => item.id == projectId);
    }

    notifyListeners();
    return true;
  }

  Future<void> fetchInvitations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _invitations = [
      Invitation(
        id: 1,
        project: 2,
        projectName: 'E-commerce API',
        senderName: 'alice_smith',
        receiver: 1,
        status: 'PENDING',
        sentAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
    notifyListeners();
  }

  Future<bool> sendInvitation(int projectId, int receiverId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> respondToInvitation(int id, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _invitations.removeWhere((i) => i.id == id);
    notifyListeners();
    return true;
  }

  Future<bool> likeProject(int projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    void updateList(List<Project> list) {
      final idx = list.indexWhere((p) => p.id == projectId);
      if (idx != -1) {
        final wasLiked = list[idx].isLiked;
        list[idx] = list[idx].copyWith(
          isLiked: !wasLiked,
          likeCount: wasLiked ? list[idx].likeCount - 1 : list[idx].likeCount + 1,
        );
      }
    }
    updateList(_projects);
    updateList(_myRepos);
    notifyListeners();
    return true;
  }

  Future<Project?> fetchProjectById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getProjectById(id, _projects[0]);
  }

  Future<Project?> updateProjectById(int id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  Future<Project?> partialUpdateProjectById(
    int id,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  Future<bool> toggleSaveProject(int projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    void updateList(List<Project> list) {
      final idx = list.indexWhere((p) => p.id == projectId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(isSaved: !list[idx].isSaved);
      }
    }
    updateList(_projects);
    notifyListeners();
    return true;
  }

  Future<bool> saveProject(int projectId) async {
    return toggleSaveProject(projectId);
  }

  Future<void> fetchMySavedProjects() async {
    _isSavedLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _savedProjects = _projects.where((p) => p.isSaved).toList();
    _isSavedLoading = false;
    notifyListeners();
  }

  Future<Invitation?> fetchInvitationById(int id) async {
    return null;
  }

  Future<Invitation?> updateInvitationById(
    int id,
    Map<String, dynamic> data,
  ) async {
    return null;
  }

  Future<Invitation?> partialUpdateInvitationById(
    int id,
    Map<String, dynamic> data,
  ) async {
    return null;
  }

  Future<bool> deleteInvitationById(int id) async {
    return true;
  }

  Future<bool> inviteUser(int projectId, int userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> toggleInterested(int projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    void updateList(List<Project> list) {
      final idx = list.indexWhere((p) => p.id == projectId);
      if (idx != -1) {
        final wasInt = list[idx].isInterested;
        list[idx] = list[idx].copyWith(
          isInterested: !wasInt,
          interestedCount: wasInt ? list[idx].interestedCount - 1 : list[idx].interestedCount + 1,
        );
      }
    }
    updateList(_projects);
    notifyListeners();
    return true;
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
