import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/organizer_profile_form.dart';

/// Screen allowing attendees to build and complete their profile during onboarding.
class BuildProfileScreen extends StatefulWidget {
  const BuildProfileScreen({super.key});

  @override
  State<BuildProfileScreen> createState() => _BuildProfileScreenState();
}

class _BuildProfileScreenState extends State<BuildProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _dobController;
  late final TextEditingController _ageController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;

  static const int _maxUploadBytes = 5 * 1024 * 1024;
  final ImagePicker _imagePicker = ImagePicker();

  File? _avatarImage;
  String _selectedCountry = 'United States';
  String? _nidFileName;
  bool _isLoading = false;
  DateTime? _selectedDate = DateTime(1994, 8, 16);

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: 'Sarah Jenkins');
    _dobController = TextEditingController(text: '08/16/1994');
    _ageController = TextEditingController(text: '30');
    _phoneController = TextEditingController(text: '+1 (555) 382-9014');
    _emailController = TextEditingController(text: 'sarah.jenkins@example.com');
    _cityController = TextEditingController(text: 'San Francisco');
    _addressController = TextEditingController(text: '742 Montgomery St, Suite 400');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(now.year - 25);
    final firstDate = DateTime(1900);
    final lastDate = now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF084DFB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        final month = pickedDate.month.toString().padLeft(2, '0');
        final day = pickedDate.day.toString().padLeft(2, '0');
        _dobController.text = '$month/$day/${pickedDate.year}';

        // Compute age
        int age = now.year - pickedDate.year;
        if (now.month < pickedDate.month ||
            (now.month == pickedDate.month && now.day < pickedDate.day)) {
          age--;
        }
        _ageController.text = age.toString();
      });
    }
  }

  void _onPickAvatar() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF084DFB)),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAvatarFrom(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF084DFB)),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAvatarFrom(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAvatarFrom(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      final int size = await picked.length();
      if (!mounted) return;
      if (size > _maxUploadBytes) {
        _showError('Photo must be 5MB or smaller.');
        return;
      }
      setState(() => _avatarImage = File(picked.path));
    } on PlatformException catch (e) {
      debugPrint('Avatar pick failed (${source.name}): ${e.code} ${e.message}');
      if (!mounted) return;
      _showError(
        source == ImageSource.camera
            ? 'Could not open the camera. Please check camera permission in Settings.'
            : 'Could not open the gallery. Please check photo permission in Settings.',
      );
    }
  }

  Future<void> _onPickNidFile() async {
    try {
      final PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (file == null || !mounted) return;

      final int size = file.lengthSync() ?? await file.length() ?? 0;
      if (!mounted) return;
      if (size > _maxUploadBytes) {
        _showError('NID file must be 5MB or smaller.');
        return;
      }
      setState(() => _nidFileName = file.name);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NID document attached successfully!'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('NID pick failed: ${e.code} ${e.message}');
      if (!mounted) return;
      _showError('Could not open the file picker. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _onSaveProfile() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification submitted successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        context.go(AppRouter.verificationSubmittedPath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF084DFB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.selectRolePath);
            }
          },
        ),
        title: const Text(
          'Build your profile',
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Organizer Badge
                    const OrganizerBadgeWidget(),
                    const SizedBox(height: 12),

                    // Title Header
                    const Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.33,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tell us a little more about yourself before creating events.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.38,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Avatar Photo Picker
                    Center(
                      child: ProfileAvatarPickerWidget(
                        imageFile: _avatarImage,
                        onTap: _onPickAvatar,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Personal Information Section
                    const SectionHeaderWidget(title: 'PERSONAL INFORMATION'),
                    const SizedBox(height: 14),

                    // Full Name Input
                    ProfileInputFieldWidget(
                      label: 'Full Name',
                      controller: _fullNameController,
                      prefixIcon: Icons.person_outline_rounded,
                      placeholder: 'Enter your full name',
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth & Age Row
                    DateAndAgeRowWidget(
                      dobController: _dobController,
                      ageController: _ageController,
                      onSelectDob: _pickDateOfBirth,
                    ),
                    const SizedBox(height: 16),

                    // Phone Number Input
                    ProfileInputFieldWidget(
                      label: 'Phone Number',
                      controller: _phoneController,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      placeholder: '+1 (555) 000-0000',
                    ),
                    const SizedBox(height: 16),

                    // Email Address Input with Verified Status & Helper text
                    EmailVerifiedFieldWidget(
                      controller: _emailController,
                      isVerified: true,
                      helperText: 'Primary contact for payouts and attendee communication',
                    ),
                    const SizedBox(height: 24),

                    // Location Section
                    const SectionHeaderWidget(title: 'LOCATION'),
                    const SizedBox(height: 14),

                    // Country & City Row
                    CountryAndCityRowWidget(
                      selectedCountry: _selectedCountry,
                      onCountryChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCountry = value;
                          });
                        }
                      },
                      cityController: _cityController,
                    ),
                    const SizedBox(height: 16),

                    // Full Address Field with Home icon
                    ProfileInputFieldWidget(
                      label: 'Full Address',
                      controller: _addressController,
                      prefixIcon: Icons.home_outlined,
                      placeholder: '742 Montgomery St, Suite 400',
                    ),
                    const SizedBox(height: 28),

                    // National ID (NID) Upload Section
                    NidUploadWidget(
                      selectedFileName: _nidFileName,
                      onTapUpload: _onPickNidFile,
                    ),
                    const SizedBox(height: 36),

                    // Primary Submit Verification Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onSaveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Submit Verification',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
