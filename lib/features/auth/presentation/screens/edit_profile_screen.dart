import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_router.dart';

const Color _primaryBlue = Color(0xFF084DFB);
const Color _ink = Color(0xFF0F172A);
const Color _fieldText = Color(0xFF64748B);
const Color _fieldBorder = Color(0xFFD9D9D9);

/// Edit Profile form: avatar picker plus the core contact fields.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;

  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'John smith');
    _dobController = TextEditingController(text: '28/111/1997');
    _countryController = TextEditingController(text: 'United States');
    _phoneController = TextEditingController(text: '+1234567890');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.homePath);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.redAccent : null,
      ),
    );
  }

  /// Lets the user choose between the camera and the photo library.
  Future<void> _pickPhoto() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: _primaryBlue),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: _primaryBlue),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;
    await _pickFrom(source);
  }

  Future<void> _pickFrom(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
      );
      if (file == null || !mounted) return;
      setState(() => _imagePath = file.path);
    } on PlatformException catch (e) {
      debugPrint('Photo pick failed: ${e.code} ${e.message}');
      if (!mounted) return;
      final String target = source == ImageSource.camera ? 'camera' : 'photo library';
      _showMessage('Could not open the $target. Please check app permissions.', error: true);
    }
  }

  void _onSave() {
    _showMessage('Profile updated.');
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(onBack: _onBack),
                  const SizedBox(height: 24),
                  Center(
                    child: _AvatarPicker(
                      imagePath: _imagePath,
                      onTap: _pickPhoto,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Field(label: 'Name', controller: _nameController),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'Date of Birth',
                    controller: _dobController,
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 16),
                  _Field(label: 'Country', controller: _countryController),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'Phone number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 40),
                  _SaveButton(onPressed: _onSave),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_rounded, size: 22, color: _ink),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Edit Profile',
          style: TextStyle(
            color: _primaryBlue,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const _AvatarPicker({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF2F7),
                  shape: BoxShape.circle,
                ),
                child: imagePath == null
                    ? const Icon(Icons.person_rounded, size: 52, color: Color(0xFF94A3B8))
                    : Image.file(File(imagePath!), fit: BoxFit.cover, cacheWidth: 288),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.photo_camera_rounded, size: 15, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              'Tap to change photo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.83,
                letterSpacing: -0.41,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: _fieldText,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            enabledBorder: border(_fieldBorder),
            focusedBorder: border(_primaryBlue),
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10)),
            BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'Save',
            style: TextStyle(fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
