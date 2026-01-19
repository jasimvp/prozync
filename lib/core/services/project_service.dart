import 'package:flutter/material.dart';
import '../../models/project_model.dart';

class ProjectService extends ChangeNotifier {
  // Singleton pattern
  static final ProjectService _instance = ProjectService._internal();

  factory ProjectService() {
    return _instance;
  }

  ProjectService._internal() {
    _initializeMockData();
  }

  final List<Project> _projects = [];

  List<Project> get projects => _projects;
  List<Project> get myWorks => _projects.where((p) => p.isPinned && p.isMyRepo).toList();
  // Mock saved projects (others' projects that I saved)
  List<Project> get savedProjects => _projects.where((p) => !p.isMyRepo).take(3).toList(); // Just grouping some as saved for demo

  void _initializeMockData() {
    _projects.addAll([
      Project(
        id: '1',
        name: 'prozync-mobile',
        description: 'A professional cross-platform mobile application built with Flutter.',
        language: 'Flutter',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        isMyRepo: true,
      ),
       Project(
        id: '2',
        name: 'backend-api-v2',
        description: 'Scalable REST API built with Node.js and Express.',
        language: 'JavaScript',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        isMyRepo: true,
      ),
      Project(
        id: '3',
        name: 'data-analytics-dashboard',
        description: 'Real-time analytics dashboard using React and D3.js.',
        language: 'React',
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
        isMyRepo: false, // Collaboration
      ),
       Project(
        id: '4',
        name: 'ai-recommendation-engine',
        description: 'Python-based recommendation system using TensorFlow.',
        language: 'Python',
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        isMyRepo: true,
        isPinned: true, // Initially pinned example
      ),
      Project(
        id: '5',
        name: 'legacy-systems-migration',
        description: 'Documentation and scripts for migrating legacy databases.',
        language: 'Shell',
        lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
        isMyRepo: false,
      ),
    ]);
  }

  void togglePin(String projectId) {
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index].isPinned = !_projects[index].isPinned;
      notifyListeners();
    }
  }
}
