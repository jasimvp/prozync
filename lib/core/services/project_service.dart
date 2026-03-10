import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../../models/social_model.dart';

class ProjectService extends ChangeNotifier {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  List<Project> _projects = [];
  List<Project> _myRepos = [];
  List<Project> _pinnedProjects = [];
  List<Project> _savedProjects = [];
  List<Invitation> _invitations = [];
  bool _isLoading = false;
  bool _isMyReposLoading = false;
  bool _isSavedLoading = false;
  bool _isPinnedLoading = false;

  List<Project> get projects => _projects;
  List<Project> get myRepos => _myRepos;
  List<Project> get pinnedProjects => _pinnedProjects;
  List<Project> get savedProjects => _savedProjects;
  List<Invitation> get invitations => _invitations;
  bool get isLoading => _isLoading;
  bool get isMyReposLoading => _isMyReposLoading;
  bool get isSavedLoading => _isSavedLoading;
  bool get isPinnedLoading => _isPinnedLoading;

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

  Future<Map<String, dynamic>> createProject(Map<String, String> data, {List<dynamic>? files}) async {
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

  Future<bool> togglePin(int projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx != -1) {
      _projects[idx] = _projects[idx].copyWith(isPinned: !_projects[idx].isPinned);
      if (_projects[idx].isPinned) {
        if (!_pinnedProjects.any((p) => p.id == projectId)) _pinnedProjects.add(_projects[idx]);
      } else {
        _pinnedProjects.removeWhere((p) => p.id == projectId);
      }
      notifyListeners();
    }
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

  Future<bool> respondToInvitation(int id, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _invitations.removeWhere((i) => i.id == id);
    notifyListeners();
    return true;
  }

  Future<bool> likeProject(int projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx != -1) {
      final wasLiked = _projects[idx].isLiked;
      _projects[idx] = _projects[idx].copyWith(
        isLiked: !wasLiked,
        likeCount: wasLiked ? _projects[idx].likeCount - 1 : _projects[idx].likeCount + 1,
      );
      notifyListeners();
    }
    return true;
  }

  Future<Project?> fetchProjectById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _projects.firstWhere((p) => p.id == id, orElse: () => _projects.isNotEmpty ? _projects[0] : throw Exception('Not found'));
  }

  Future<bool> toggleSaveProject(int projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _projects.indexWhere((p) => p.id == projectId);
    if (idx != -1) {
      _projects[idx] = _projects[idx].copyWith(isSaved: !_projects[idx].isSaved);
      if (_projects[idx].isSaved) {
        if (!_savedProjects.any((p) => p.id == projectId)) _savedProjects.add(_projects[idx]);
      } else {
        _savedProjects.removeWhere((p) => p.id == projectId);
      }
      notifyListeners();
    }
    return true;
  }

  void clear() {
    _projects = [];
    _myRepos = [];
    _pinnedProjects = [];
    _savedProjects = [];
    _invitations = [];
    _isLoading = false;
    notifyListeners();
  }
}
