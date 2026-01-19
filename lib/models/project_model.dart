class Project {
  final String id;
  final String name;
  final String description;
  final String language;
  final DateTime lastUpdated;
  bool isPinned;
  final bool isMyRepo; // To distinguish between my repos and collaborations

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.language,
    required this.lastUpdated,
    this.isPinned = false,
    this.isMyRepo = true,
  });
}
