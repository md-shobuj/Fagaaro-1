import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/utils/app_snackbar.dart';
import '../bloc/todos_bloc.dart';
import '../bloc/todos_event.dart';
import '../bloc/todos_state.dart';

class AddTodoScreen extends StatelessWidget {
  const AddTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodosBloc>(
      create: (context) => sl<TodosBloc>(),
      child: const AddTodoForm(),
    );
  }
}

class AddTodoForm extends StatefulWidget {
  const AddTodoForm({super.key});

  @override
  State<AddTodoForm> createState() => _AddTodoFormState();
}

class _AddTodoFormState extends State<AddTodoForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > AppDimensions.tabletBreakpoint;

    final scaffoldBg = AppColors.outerCard(isDark);
    final titleColor = AppColors.title(isDark);

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
          'Create Task',
          style: TextStyle(
            color: titleColor,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.36,
          ),
        ),
      ),
      body: BlocListener<TodosBloc, TodosState>(
        listener: (context, state) {
          if (state is TodoActionSuccess) {
            Navigator.of(context).pop(true);
          } else if (state is TodosError) {
            AppSnackbar.showError(context, state.message);
          }
        },
        child: BlocBuilder<TodosBloc, TodosState>(
          builder: (context, state) {
            final isLoading = state is TodosLoading;

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
                        Text(
                          'Create a new operation tracking checklist task. You can input multiple lines to add a description (e.g. title on the first line, description on the second line).',
                          style: TextStyle(
                            color: AppColors.subtitle(isDark),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Task Title input
                        _buildInputField(
                          label: 'Task Title',
                          controller: _titleController,
                          hintText: 'e.g. Inspect boundary flags\nCheck all corners for damage',
                          isDark: isDark,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter task title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Create Task button
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
                                      'Create Task',
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    int? maxLines,
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
            maxLines: maxLines ?? 1,
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<TodosBloc>().add(
            AddTodoEvent(
              title: _titleController.text.trim(),
            ),
          );
    }
  }
}
