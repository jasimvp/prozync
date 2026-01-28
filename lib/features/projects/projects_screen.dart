import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:prozync/features/profile/other_user_profile_screen.dart';
import 'package:prozync/features/projects/project_details_screen.dart';
import 'package:prozync/models/project_model.dart';
import 'package:prozync/core/services/project_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:prozync/core/theme/app_theme.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    _projectService.fetchProjects();
    _projectService.fetchMyRepos();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _projectService,
      builder: (context, _) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Projects Explorer'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () => _showUploadBottomSheet(context),
                  icon: const Icon(Icons.add_circle_outline, size: 28),
                  tooltip: 'New Project',
                ),
                const SizedBox(width: 8),
              ],
              bottom: TabBar(
                tabs: const [
                  Tab(text: 'My Portfolio'),
                  Tab(text: 'Collaborations'),
                ],
                indicatorColor: AppTheme.primaryColor,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            body: _projectService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _buildProjectList(context, projects: _projectService.myRepos),
                      _buildProjectList(context, projects: _projectService.projects.where((p) => p.ownerName != 'DevUser').toList()),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildProjectList(BuildContext context, {required List<Project> projects}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No projects yet', style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Start your journey by creating one.', style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _projectService.fetchProjects(),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Refresh Feed'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isWide ? 1000 : double.infinity),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 0 : 20,
            vertical: 20,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            return _buildProjectCard(context, projects[index]);
          },
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailsScreen(
                  project: project,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (project.isPrivate ? Colors.orange : Colors.blue).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        project.isPrivate ? Icons.lock_outline : Icons.code_rounded,
                        color: project.isPrivate ? Colors.orange : Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              _buildLanguageDot(_getLanguageColor(project.language)),
                              const SizedBox(width: 6),
                              Text(
                                project.language,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildTypeTag(project.projectType),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (project.ownerName == 'DevUser')
                      IconButton(
                        icon: Icon(
                          project.isPinned ? Icons.star : Icons.star_border,
                          color: project.isPinned ? Colors.amber : Colors.grey[400],
                        ),
                        onPressed: () {
                          _projectService.togglePin(project.id);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  project.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherUserProfileScreen(
                              userName: project.ownerName,
                              userDesignation: 'Developer',
                              userImage: 'https://ui-avatars.com/api/?name=${project.ownerName}&background=random',
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${project.ownerName}&background=random'),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '@${project.ownerName}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Updated recently',
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildTypeTag(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'flutter': return Colors.blue;
      case 'javascript': return Colors.yellow[700]!;
      case 'python': return Colors.blue[800]!;
      case 'react': return Colors.cyan;
      default: return Colors.grey;
    }
  }

  void _showUploadBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String? selectedFileName;
    String? selectedFilePath;
    dynamic selectedFileBytes;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('New Project', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBottomSheetTextField('Project Name', Icons.drive_file_rename_outline, nameController),
                        const SizedBox(height: 20),
                        _buildBottomSheetTextField('Description', Icons.description_outlined, descController, maxLines: 3),
                        const SizedBox(height: 32),
                        const Text('Source Code (ZIP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['zip'],
                              withData: kIsWeb,
                            );

                            if (result != null) {
                              setModalState(() {
                                selectedFileName = result.files.first.name;
                                selectedFileBytes = result.files.first.bytes;
                                selectedFilePath = result.files.first.path;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.withOpacity(0.2), style: BorderStyle.solid),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue[300]),
                                const SizedBox(height: 12),
                                Text(
                                  selectedFileName ?? 'Click to select project ZIP',
                                  style: TextStyle(
                                    color: selectedFileName != null ? Colors.blue : Colors.grey[600],
                                    fontWeight: selectedFileName != null ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isUploading ? null : () async {
                              if (nameController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a project name')));
                                return;
                              }
                              if (selectedFileName == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a ZIP file')));
                                return;
                              }

                              setModalState(() => isUploading = true);

                              http.MultipartFile? multipartFile;
                              if (kIsWeb && selectedFileBytes != null) {
                                multipartFile = http.MultipartFile.fromBytes('project_zip', selectedFileBytes, filename: selectedFileName);
                              } else if (!kIsWeb && selectedFilePath != null) {
                                multipartFile = await http.MultipartFile.fromPath('project_zip', selectedFilePath!);
                              }

                              final success = await _projectService.createProject({
                                'project_name': nameController.text,
                                'slug': nameController.text.toLowerCase().replaceAll(' ', '-'),
                                'description': descController.text,
                                'technology': 'Flutter',
                                'is_private': 'false',
                              }, file: multipartFile);

                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success != null ? 'Project published!' : 'Upload failed'),
                                    backgroundColor: success != null ? Colors.green : Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                            ),
                            child: isUploading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Publish Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomSheetTextField(String label, IconData icon, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue, size: 20),
            hintText: 'Enter $label',
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
