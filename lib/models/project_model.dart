class Project {
  final int id;
  final int owner;
  final String ownerName;
  final String projectName;
  final String slug;
  final String description;
  final String technology;
  final String? projectZip;
  final String? coverImage;
  final String? readme;
  final bool isPrivate;
  final String collaboratorCount;
  final List<dynamic> collaborators;
  final DateTime createdAt;
  bool isPinned;

  Project({
    required this.id,
    required this.owner,
    required this.ownerName,
    required this.projectName,
    required this.slug,
    required this.description,
    required this.technology,
    this.projectZip,
    this.coverImage,
    this.readme,
    required this.isPrivate,
    required this.collaboratorCount,
    this.collaborators = const [],
    required this.createdAt,
    this.isPinned = false,
  });

  // UI Compatibility Getters
  String get name => projectName;
  String get language => technology;
  String get projectType => "Repo";
  DateTime get lastUpdated => createdAt;
  bool get isMyRepo => true;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      owner: json['owner'],
      ownerName: json['owner_name'],
      projectName: json['project_name'],
      slug: json['slug'],
      description: json['description'] ?? '',
      technology: json['technology'] ?? '',
      projectZip: json['project_zip'],
      coverImage: json['cover_image'],
      readme: json['readme'],
      isPrivate: json['is_private'] ?? false,
      collaboratorCount: json['collaborator_count'].toString(),
      collaborators: json['collaborators'] ?? [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner': owner,
      'project_name': projectName,
      'slug': slug,
      'description': description,
      'technology': technology,
      'project_zip': projectZip,
      'cover_image': coverImage,
      'readme': readme,
      'is_private': isPrivate,
    };
  }
}
