import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/resume_database_service.dart' show ResumeDatabaseService;

class ResumeScreen extends StatefulWidget {
  static const routeName = '/ai/resume';
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  PlatformFile? _file;
  bool _isUploading = false;
  double? _resumeScore;

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => _file = res.files.single);
    }
  }

  Future<void> _analyze() async {
    if (_file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a resume first')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      late Uint8List uploadData;

      // Get file data
      if (_file!.path != null) {
        uploadData = await File(_file!.path!).readAsBytes();
      } else if (_file!.bytes != null) {
        uploadData = _file!.bytes!;
      } else {
        throw Exception("Unable to read selected file");
      }

      // ✅ Save to Firestore using base64
      await ResumeDatabaseService.saveResumeAsBase64(
        userId: user.uid,
        fileName: _file!.name,
        fileData: uploadData,
      );
      print('✅ Resume saved to Firestore (base64)');

      // ✅ Score resume and show success
      final score = _calculateResumeScore(_file!);
      setState(() => _resumeScore = score);

      _showStatusDialog(
        success: true,
        message:
            "Resume uploaded and saved successfully!\nScore: ${score.toStringAsFixed(1)}%",
      );
    } catch (e) {
      print('❌ Analysis failed: $e');
      _showStatusDialog(
        success: false,
        message: "Upload failed: ${e.toString().replaceAll('Exception: ', '')}",
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  double _calculateResumeScore(PlatformFile file) {
    final fileSizeKB = file.size / 1024;
    if (fileSizeKB < 10) return 55.0;
    if (fileSizeKB > 1000) return 65.0;
    return 80.0 + (20 * (fileSizeKB / 1000).clamp(0.0, 1.0));
  }

  void _showStatusDialog({required bool success, required String message}) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(success ? 'Success' : 'Error'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Resume Analysis'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          children: [
            Text(
              'Upload your resume',
              style: text.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your resume to get personalized insights and score.',
              style: text.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(.7),
              ),
            ),
            const SizedBox(height: 24),
            DottedBorder(
              color: cs.outline,
              strokeWidth: 1.4,
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 36,
                ),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _file == null ? 'Upload Resume' : _file!.name,
                      textAlign: TextAlign.center,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _file == null
                          ? 'PDF, DOCX, or TXT'
                          : '${(_file!.size / 1024).toStringAsFixed(1)} KB',
                      style: text.bodySmall?.copyWith(color: cs.secondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.surfaceContainerHighest,
                        foregroundColor: cs.onSurface,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _isUploading ? null : _pickFile,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Text('Browse Files'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_resumeScore != null) ...[
              const SizedBox(height: 24),
              Text(
                'Resume Score: ${_resumeScore!.toStringAsFixed(1)}%',
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(shape: const StadiumBorder()),
            onPressed: _isUploading ? null : _analyze,
            child:
                _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Analyze Resume'),
          ),
        ),
      ),
    );
  }
}
