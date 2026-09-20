import 'dart:io';
import 'package:flutter/material.dart';

/// Pill badge indicating "ORGANIZER ONBOARDING" status.
class OrganizerBadgeWidget extends StatelessWidget {
  const OrganizerBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4FF),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          width: 1,
          color: const Color(0x99D9D3FE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF084DFB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'ORGANIZER ONBOARDING',
            style: TextStyle(
              color: Color(0xFF084DFB),
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.5,
              letterSpacing: 0.28,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill badge indicating "ATTENDEE ONBOARDING" status.
class AttendeeBadgeWidget extends StatelessWidget {
  const AttendeeBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4FF),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          width: 1,
          color: const Color(0x99D9D3FE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF084DFB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'ATTENDEE ONBOARDING',
            style: TextStyle(
              color: Color(0xFF084DFB),
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.5,
              letterSpacing: 0.28,
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular photo uploader widget with camera badge button and size guidance.
class ProfileAvatarPickerWidget extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;

  const ProfileAvatarPickerWidget({
    super.key,
    required this.imageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF084DFB);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Avatar Container
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryBlue, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: imageFile != null
                      ? Image.file(
                          imageFile!,
                          width: 128,
                          height: 128,
                          fit: BoxFit.cover,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.black.withValues(alpha: 0.4),
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'UPLOAD\nPHOTO',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.4),
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Camera Action Button Overlay
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF8F5F5), width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'JPG, PNG or WEBP (Max 5MB)',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.33,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

/// Section title widget (e.g. PERSONAL INFORMATION)
class SectionHeaderWidget extends StatelessWidget {
  final String title;

  const SectionHeaderWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          height: 1.33,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Reusable profile input field with label and leading icon.
class ProfileInputFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData prefixIcon;
  final String? placeholder;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const ProfileInputFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.placeholder,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2.0, bottom: 6.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            height: 1.33,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF084DFB),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.redAccent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Email input field paired with green "Verified" badge header.
class EmailVerifiedFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isVerified;
  final String? helperText;
  final String? Function(String?)? validator;

  const EmailVerifiedFieldWidget({
    super.key,
    required this.controller,
    this.isVerified = true,
    this.helperText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 2.0),
              child: Text(
                'Email Address',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
            ),
            if (isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    width: 1,
                    color: const Color(0xCCA7F3D0),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF059669),
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          validator: validator,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            height: 1.33,
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF084DFB),
                width: 1.5,
              ),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              helperText!,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 2-Column layout combining Date of Birth selector and Age display.
class DateAndAgeRowWidget extends StatelessWidget {
  final TextEditingController dobController;
  final TextEditingController ageController;
  final VoidCallback onSelectDob;

  const DateAndAgeRowWidget({
    super.key,
    required this.dobController,
    required this.ageController,
    required this.onSelectDob,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date of Birth Field
        Expanded(
          child: ProfileInputFieldWidget(
            label: 'Date of Birth',
            controller: dobController,
            prefixIcon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: onSelectDob,
            placeholder: 'MM/DD/YYYY',
          ),
        ),
        const SizedBox(width: 12),

        // Age Field (Read only, calculated)
        Expanded(
          child: ProfileInputFieldWidget(
            label: 'Age',
            controller: ageController,
            prefixIcon: Icons.cake_outlined,
            readOnly: true,
            placeholder: 'Age',
          ),
        ),
      ],
    );
  }
}

/// Dropdown widget for selecting country.
class CountrySelectDropdownWidget extends StatelessWidget {
  final String selectedCountry;
  final ValueChanged<String?> onChanged;

  const CountrySelectDropdownWidget({
    super.key,
    required this.selectedCountry,
    required this.onChanged,
  });

  static const List<String> countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'Germany',
    'France',
    'Somalia',
    'Kenya',
    'United Arab Emirates',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2.0, bottom: 6.0),
          child: Text(
            'Country',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: countries.contains(selectedCountry) ? selectedCountry : countries.first,
          onChanged: onChanged,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
          ),
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF084DFB),
                width: 1.5,
              ),
            ),
          ),
          items: countries.map((country) {
            return DropdownMenuItem<String>(
              value: country,
              child: Text(
                country,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// 2-Column row combining Country dropdown and City input field.
class CountryAndCityRowWidget extends StatelessWidget {
  final String selectedCountry;
  final ValueChanged<String?> onCountryChanged;
  final TextEditingController cityController;

  const CountryAndCityRowWidget({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.cityController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CountrySelectDropdownWidget(
            selectedCountry: selectedCountry,
            onChanged: onCountryChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 2.0, bottom: 6.0),
                child: Text(
                  'City',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                  ),
                ),
              ),
              TextFormField(
                controller: cityController,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                ),
                decoration: InputDecoration(
                  hintText: 'San Francisco',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF084DFB),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// National ID (NID) upload card widget with cloud icon and file upload area.
class NidUploadWidget extends StatelessWidget {
  final String? selectedFileName;
  final VoidCallback onTapUpload;

  const NidUploadWidget({
    super.key,
    this.selectedFileName,
    required this.onTapUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'National ID (NID) Upload',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please provide a valid government-issued document to activate your organizer payout account.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.38,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTapUpload,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFF084DFB),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  selectedFileName ?? 'Click to upload or drag NID copy',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'PDF, PNG OR JPG (MAX 5MB)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
