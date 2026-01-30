import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../../domain/usecases/upload_artifact_usecase.dart';
import '../../domain/repositories/artifact_repository.dart';

class UploadImagesScreen extends StatefulWidget {
  const UploadImagesScreen({super.key});

  @override
  State<UploadImagesScreen> createState() => _UploadImagesScreenState();
}

class _UploadImagesScreenState extends State<UploadImagesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _platformNotifier = ValueNotifier<String?>('PC DOS');
  final _dateNotifier = ValueNotifier<DateTime>(DateTime.now());
  final _fileNotifier = ValueNotifier<File?>(null);
  final _progressNotifier = ValueNotifier<double>(0.0);
  final _isUploadingNotifier = ValueNotifier<bool>(false);

  final List<String> _platforms = [
    'PC DOS',
    'Amiga',
    'Commodore 64',
    'Atari ST',
    'ZX Spectrum',
    'Nintendo NES',
    'Sega Genesis',
  ];

  late UploadArtifactUseCase _uploadUseCase;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = Provider.of<ArtifactRepository>(context);
    _uploadUseCase = UploadArtifactUseCase(repository);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _platformNotifier.dispose();
    _dateNotifier.dispose();
    _fileNotifier.dispose();
    _progressNotifier.dispose();
    _isUploadingNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['iso'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      _fileNotifier.value = File(result.files.single.path!);
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fileNotifier.value == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a file')));
      return;
    }

    _isUploadingNotifier.value = true;
    _progressNotifier.value = 0.0;

    try {
      await _uploadUseCase(
        UploadArtifactParams(
          title: _titleController.text,
          platform: _platformNotifier.value!,
          releaseDate: _dateNotifier.value,
          file: _fileNotifier.value!,
          onProgress: (progress) {
            _progressNotifier.value = progress;
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Przesyłanie zakończone sukcesem!')),
        );
        _titleController.clear();
        _fileNotifier.value = null;
        _progressNotifier.value = 0.0;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      _isUploadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Błąd')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Widok nie jest dostępny na tej platformie.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Prześlij Obraz (Desktop)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tytuł',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Wprowadź tytuł'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String?>(
                    valueListenable: _platformNotifier,
                    builder: (context, value, _) {
                      return DropdownButtonFormField<String>(
                        value: value,
                        decoration: const InputDecoration(
                          labelText: 'Platforma',
                          border: OutlineInputBorder(),
                        ),
                        items: _platforms
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        onChanged: (v) => _platformNotifier.value = v,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<DateTime>(
                    valueListenable: _dateNotifier,
                    builder: (context, date, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Data Wydania',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: date,
                                firstDate: DateTime(1970),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) _dateNotifier.value = picked;
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ValueListenableBuilder<File?>(
                    valueListenable: _fileNotifier,
                    builder: (context, file, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                file != null
                                    ? p.basename(file.path)
                                    : 'Nie wybrano pliku (.iso)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _pickFile,
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Przeglądaj'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isUploadingNotifier,
                    builder: (context, isUploading, _) {
                      if (isUploading) {
                        return ValueListenableBuilder<double>(
                          valueListenable: _progressNotifier,
                          builder: (context, progress, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(value: progress),
                                const SizedBox(height: 8),
                                Text(
                                  'Przesyłanie: ${(progress * 100).toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _upload,
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('PRZEŚLIJ OBRAZ'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
