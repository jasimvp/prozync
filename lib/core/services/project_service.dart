import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import 'api_service.dart';

class ProjectService extends ChangeNotifier {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  final ApiService _apiService = ApiService();
  List<Project> _projects = [];
  List<Project> _myRepos = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  List<Project> get myRepos => _myRepos;
  List<Project> get savedProjects => _projects.where((p) => p.isPinned).toList();
  bool get isLoading => _isLoading;

  Future<void> fetchProjects({String? search}) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final endpoint = search != null ? '/projects/?search=$search' : '/projects/';
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
    notifyListeners();

    try {
      final response = await _apiService.get('/projects/my_repos/');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _myRepos = data.map((json) => Project.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching my repos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Project?> createProject(Map<String, String> data, {http.MultipartFile? file}) async {
    try {
      final response = await _apiService.postMultipart('/projects/', data, file: file);
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

  void togglePin(int projectId) {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index].isPinned = !_projects[index].isPinned;
      notifyListeners();
    }
  }
}
