import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/app_bottom_nav_bar.dart';
import '../../../../core/presentation/utils/app_snackbar.dart';
import '../../domain/entities/geofence_location.dart';
import '../bloc/locations_bloc.dart';
import '../bloc/locations_event.dart';
import '../bloc/locations_state.dart';
import '../../../geofence/data/services/geofence_manager.dart';
import '../../../geofence/data/services/permission_manager.dart';

class LocationListScreen extends StatelessWidget {
  const LocationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationsBloc>(
      create: (context) => sl<LocationsBloc>()..add(LoadLocationsEvent()),
      child: const LocationListScreenView(),
    );
  }
}

class LocationListScreenView extends StatefulWidget {
  const LocationListScreenView({super.key});

  @override
  State<LocationListScreenView> createState() => _LocationListScreenViewState();
}

class _LocationListScreenViewState extends State<LocationListScreenView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _initializeGeofencing();
  }

  Future<void> _initializeGeofencing() async {
    final permissionManager = sl<PermissionManager>();
    final hasPermission = await permissionManager.checkLocationPermissions();
    if (!hasPermission) {
      final granted = await permissionManager.requestLocationPermissions();
      if (granted) {
        sl<GeofenceManager>().startMonitoring();
      }
    } else {
      sl<GeofenceManager>().startMonitoring();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;

    final scaffoldBg = AppColors.outerCard(isDark);
    final titleColor = AppColors.title(isDark);
    final subtitleColor = AppColors.subtitle(isDark);
    final accentText = AppColors.accent(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
      body: SafeArea(
        child: BlocListener<LocationsBloc, LocationsState>(
          listener: (context, state) {
            if (state is LocationsActionSuccess) {
              AppSnackbar.showSuccess(context, state.message);
              context.read<LocationsBloc>().add(LoadLocationsEvent());
            } else if (state is LocationsError) {
              AppSnackbar.showError(context, state.message);
            }
          },
          child: BlocBuilder<LocationsBloc, LocationsState>(
            builder: (context, state) {
              if (state is LocationsLoading || state is LocationsInitial) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              if (state is LocationsLoaded) {
                final locations = state.locations;

                // Filter locations based on search query
                final filtered = locations.where((loc) {
                  final query = _searchQuery.toLowerCase();
                  return loc.name.toLowerCase().contains(query) ||
                      '${loc.latitude}, ${loc.longitude}'.contains(query);
                }).toList();

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 600.0 : double.infinity,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingXL,
                        vertical: AppDimensions.paddingXXL,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row with Title and Add Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Locations',
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 21,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.42,
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => context.push(AppRouter.addLocationPath).then((_) {
                                      if (context.mounted) {
                                        context.read<LocationsBloc>().add(LoadLocationsEvent());
                                      }
                                    }),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: ShapeDecoration(
                                        color: accentText,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Search Bar
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: ShapeDecoration(
                              color: isDark ? const Color(0xFF131A24) : Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF),
                                ),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: isDark ? Colors.black26 : const Color(0x0C141C28),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 14.50,
                                fontFamily: 'Inter',
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search locations',
                                hintStyle: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 14.50,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                                icon: Icon(
                                  Icons.search,
                                  color: subtitleColor,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Locations List or Empty State
                          Expanded(
                            child: filtered.isEmpty
                                ? _buildEmptyState(context, locations.isEmpty)
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      return _buildLocationCard(
                                        context,
                                        filtered[index],
                                        isDark,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<LocationsBloc, LocationsState>(
        builder: (context, state) {
          if (state is LocationsLoaded && state.locations.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => context.push(AppRouter.addLocationPath).then((_) {
                if (context.mounted) {
                  context.read<LocationsBloc>().add(LoadLocationsEvent());
                }
              }),
              backgroundColor: AppColors.accent(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isOriginalListEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding3XL + 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppDimensions.sizeLogo + 20,
              height: AppDimensions.sizeLogo + 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppDimensions.space3XL),
            Text(
              isOriginalListEmpty ? 'No locations monitored yet' : 'No matching locations',
              style: AppTextStyles.titleSmall,
            ),
            SizedBox(height: AppDimensions.spaceM),
            Text(
              isOriginalListEmpty
                  ? 'Add coordinates and radius to set up geofencing boundaries and alerts.'
                  : 'Try typing a different name or search term.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, GeofenceLocation location, bool isDark) {
    final cardBgColor = isDark ? const Color(0xFF131A24) : Colors.white;
    final borderColor = isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF);
    final titleColor = isDark ? Colors.white : const Color(0xFF131A24);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF5C6675);
    final accentBg = isDark ? const Color(0xFF0F3E3A) : const Color(0xFFD6F3EF);
    final accentText = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);

    final activeBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFDDF4E7);
    final activeText = isDark ? const Color(0xFF34D399) : const Color(0xFF15A05A);
    final inactiveBg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F4F7);
    final inactiveText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF5C6675);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ShapeDecoration(
        color: cardBgColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: [
          BoxShadow(
            color: isDark ? Colors.black38 : const Color(0x0C141C28),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark ? Colors.black26 : const Color(0x0F141C28),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          )
        ],
      ),
      child: InkWell(
        onTap: () => _showLocationOptionsBottomSheet(context, location),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: ShapeDecoration(
                  color: accentBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.location_on,
                    color: accentText,
                    size: 21,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15.50,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          color: subtitleColor,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 12.50,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: ShapeDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F4F7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          ),
                          child: Text(
                            '${location.radius.toInt()} m radius',
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 11.50,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: ShapeDecoration(
                            color: location.isActive ? activeBg : inactiveBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          ),
                          child: Text(
                            location.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: location.isActive ? activeText : inactiveText,
                              fontSize: 11.50,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 30,
                padding: const EdgeInsets.only(top: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? const Color(0xFF6B7480) : const Color(0xFF8A94A3),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationOptionsBottomSheet(BuildContext context, GeofenceLocation location) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A24) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF131A24);
    final iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF5C6675);

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  location.name,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: iconColor),
                title: Text(
                  'Edit Location',
                  style: TextStyle(color: titleColor, fontFamily: 'Inter'),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  context.push(AppRouter.editLocationPath, extra: location).then((_) {
                    if (context.mounted) {
                      context.read<LocationsBloc>().add(LoadLocationsEvent());
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text(
                  'Delete Location',
                  style: TextStyle(color: Colors.redAccent, fontFamily: 'Inter'),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showDeleteConfirmation(context, location);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, GeofenceLocation location) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete Location?',
          style: AppTextStyles.titleSmall,
        ),
        content: Text('Are you sure you want to delete "${location.name}"? This will stop geofencing alerts for this area.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusCard)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<LocationsBloc>().add(DeleteLocationEvent(id: location.id));
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
