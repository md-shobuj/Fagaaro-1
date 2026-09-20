import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/presentation/utils/app_snackbar.dart';
import '../../../../core/presentation/widgets/app_bottom_nav_bar.dart';
import '../../../../features/todos/presentation/bloc/todos_bloc.dart';
import '../../../../features/todos/presentation/bloc/todos_event.dart';
import '../../../../features/todos/presentation/bloc/todos_state.dart';
import '../../../../features/todos/domain/entities/todo.dart';

class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodosBloc>(
      create: (context) => sl<TodosBloc>()..add(LoadTodosEvent()),
      child: const SyncScreenView(),
    );
  }
}

class SyncScreenView extends StatefulWidget {
  const SyncScreenView({super.key});

  @override
  State<SyncScreenView> createState() => _SyncScreenViewState();
}

class _SyncScreenViewState extends State<SyncScreenView> {
  DateTime? _lastSyncedTime;

  String _formatTime(BuildContext context, DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _getLastSyncText(int pendingCount, BuildContext context) {
    if (_lastSyncedTime == null) {
      if (pendingCount == 0) {
        return 'All changes synced to server';
      } else {
        return 'Last synced today, 9:45 AM';
      }
    }
    
    final timeStr = _formatTime(context, _lastSyncedTime!);
    return 'Last synced today, $timeStr';
  }

  IconData _getIconForTodo(String title) {
    final t = title.toLowerCase();
    if (t.contains('inventory') || t.contains('count') || t.contains('stock')) {
      return Icons.inventory_2_outlined;
    } else if (t.contains('manager') || t.contains('visit') || t.contains('branch')) {
      return Icons.description_outlined;
    } else if (t.contains('display') || t.contains('store') || t.contains('shop')) {
      return Icons.storefront_outlined;
    } else if (t.contains('location') || t.contains('map')) {
      return Icons.location_on_outlined;
    }
    return Icons.assignment_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;

    // Theme values matching the specs and screenshots
    final scaffoldBg = isDark ? const Color(0xFF0B0E14) : const Color(0xFFF4F6F8);
    final cardBgColor = isDark ? const Color(0xFF131A24) : Colors.white;
    final borderColor = isDark ? const Color(0xFF222C3A) : const Color(0xFFE6EAEF);
    final titleColor = isDark ? Colors.white : const Color(0xFF131A24);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF5C6675);
    
    // Status banner colors
    final offlineBannerBg = isDark ? const Color(0xFF2C1E12) : const Color(0xFFFBEFD7);
    final offlineBannerText = isDark ? const Color(0xFFE2A03F) : const Color(0xFFC8821A);

    // Sync card left box colors
    final syncIconBoxBg = isDark ? const Color(0xFF142B28) : const Color(0xFFD6F3EF);
    final syncIconColor = isDark ? const Color(0xFF14B8A6) : const Color(0xFF0F9F90);

    // Sync now button colors
    final buttonBg = isDark ? const Color(0xFF14B8A6) : const Color(0xFF0F9F90);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: BlocListener<TodosBloc, TodosState>(
        listener: (context, state) {
          if (state is TodoActionSuccess) {
            setState(() {
              _lastSyncedTime = DateTime.now();
            });
            AppSnackbar.showSuccess(context, state.message);
            context.read<TodosBloc>().add(LoadTodosEvent());
          } else if (state is TodosError) {
            AppSnackbar.showError(context, state.message);
          }
        },
        child: BlocBuilder<TodosBloc, TodosState>(
          builder: (context, state) {
            final isLoading = state is TodosLoading;
            bool isOffline = false;
            int pendingCount = 0;
            List<Todo> pendingTodos = [];

            if (state is TodosLoaded) {
              isOffline = state.isOffline;
              pendingCount = state.pendingSyncCount;
              pendingTodos = state.pendingTodos;
            }

            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 480.0 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header "Sync"
                      Padding(
                        padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 14),
                        child: Text(
                          'Sync',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 28.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Offline Mode Banner
                              if (isOffline) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                                  decoration: ShapeDecoration(
                                    color: offlineBannerBg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wifi_off_rounded,
                                        color: offlineBannerText,
                                        size: 20.sp,
                                      ),
                                      const SizedBox(width: 11),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "You're offline",
                                              style: TextStyle(
                                                color: offlineBannerText,
                                                fontSize: 13.5.sp,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              'Changes are saved on this device',
                                              style: TextStyle(
                                                color: subtitleColor,
                                                fontSize: 12.5.sp,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],

                              // 2. Main Sync Queue Info Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 18),
                                decoration: ShapeDecoration(
                                  color: cardBgColor,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 1, color: borderColor),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: isDark ? Colors.black38 : const Color(0x0C141C28),
                                      blurRadius: 16.r,
                                      offset: const Offset(0, 6),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: isDark ? Colors.black12 : const Color(0x0F141C28),
                                      blurRadius: 2.r,
                                      offset: const Offset(0, 1),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50.r,
                                      height: 50.r,
                                      decoration: ShapeDecoration(
                                        color: syncIconBoxBg,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.sync_rounded,
                                          color: syncIconColor,
                                          size: 24.sp,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pendingCount == 0
                                                ? 'All changes synced'
                                                : '$pendingCount changes pending',
                                            style: TextStyle(
                                              color: titleColor,
                                              fontSize: 17.sp,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _getLastSyncText(pendingCount, context),
                                            style: TextStyle(
                                              color: subtitleColor,
                                              fontSize: 12.5.sp,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 3. Waiting to upload Section
                              if (pendingCount > 0) ...[
                                Text(
                                  'WAITING TO UPLOAD',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF8A94A3),
                                    fontSize: 12.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.60,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: pendingTodos.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final todo = pendingTodos[index];
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                                      decoration: ShapeDecoration(
                                        color: cardBgColor,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(width: 1, color: borderColor),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color: isDark ? Colors.black26 : const Color(0x0C141C28),
                                            blurRadius: 16.r,
                                            offset: const Offset(0, 6),
                                            spreadRadius: 0,
                                          ),
                                          BoxShadow(
                                            color: isDark ? Colors.black12 : const Color(0x0F141C28),
                                            blurRadius: 2.r,
                                            offset: const Offset(0, 1),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36.r,
                                            height: 36.r,
                                            decoration: ShapeDecoration(
                                              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F4F7),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                _getIconForTodo(todo.title),
                                                color: subtitleColor,
                                                size: 18.sp,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  todo.title,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: titleColor,
                                                    fontSize: 14.sp,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Marked done • ${_formatTime(context, todo.updatedAt)}',
                                                  style: TextStyle(
                                                    color: subtitleColor,
                                                    fontSize: 12.sp,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                            decoration: ShapeDecoration(
                                              color: offlineBannerBg,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                            ),
                                            child: Text(
                                              'Pending',
                                              style: TextStyle(
                                                color: offlineBannerText,
                                                fontSize: 11.sp,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      // 4. Sync Now Button
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonBg,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: buttonBg.withOpacity(0.5),
                              disabledForegroundColor: Colors.white.withOpacity(0.7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            icon: isLoading
                                ? SizedBox(
                                    width: 20.r,
                                    height: 20.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(Icons.sync_rounded, size: 20.sp),
                            label: Text(
                              isLoading ? 'Syncing...' : 'Sync now',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: (isOffline || isLoading)
                                ? null
                                : () {
                                    context.read<TodosBloc>().add(SyncTodosManuallyEvent());
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }
}
