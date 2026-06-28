import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../theme/spacing.dart';
import '../../widgets/primary_button.dart';

class ChildGradesScreen extends StatefulWidget {
  const ChildGradesScreen({super.key});

  @override
  State<ChildGradesScreen> createState() => _ChildGradesScreenState();
}

class _ChildGradesScreenState extends State<ChildGradesScreen> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(context.l10n.childGrades_appBarTitle, style: AppTextStyles.font(context, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(context.l10n.childGrades_title, style: AppTextStyles.font(context, fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (_, i) {
                    final grade = i + 1;
                    final active = _selected == grade;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = grade),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: active
                                ? AppColors.primary
                                : AppColors.cardBorder,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          context.l10n.childGrades_gradeLabel(grade),
                          style: AppTextStyles.font(context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: active ? AppColors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Opacity(
                opacity: _selected != null ? 1.0 : 0.4,
                child: PrimaryButton(
                  label: context.l10n.childGrades_button_done,
                  onTap: () {
                    if (_selected != null) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
