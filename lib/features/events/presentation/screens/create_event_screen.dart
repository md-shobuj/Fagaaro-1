import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

/// Step 1 of event creation: name, category, cover image and description.
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  static const int _maxCoverBytes = 10 * 1024 * 1024;
  static const List<String> _categories = [
    'Technology & Innovation',
    'Music & Entertainment',
    'Business & Networking',
    'Arts & Culture',
    'Sports & Fitness',
    'Food & Drink',
    'Education',
    'Other',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  String? _category;
  String? _coverPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    try {
      final PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
      );
      if (file == null || !mounted) return;

      final int size = file.lengthSync() ?? await file.length() ?? 0;
      if (!mounted) return;
      if (size > _maxCoverBytes) {
        _showError('Cover image must be 10MB or smaller.');
        return;
      }
      setState(() => _coverPath = file.path);
    } on PlatformException catch (e) {
      debugPrint('Cover pick failed: ${e.code} ${e.message}');
      if (!mounted) return;
      _showError('Could not open the file picker. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _onCancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.homePath);
    }
  }

  void _onNext() {
    if (_formKey.currentState?.validate() ?? false) {
      context.push(AppRouter.scheduleEventPath);
    }
  }

  String? _required(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: _onCancel,
        ),
        title: const Text(
          'Create Event',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Information',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Provide the core details and visual identity for your event to attract attendees.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.63,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _FieldLabel('EVENT NAME'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: _inputTextStyle,
                      decoration: _inputDecoration(hint: 'Enter event name'),
                      validator: (v) => _required(v, 'Event name is required'),
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('EVENT CATEGORY'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: _inputTextStyle,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                      ),
                      decoration: _inputDecoration(hint: 'Select a category'),
                      items: [
                        for (final String c in _categories)
                          DropdownMenuItem<String>(
                            value: c,
                            child: Text(c, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (v) => setState(() => _category = v),
                      validator: (v) => v == null ? 'Select a category' : null,
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('EVENT COVER IMAGE'),
                    const SizedBox(height: 6),
                    _CoverUploadCard(imagePath: _coverPath, onTap: _pickCover),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FieldLabel('FULL EVENT DESCRIPTION'),
                        Text(
                          'Detailed overview',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 8,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.63,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Describe your event, agenda and what attendees can expect',
                        vertical: 10,
                      ),
                      validator: (v) => _required(v, 'Description is required'),
                    ),
                    const SizedBox(height: 16),
                    const _NextStepsBanner(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _CancelButton(onPressed: _onCancel),
                        ),
                        const SizedBox(width: 10),
                        // Next gets double the width: it is the primary action.
                        Expanded(
                          flex: 2,
                          child: _NextButton(onPressed: _onNext),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const TextStyle _inputTextStyle = TextStyle(
    color: Color(0xFF0F172A),
    fontSize: 14,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  static InputDecoration _inputDecoration({required String hint, double vertical = 12}) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: vertical),
      enabledBorder: border(const Color(0xFFE2E8F0)),
      focusedBorder: border(const Color(0xFF084DFB), 1.5),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 1.5),
    );
  }
}

/// Uppercase field label with the red required asterisk.
class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(
      color: Color(0xFF475569),
      fontSize: 11,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
      height: 1.5,
      letterSpacing: 0.55,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$text ', style: style),
          TextSpan(
            text: '*',
            style: style.copyWith(color: const Color(0xFFF43F5E)),
          ),
        ],
      ),
    );
  }
}

class _CoverUploadCard extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const _CoverUploadCard({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        painter: const _DashedBorderPainter(
          color: Color(0x66635BFF),
          radius: 12,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x4CF5F4FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: imagePath == null ? const _CoverPlaceholder() : _CoverPreview(path: imagePath!),
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFECEAFF)),
          ),
          child: const Icon(Icons.image_outlined, size: 20, color: Color(0xFF084DFB)),
        ),
        const SizedBox(height: 10),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Tap to upload',
                style: TextStyle(
                  color: Color(0xFF084DFB),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
              TextSpan(
                text: ' or drag and drop',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        const Text(
          'PNG, JPG or WebP (max 10MB)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _CoverPreview extends StatelessWidget {
  final String path;

  const _CoverPreview({required this.path});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.file(File(path), fit: BoxFit.cover, cacheWidth: 800),
      ),
    );
  }
}

/// Draws a rounded dashed outline around its child.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  static const double _dash = 7;
  static const double _gap = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(1),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _NextStepsBanner extends StatelessWidget {
  const _NextStepsBanner();

  @override
  Widget build(BuildContext context) {
    const TextStyle muted = TextStyle(
      color: Color(0xFF475569),
      fontSize: 11,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      height: 1.5,
    );
    final TextStyle strong = muted.copyWith(color: const Color(0xFF1E293B));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xB2F5F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECEAFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0x19635BFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFF635BFF)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: muted,
                children: [
                  const TextSpan(text: 'Next steps will cover '),
                  TextSpan(text: 'Date & Location', style: strong),
                  const TextSpan(text: ' (Step 2) followed by '),
                  TextSpan(text: 'Tickets & Pricing', style: strong),
                  const TextSpan(text: ' (Step 3) before final publishing.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CancelButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF084DFB),
          side: const BorderSide(color: Color(0xFF084DFB)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NextButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F635BFF),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -1,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF084DFB),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Next',
                style: TextStyle(fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
