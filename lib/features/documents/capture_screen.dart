import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/models/finance.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/motion.dart';
import '../../data/repositories/workspace.dart';
import '../../data/services/document_extraction_service.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});
  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  Uint8List? preview;
  String? filename;
  String error = '';
  bool busy = false;
  FinanceDocument? result;
  String? target = 't4';
  Future<void> pick(ImageSource? source) async {
    setState(() {
      error = '';
      result = null;
      preview = null;
      filename = null;
    });
    try {
      Uint8List? bytes;
      String? name;
      if (source != null) {
        final photo = await ImagePicker().pickImage(
          source: source,
          maxWidth: 1600,
          imageQuality: 85,
        );
        if (photo == null) {
          return;
        }
        bytes = await photo.readAsBytes();
        name = photo.name;
      } else {
        final selection = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
          withData: true,
        );
        if (selection == null) {
          return;
        }
        bytes = selection.files.single.bytes;
        name = selection.files.single.name;
        if (bytes == null) {
          throw StateError('Unreadable file');
        }
      }
      if (bytes.length > 10 * 1024 * 1024) {
        throw StateError('File too large');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        filename = name;
        preview = name!.toLowerCase().endsWith('.pdf') ? null : bytes;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Could not open this file. Check permissions and choose an image or PDF under 10 MB.',
        );
      }
    }
  }

  Future<void> process() async {
    setState(() {
      busy = true;
      error = '';
    });
    final document = await DemoDocumentExtractionService().extract();
    if (mounted) {
      setState(() {
        result = document;
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceProvider);
    final targets = state.transactions
        .where(
          (t) =>
              t.document == null && t.status != ReconciliationStatus.reconciled,
        )
        .toList();
    if (!targets.any((t) => t.id == target)) {
      target = targets.firstOrNull?.id;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Capture document')),
      body: PageBody(
        children: [
          const Notice(
            'Demo extraction · Files stay on this device. The example fields below are synthetic and are not read from your file.',
          ),
          if (!state.demo)
            const Notice(
              'Document capture is currently available in demo mode only.',
            ),
          if (state.demo) ...[
            Text(
              'From paper to a clear next step.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: busy ? null : () => pick(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Camera'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : () => pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_outlined),
                  label: const Text('Photos'),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : () => pick(null),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload file'),
                ),
              ],
            ),
            TextButton(
              onPressed: busy
                  ? null
                  : () {
                      setState(() {
                        filename = 'Synthetic cafe receipt';
                        preview = null;
                        result = null;
                      });
                    },
              child: const Text('Use sample receipt'),
            ),
            if (filename != null) ...[
              Text(filename!),
              if (preview != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Image.memory(
                    preview!,
                    height: 180,
                    errorBuilder: (_, _, _) =>
                        const Text('Image preview unavailable'),
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: busy ? null : process,
                child: ActionLabel(
                  busy: busy,
                  label: 'Show demo extraction',
                  busyLabel: 'Processing example…',
                ),
              ),
            ],
            if (error.isNotEmpty) Notice(error),
            if (result != null) ...[
              const SizedBox(height: 24),
              Text(
                'Review extracted fields',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Notice(
                '${result!.supplier}\n${money(result!.amountPence)} · ${result!.reference}\n16 September 2026 · 94% extraction confidence',
              ),
              DropdownButtonFormField<String>(
                initialValue: target,
                decoration: const InputDecoration(
                  labelText: 'Potential transaction',
                ),
                items: targets
                    .map(
                      (t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(t.merchant),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => target = v),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: busy || target == null
                    ? null
                    : () async {
                        setState(() => busy = true);
                        await state.refreshPlan();
                        final saved = await state.capture(result!, target!);
                        if (!mounted) {
                          return;
                        }
                        setState(() => busy = false);
                        if (context.mounted) {
                          if (saved) {
                            context.replace('/transaction/$target');
                          } else {
                            context.push('/subscriptions');
                          }
                        }
                      },
                child: const Text('Confirm and review match'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
