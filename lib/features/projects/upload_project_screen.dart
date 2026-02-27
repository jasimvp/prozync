import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:prozync/core/services/project_service.dart';
import 'package:prozync/core/theme/app_theme.dart';

class UploadProjectScreen extends StatefulWidget {
  const UploadProjectScreen({super.key});

  @override
  State<UploadProjectScreen> createState() => _UploadProjectScreenState();
}

class _UploadProjectScreenState extends State<UploadProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _techController = TextEditingController();
  final _readmeController = TextEditingController();
  
  String? _selectedFileName;
  String? _selectedFilePath;
  dynamic _selectedFileBytes;
  
  XFile? _selectedCoverImage;
  Uint8List? _selectedCoverImageBytes;
  
  bool _isPrivate = false;
  bool _isUploading = false;
  
  final _imagePicker = ImagePicker();

  Future<void> _pickZipFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.first.name;
        _selectedFileBytes = result.files.first.bytes;
        _selectedFilePath = result.files.first.path;
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedCoverImage = image;
        _selectedCoverImageBytes = bytes;
      });
    }
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project ZIP file')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      List<http.MultipartFile> files = [];

      // ZIP File
      if (kIsWeb && _selectedFileBytes != null) {
        files.add(http.MultipartFile.fromBytes(
          'project_zip',
          _selectedFileBytes,
          filename: _selectedFileName!.replaceAll(RegExp(r'[^\w.]'), '_'),
          contentType: MediaType('application', 'zip'),
        ));
      } else if (!kIsWeb && _selectedFilePath != null) {
        files.add(await http.MultipartFile.fromPath(
          'project_zip',
          _selectedFilePath!,
          contentType: MediaType('application', 'zip'),
        ));
      }

      // Cover Image - Sending under multiple keys to ensure backend compatibility
      if (_selectedCoverImage != null) {
        final extension = _selectedCoverImage!.name.split('.').last.toLowerCase();
        final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
        final fileName = 'project_cover_${DateTime.now().millisecondsSinceEpoch}.$extension';
        final fileBytes = _selectedCoverImageBytes;
        final filePath = _selectedFilePath;

        // List of keys to try (backend might expect any of these)
        final imageKeys = ['cover_image', 'Cover_image', 'image', 'project_image'];

        for (final key in imageKeys) {
          if (kIsWeb && fileBytes != null) {
            files.add(http.MultipartFile.fromBytes(
              key,
              fileBytes,
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            ));
          } else if (!kIsWeb && filePath != null) {
            files.add(await http.MultipartFile.fromPath(
              key,
              filePath,
              contentType: MediaType.parse(mimeType),
            ));
          }
        }
      }

      final result = await ProjectService().createProject({
        'project_name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'technology': _techController.text.trim(),
        'readme': _readmeController.text.trim(),
        'is_private': _isPrivate.toString(),
      }, files: files);

      if (mounted) {
        setState(() => _isUploading = false);
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload project. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish New Project'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Project Details'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Project Name',
                hint: 'e.g. My Awesome App',
                icon: Icons.title_rounded,
                validator: (v) => v!.isEmpty ? 'Enter project name' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _techController,
                label: 'Technology Stack',
                hint: 'e.g. Flutter, Firebase, Node.js',
                icon: Icons.code_rounded,
                validator: (v) => v!.isEmpty ? 'Enter technology stack' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _descController,
                label: 'Short Description',
                hint: 'What does this project do?',
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _readmeController,
                label: 'README Content',
                hint: 'Detailed instructions or documentation (Markdown allowed)',
                icon: Icons.article_outlined,
                maxLines: 5,
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Assets'),
              const SizedBox(height: 16),
              
              // Cover Image Picker
              const Text('Cover Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickCoverImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    image: _selectedCoverImageBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_selectedCoverImageBytes!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedCoverImageBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppTheme.primaryColor.withOpacity(0.5)),
                            const SizedBox(height: 8),
                            const Text('Select a cover image', style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ZIP Picker
              const Text('Source Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickZipFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _selectedFileName != null 
                        ? Colors.green.withOpacity(0.05) 
                        : AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedFileName != null 
                          ? Colors.green.withOpacity(0.3) 
                          : AppTheme.primaryColor.withOpacity(0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedFileName != null ? Icons.check_circle_rounded : Icons.folder_zip_outlined,
                        size: 32,
                        color: _selectedFileName != null ? Colors.green : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _selectedFileName ?? 'Select Project ZIP file',
                          style: TextStyle(
                            color: _selectedFileName != null ? Colors.green[700] : Colors.grey[600],
                            fontWeight: _selectedFileName != null ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Settings'),
              SwitchListTile(
                title: const Text('Private Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Only you can view this project'),
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  _isPrivate ? Icons.lock_rounded : Icons.public_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _handleUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Publish Project',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
