import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/interview_database_service.dart'
    show InterviewDatabaseService;
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';

class InterviewScreen extends StatefulWidget {
  static const routeName = '/ai/interview';
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  PlatformFile? _file;
  bool _isUploading = false;

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
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      late Uint8List uploadData;

      if (_file!.path != null) {
        uploadData = await File(_file!.path!).readAsBytes();
      } else if (_file!.bytes != null) {
        uploadData = _file!.bytes!;
      } else {
        throw Exception("Unable to read selected file");
      }

      // ✅ Save interview file as base64
      await InterviewDatabaseService.saveInterviewAsBase64(
        userId: user.uid,
        fileName: _file!.name,
        fileData: uploadData,
      );

      _showStatusDialog(
        success: true,
        message: "Interview file uploaded and saved to Firestore!",
      );
    } catch (e) {
      _showStatusDialog(success: false, message: "Upload failed: $e");
    } finally {
      setState(() => _isUploading = false);
    }
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
        title: const Text('Interview Upload'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          children: [
            Text(
              'Upload your interview file',
              style: text.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload interview-related documents to get valuable insights.',
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
                      _file == null ? 'Upload File' : _file!.name,
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
                    : const Text('Analyze Interview File'),
          ),
        ),
      ),
    );
  }
}
