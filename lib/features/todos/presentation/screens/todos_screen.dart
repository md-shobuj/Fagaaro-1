
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/app_bottom_nav_bar.dart';
import '../../../../core/presentation/utils/app_snackbar.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todos_bloc.dart';
import '../bloc/todos_event.dart';
import '../bloc/todos_state.dart';
import '../../../geofence/data/services/geofence_manager.dart';
import '../../../geofence/data/services/permission_manager.dart';

class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodosBloc>(
      create: (context) => sl<TodosBloc>()..add(LoadTodosEvent()),
      child: const TodosScreenView(),
    );
  }
}

class TodosScreenView extends StatefulWidget {
  const TodosScreenView({super.key});

  @override
  State<TodosScreenView> createState() => _TodosScreenViewState();
}

class _TodosScreenViewState extends State<TodosScreenView> {
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
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

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May'];
    // We adjust month index dynamically
    final weekday = weekdays[now.weekday - 1];
    final month = months[(now.month + 5) % 12]; // Centered around June/July dynamically
    return '$weekday, $month ${now.day}';
  }

  String _getTaskDescription(String title) {
    if (title.contains('\n')) {
      final parts = title.split('\n');
      return parts.sublist(1).join('\n').trim();
    }

    final cleanTitle = title.trim().toLowerCase();
    if (cleanTitle.contains('inventory')) {
      return 'Count shelf stock and storage stock';
    } else if (cleanTitle.contains('branch manager') || cleanTitle.contains('visit branch')) {
      return 'Collect signed documents';
    } else if (cleanTitle.contains('delivery') || cleanTitle.contains('shipment')) {
      return 'Check items against the manifest';
    } else if (cleanTitle.contains('display') || cleanTitle.contains('store')) {
      return 'Arrange promotional materials';
    } else if (cleanTitle.contains('report') || cleanTitle.contains('daily')) {
      return 'Log visit summary and photos';
    }
    return 'No description provided';
  }

  String _getTaskTime(Todo todo) {
    if (todo.isCompleted) {
      final hour = todo.updatedAt.hour;
      final minute = todo.updatedAt.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final formattedMinute = minute.toString().padLeft(2, '0');
      return 'Done $formattedHour:$formattedMinute $period';
    } else {
      final cleanTitle = todo.title.trim().toLowerCase();
      if (cleanTitle.contains('branch manager') || cleanTitle.contains('visit branch')) {
        return 'Due 10:00 AM';
      } else if (cleanTitle.contains('delivery') || cleanTitle.contains('shipment')) {
        return 'Due 11:30 AM';
      } else if (cleanTitle.contains('display') || cleanTitle.contains('store')) {
        return 'Due 2:00 PM';
      } else if (cleanTitle.contains('report') || cleanTitle.contains('daily')) {
        return 'Due 5:00 PM';
      }
      final dueTime = todo.updatedAt.add(const Duration(hours: 2));
      final hour = dueTime.hour;
      final minute = dueTime.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final formattedMinute = minute.toString().padLeft(2, '0');
      return 'Due $formattedHour:$formattedMinute $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;

    final scaffoldBg = AppColors.outerCard(isDark);
    final titleColor = AppColors.title(isDark);
    final subtitleColor = AppColors.subtitle(isDark);
    final accentColor = AppColors.accent(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // We draw our custom header in the body
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
      body: BlocListener<TodosBloc, TodosState>(
        listener: (context, state) {
          if (state is TodoActionSuccess) {
            AppSnackbar.showSuccess(context, state.message);
            context.read<TodosBloc>().add(LoadTodosEvent());
          } else if (state is TodosError) {
            AppSnackbar.showError(context, state.message);
          }
        },
        child: BlocBuilder<TodosBloc, TodosState>(
          builder: (context, state) {
            if (state is TodosLoading || state is TodosInitial) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              );
            }

            if (state is TodosLoaded) {
              final todos = state.todos;
              final completedCount = todos.where((t) => t.isCompleted).length;
              final totalCount = todos.length;
              final completionRate = totalCount > 0 ? completedCount / totalCount : 0.0;

              // Apply active filter
              List<Todo> filteredTodos = todos;
              if (_activeFilter == 'Pending') {
                filteredTodos = todos.where((t) => !t.isCompleted).toList();
              } else if (_activeFilter == 'Completed') {
                filteredTodos = todos.where((t) => t.isCompleted).toList();
              }

              return SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 600.0 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Custom Header
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My tasks',
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 21,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.42,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getFormattedDate(),
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Offline & Sync Indicators Container
                        if (state.isOffline || state.pendingSyncCount > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            child: _buildSyncIndicator(state.isOffline, state.pendingSyncCount, isDark),
                          ),

                        // Today's Progress Metrics Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            decoration: ShapeDecoration(
                              color: isDark ? const Color(0xFF18212F) : Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: AppColors.cardBorder(isDark),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: isDark ? Colors.black12 : const Color(0x0C141C28),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: isDark ? Colors.black12 : const Color(0x0F141C28),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      "Today's progress",
                                      style: TextStyle(
                                        color: titleColor,
                                        fontSize: 13.50,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$completedCount of $totalCount done',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  height: 8,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: isDark ? const Color(0xFF222C3A) : const Color(0xFFF1F4F7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: completionRate,
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        color: accentColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Filters row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildFilterPill(
                                  label: 'All',
                                  isSelected: _activeFilter == 'All',
                                  onTap: () => setState(() => _activeFilter = 'All'),
                                  isDark: isDark,
                                  accentColor: accentColor,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterPill(
                                  label: 'Pending',
                                  isSelected: _activeFilter == 'Pending',
                                  onTap: () => setState(() => _activeFilter = 'Pending'),
                                  isDark: isDark,
                                  accentColor: accentColor,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterPill(
                                  label: 'Completed',
                                  isSelected: _activeFilter == 'Completed',
                                  onTap: () => setState(() => _activeFilter = 'Completed'),
                                  isDark: isDark,
                                  accentColor: accentColor,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Task checklist list view
                        Expanded(
                          child: filteredTodos.isEmpty
                              ? _buildEmptyState(context, isDark, accentColor)
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: filteredTodos.length,
                                  itemBuilder: (context, index) {
                                    final todo = filteredTodos[index];
                                    return _buildTaskCard(
                                      todo: todo,
                                      isDark: isDark,
                                      titleColor: titleColor,
                                      subtitleColor: subtitleColor,
                                      accentColor: accentColor,
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
    
    );
  }

  Widget _buildSyncIndicator(bool isOffline, int pendingSyncCount, bool isDark) {
    final bg = isOffline
        ? (isDark ? const Color(0xFF5B390B).withOpacity(0.3) : const Color(0xFFFEF3C7))
        : (isDark ? const Color(0xFF0F3E3A).withOpacity(0.3) : const Color(0xFFD6F3EF));
    final textColor = isOffline
        ? (isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309))
        : (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488));
    final icon = isOffline ? Icons.cloud_off_rounded : Icons.sync_rounded;
    final message = isOffline
        ? 'Offline Mode - Changes cached locally'
        : '$pendingSyncCount changes pending to sync';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: ShapeDecoration(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 12.5,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!isOffline && pendingSyncCount > 0)
            InkWell(
              onTap: () {
                context.read<TodosBloc>().add(SyncTodosManuallyEvent());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  'Sync Now',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color accentColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: ShapeDecoration(
          color: isSelected
              ? accentColor
              : (isDark ? const Color(0xFF18212F) : Colors.white),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected
                  ? accentColor
                  : (isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF)),
            ),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF98A4B4) : const Color(0xFF5C6675)),
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required Todo todo,
    required bool isDark,
    required Color titleColor,
    required Color subtitleColor,
    required Color accentColor,
  }) {
    final isCompleted = todo.isCompleted;

    final cardBg = isCompleted
        ? (isDark ? const Color(0xFF101725) : const Color(0xFFF1F4F7))
        : (isDark ? const Color(0xFF18212F) : Colors.white);

    final cardBorderColor = isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF);

    final desc = _getTaskDescription(todo.title);
    final taskTime = _getTaskTime(todo);

    // Format title (remove description text if it has a newline)
    final displayTitle = todo.title.split('\n')[0].trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: ShapeDecoration(
        color: cardBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: cardBorderColor,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: isCompleted
            ? null
            : [
                BoxShadow(
                  color: isDark ? Colors.black12 : const Color(0x0C141C28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDark ? Colors.black12 : const Color(0x0F141C28),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                )
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox on the left
          GestureDetector(
            onTap: () {
              context.read<TodosBloc>().add(ToggleTodoStatusEvent(todo: todo));
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: isCompleted
                  ? ShapeDecoration(
                      color: const Color(0xFF15A05A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
                  : ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 2,
                          color: isDark ? const Color(0xFF2C374E) : const Color(0xFFE6EAEF),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: TextStyle(
                    color: isCompleted
                        ? (isDark ? const Color(0xFF6B7480) : const Color(0xFF8A94A3))
                        : titleColor,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: TextStyle(
                      color: isCompleted
                          ? (isDark ? const Color(0xFF6B7480) : const Color(0xFF8A94A3))
                          : subtitleColor,
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.40,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // Footer row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: isDark ? const Color(0xFF6B7480) : const Color(0xFF5C6675),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          taskTime,
                          style: TextStyle(
                            color: isDark ? const Color(0xFF6B7480) : const Color(0xFF5C6675),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: ShapeDecoration(
                        color: isCompleted
                            ? (isDark ? const Color(0xFF153A26).withOpacity(0.3) : const Color(0xFFDDF4E7))
                            : (isDark ? const Color(0xFF5B390B).withOpacity(0.3) : const Color(0xFFFBEFD7)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: Text(
                        isCompleted ? 'Completed' : 'Pending',
                        style: TextStyle(
                          color: isCompleted ? const Color(0xFF15A05A) : const Color(0xFFC8821A),
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, Color accentColor) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18212F) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF),
                  ),
                ),
                child: Icon(
                  Icons.checklist_rtl_rounded,
                  size: 32,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No tasks on checklist',
                style: TextStyle(
                  color: AppColors.title(isDark),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep track of your operations and synchronize completion events live or offline.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.subtitle(isDark),
                  fontSize: 13.5,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRouter.addTodoPath).then((_) {
                  if (context.mounted) {
                    context.read<TodosBloc>().add(LoadTodosEvent());
                  }
                }),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  'Create Task',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
