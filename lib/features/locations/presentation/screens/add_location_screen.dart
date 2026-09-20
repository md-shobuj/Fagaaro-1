import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/utils/app_snackbar.dart';
import '../bloc/locations_bloc.dart';
import '../bloc/locations_event.dart';
import '../bloc/locations_state.dart';

class AddLocationScreen extends StatelessWidget {
  const AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationsBloc>(
      create: (context) => sl<LocationsBloc>(),
      child: const AddLocationForm(),
    );
  }
}

class AddLocationForm extends StatefulWidget {
  const AddLocationForm({super.key});

  @override
  State<AddLocationForm> createState() => _AddLocationFormState();
}

class _AddLocationFormState extends State<AddLocationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  
  double _currentRadius = 150.0;
  bool _isActive = true;
  bool _isLocating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final request = await Geolocator.requestPermission();
        if (request == LocationPermission.denied || request == LocationPermission.deniedForever) {
          if (mounted) {
            AppSnackbar.showError(context, 'Location permission denied');
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
      });
      if (mounted) {
        AppSnackbar.showSuccess(context, 'Location fetched successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to get location: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLocating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;

    final scaffoldBg = AppColors.outerCard(isDark);
    final titleColor = AppColors.title(isDark);
    final accentText = AppColors.accent(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 58,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 9, bottom: 9),
          child: Container(
            decoration: ShapeDecoration(
              color: isDark ? const Color(0xFF131A24) : Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.chevron_left_rounded,
                color: isDark ? Colors.white : const Color(0xFF131A24),
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'New location',
          style: TextStyle(
            color: titleColor,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.36,
          ),
        ),
      ),
      body: BlocListener<LocationsBloc, LocationsState>(
        listener: (context, state) {
          if (state is LocationsActionSuccess) {
            Navigator.of(context).pop(true);
          } else if (state is LocationsError) {
            AppSnackbar.showError(context, state.message);
          }
        },
        child: BlocBuilder<LocationsBloc, LocationsState>(
          builder: (context, state) {
            final isLoading = state is LocationsLoading;

            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXL,
                  vertical: AppDimensions.paddingL,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 600.0 : double.infinity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Map illustration
                        _buildMapIllustration(isDark),
                        const SizedBox(height: 12),

                        // Current location button
                        InkWell(
                          onTap: _isLocating ? null : _getCurrentLocation,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: accentText,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isLocating
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(accentText),
                                        ),
                                      )
                                    : Icon(
                                        Icons.my_location_rounded,
                                        color: accentText,
                                        size: 17,
                                      ),
                                const SizedBox(width: 8),
                                Text(
                                  'Use my current location',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: accentText,
                                    fontSize: 13.50,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Location Name input
                        _buildInputField(
                          label: 'Location name',
                          controller: _nameController,
                          hintText: 'e.g. Downtown Branch',
                          isDark: isDark,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter location name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Latitude and Longitude Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Latitude',
                                controller: _latController,
                                hintText: 'e.g. 25.2048',
                                isDark: isDark,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  final lat = double.tryParse(value);
                                  if (lat == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                label: 'Longitude',
                                controller: _lngController,
                                hintText: 'e.g. 55.2708',
                                isDark: isDark,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  final lng = double.tryParse(value);
                                  if (lng == null) {
                                    return 'Invalid number';
                                  }
                                  if (lng < -180 || lng > 180) {
                                    return 'Must be -180 to 180';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Geofence Radius Slider
                        _buildRadiusSlider(context, isDark),
                        const SizedBox(height: 18),

                        // Active Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active',
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 14.50,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Workers can check in here',
                                  style: TextStyle(
                                    color: AppColors.subtitle(isDark),
                                    fontSize: 12.50,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isActive,
                              activeThumbColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Save location button
                        InkWell(
                          onTap: isLoading ? null : _submitForm,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: ShapeDecoration(
                              color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    )
                                  : const Text(
                                      'Save location',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapIllustration(bool isDark) {
    final gridColor = isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF);
    final circleBg = isDark ? const Color(0xFF0F3E3A).withOpacity(0.5) : const Color(0xFFD6F3EF).withOpacity(0.5);
    final circleBorderColor = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);
    final markerColor = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);

    return Container(
      width: double.infinity,
      height: 164,
      decoration: ShapeDecoration(
        color: isDark ? const Color(0xFF131A24) : Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final centerX = constraints.maxWidth / 2;
          final centerY = constraints.maxHeight / 2;

          return Stack(
            children: [
              // Horizontal line
              Positioned(
                left: 0,
                top: centerY - 0.5,
                right: 0,
                child: Container(
                  height: 1,
                  color: gridColor,
                ),
              ),
              // Vertical line
              Positioned(
                left: centerX - 0.5,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 1,
                  color: gridColor,
                ),
              ),
              // Geofence Circle
              Positioned(
                left: centerX - 48,
                top: centerY - 48,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: ShapeDecoration(
                    color: circleBg,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: circleBorderColor,
                      ),
                      borderRadius: BorderRadius.circular(48),
                    ),
                  ),
                ),
              ),
              // Marker
              Positioned(
                left: centerX - 12,
                top: centerY - 32,
                child: Icon(
                  Icons.location_on_rounded,
                  color: markerColor,
                  size: 24,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 3),
                      blurRadius: 4,
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF5C6675);
    final fieldBg = isDark ? const Color(0xFF131A24) : Colors.white;
    final fieldBorder = isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF);
    final textColor = isDark ? Colors.white : const Color(0xFF131A24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12.50,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          decoration: ShapeDecoration(
            color: fieldBg,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: fieldBorder,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF6B7480) : const Color(0xFF8A94A3),
                fontSize: 15,
                fontFamily: 'Inter',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildRadiusSlider(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Geofence radius',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF5C6675),
                fontSize: 12.50,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_currentRadius.toInt()} m',
              style: TextStyle(
                color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
            inactiveTrackColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F4F7),
            thumbColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
            overlayColor: (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488)).withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10.0,
              elevation: 4,
            ),
          ),
          child: Slider(
            value: _currentRadius,
            min: 50.0,
            max: 1000.0,
            divisions: 19,
            onChanged: (value) {
              setState(() {
                _currentRadius = value;
              });
            },
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<LocationsBloc>().add(
            AddLocationEvent(
              name: _nameController.text.trim(),
              latitude: double.parse(_latController.text.trim()),
              longitude: double.parse(_lngController.text.trim()),
              radius: _currentRadius,
              isActive: _isActive,
            ),
          );
    }
  }
}
