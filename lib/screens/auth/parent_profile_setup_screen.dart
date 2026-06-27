import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class ParentProfileSetupScreen extends StatefulWidget {
  const ParentProfileSetupScreen({super.key});

  @override
  State<ParentProfileSetupScreen> createState() =>
      _ParentProfileSetupScreenState();
}

class _ParentProfileSetupScreenState extends State<ParentProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _pinFocus = FocusNode();

  String? _selectedGrade;
  String? _selectedInterest;

  static const _grades = [
    'Grade 7', 'Grade 8', 'Grade 9',
    '1st year', '2nd year', '3rd year', '4th year',
  ];

  static const _interests = [
    'Fraction', 'Multiplication', 'Algebra', 'Equations',
  ];

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _usernameCtrl.text.trim().isNotEmpty &&
      _selectedGrade != null &&
      _selectedInterest != null &&
      _pinCtrl.text.length == 4;

  void _onSubmit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Add Another Child?',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Would you like to set up a profile for another child?',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/profile-setup-done');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'No',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Reset form for next child
                    _nameCtrl.clear();
                    _usernameCtrl.clear();
                    _pinCtrl.clear();
                    setState(() {
                      _selectedGrade = null;
                      _selectedInterest = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Yes',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
    _usernameCtrl.addListener(() => setState(() {}));
    _pinCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _pinCtrl.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pin = _pinCtrl.text;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.textPrimary, size: 24),
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),

                // Title
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
                Text(
                  "Please complete your first child's profile.",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 28),

                // Full Name
                _FieldLabel('Full Name'),
                const SizedBox(height: 8),
                _RoundedTextField(
                  controller: _nameCtrl,
                  hint: 'Enter full name',
                  prefixIcon: Icons.person_outline,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Username
                _FieldLabel('Username'),
                const SizedBox(height: 8),
                _RoundedTextField(
                  controller: _usernameCtrl,
                  hint: 'Enter username',
                  prefixIcon: Icons.alternate_email,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Grade
                _FieldLabel('Grade'),
                const SizedBox(height: 8),
                _DropdownField(
                  hint: 'Select grade',
                  prefixIcon: Icons.bookmark_border,
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
                  prefixIcon: Icons.lightbulb_outline,
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

                // Hidden PIN input
                Opacity(
                  opacity: 0,
                  child: SizedBox(
                    height: 0,
                    child: OverflowBox(
                      maxHeight: 0,
                      child: TextField(
                        controller: _pinCtrl,
                        focusNode: _pinFocus,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                ),

                // PIN circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < pin.length;
                    final isActive = i == pin.length;
                    return GestureDetector(
                      onTap: () => _pinFocus.requestFocus(),
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
                                  pin[i],
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
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
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _onSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.35),
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(
                            color: AppColors.white, width: 2),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
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

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final VoidCallback? onChanged;

  const _RoundedTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged?.call(),
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.poppins(fontSize: 14, color: AppColors.textHint),
          prefixIcon:
              Icon(prefixIcon, color: AppColors.textHint, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final IconData prefixIcon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.prefixIcon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ...items.map((item) => GestureDetector(
                  onTap: () {
                    onChanged(item);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: value == item
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: value == item
                            ? AppColors.primary
                            : AppColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: value == item
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: value == item
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: AppColors.cardBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(prefixIcon, color: AppColors.textHint, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? hint,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: value != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
