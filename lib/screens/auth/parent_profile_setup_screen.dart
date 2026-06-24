import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../widgets/primary_button.dart';

class ParentProfileSetupScreen extends StatefulWidget {
  const ParentProfileSetupScreen({super.key});

  @override
  State<ParentProfileSetupScreen> createState() =>
      _ParentProfileSetupScreenState();
}

class _ParentProfileSetupScreenState extends State<ParentProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  String? _selectedGrade;
  String? _selectedInterest;
  final List<String> _pin = [];

  static const _grades = [
    'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6',
    'Grade 7', 'Grade 8', 'Grade 9', '1st year', '2nd year', '3rd year', '4th year',
  ];

  static const _interests = [
    'Mathematics', 'Science', 'English', 'History', 'Art', 'Music',
  ];

  void _onKey(String digit) {
    if (_pin.length < 4) setState(() => _pin.add(digit));
  }

  void _onDelete() {
    if (_pin.isNotEmpty) setState(() => _pin.removeLast());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Title centered
              Center(
                child: Text(
                  'Child Profile Setup',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Please complete your first child's profile.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Full Name
              _FieldLabel('Full Name'),
              const SizedBox(height: 8),
              _RoundedField(
                child: TextField(
                  controller: _nameCtrl,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Enter ful name',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 14, color: AppColors.textHint),
                    prefixIcon: const Icon(Icons.person_outline,
                        color: AppColors.textHint, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grade
              _FieldLabel('Grade'),
              const SizedBox(height: 8),
              _DropdownField(
                hint: 'Select grade',
                icon: Icons.bookmark_border,
                value: _selectedGrade,
                items: _grades,
                onChanged: (v) => setState(() => _selectedGrade = v),
              ),
              const SizedBox(height: 16),

              // Interest
              _FieldLabel('What do your child want to get better at?'),
              const SizedBox(height: 8),
              _DropdownField(
                hint: 'Select interest',
                icon: Icons.lightbulb_outline,
                value: _selectedInterest,
                items: _interests,
                onChanged: (v) => setState(() => _selectedInterest = v),
              ),
              const SizedBox(height: 20),

              // Access Code
              _FieldLabel('Access Code'),
              const SizedBox(height: 4),
              Text(
                'Please add 4 digit access code for your child',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              // PIN dots row
              Row(
                children: List.generate(4, (i) {
                  final filled = i < _pin.length;
                  final isActive = i == _pin.length;
                  return GestureDetector(
                    onTap: () {
                      // open number pad via focus
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 14),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.cardBorder,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: filled
                            ? Text(
                                _pin[i],
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Compact number keypad
              _Keypad(onKey: _onKey, onDelete: _onDelete),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Submit',
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/child-grades'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final Widget child;
  const _RoundedField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, color: AppColors.textHint, size: 18),
              const SizedBox(width: 10),
              Text(
                hint,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textHint),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textSecondary),
          isExpanded: true,
          style: GoogleFonts.poppins(
              fontSize: 14, color: AppColors.textPrimary),
          items: items
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onKey;
  final VoidCallback onDelete;
  const _Keypad({required this.onKey, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Column(
      children: rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: row.map((k) {
            if (k.isEmpty) return const SizedBox(width: 74, height: 52);
            return GestureDetector(
              onTap: () => k == 'del' ? onDelete() : onKey(k),
              child: SizedBox(
                width: 74,
                height: 52,
                child: Center(
                  child: k == 'del'
                      ? const Icon(Icons.backspace_outlined,
                          size: 22, color: AppColors.textPrimary)
                      : Text(
                          k,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
