import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../l10n/l10n_extension.dart';
import '../../models/student_profile.dart';
import '../../providers/auth_state.dart';
import '../../services/api_http_client.dart';
import '../../services/supabase_service.dart';
import '../../theme/colors.dart';
import '../../theme/responsive.dart';
import '../../theme/text_styles.dart';
import 'points_card.dart';

Future<void> _confirmLogout(BuildContext context) async {
  // End the Supabase session if one exists (guarded so tests without a live
  // session don't attempt a real network sign-out), clear the locally
  // selected student, then return to the root route.
  final auth = context.read<AuthState>();
  final messenger = Navigator.of(context);
  try {
    if (Supabase.instance.client.auth.currentSession != null) {
      await SupabaseService().signOut();
    }
  } catch (_) {
    // Ignore sign-out transport errors; still clear local state below.
  }
  await auth.setSelectedStudentId(null);
  messenger.pushNamedAndRemoveUntil('/', (r) => false);
}

void _showLogoutDialog(BuildContext context) {
  final l10n = context.l10n;
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.logOut_title,
              style: AppTextStyles.font(context,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.logOut_body,
              style: AppTextStyles.font(context,
                fontSize: 16,
                color: const Color(0xFF2E2E2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          l10n.logOut_button_no,
                          style: AppTextStyles.font(context,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(dialogContext);
                      await _confirmLogout(context);
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          l10n.logOut_button_yes,
                          style: AppTextStyles.font(context,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class ProfileScreen extends StatefulWidget {
  /// Injectable for tests; production uses [ApiHttpClient].
  final ProfileApi? api;

  /// Test-only override for the selected student id. When null, the id is
  /// read from [AuthState].
  final String? selectedStudentIdOverride;

  const ProfileScreen({super.key, this.api, this.selectedStudentIdOverride});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileApi _api;
  StudentProfile? _profile;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? ApiHttpClient();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = widget.selectedStudentIdOverride ??
        context.read<AuthState>().selectedStudentId;
    if (id == null) return;
    try {
      final profile = await _api.fetchStudentProfile(id);
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      // Keep fallback mock values on any failure.
    }
  }

  @override
  Widget build(BuildContext context) {
    final double avatarSize = context.rs(100);
    final double avatarOverlap = context.rs(50);
    // Reserve space for the fixed name that now sits below the avatar
    // (8px gap + ~40px line height for the 28px font).
    final double nameBlockHeight = context.rs(48);

    final name = _profile?.name ?? 'John';
    final avatarUrl = _profile?.avatarUrl;

    return ColoredBox(
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Text(
                context.l10n.profile_title,
                style: AppTextStyles.font(
                  context,
                  fontSize: context.rs(22),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: context.rs(20)),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.isTablet ? 640 : double.infinity,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Cream body — only the cards inside this scroll.
                    Positioned.fill(
                      top: avatarOverlap,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                          // Top padding clears the pinned avatar + fixed name.
                          padding: EdgeInsets.fromLTRB(
                            context.rs(20),
                            avatarOverlap + context.rs(8) + nameBlockHeight,
                            context.rs(20),
                            context.rs(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProfilePointsCard(
                                points: _profile?.pointsBalance,
                              ),
                              SizedBox(height: context.rs(16)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.rs(20),
                                  vertical: context.rs(16),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    context.rs(16),
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: context.rs(44),
                                      height: context.rs(44),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          context.rs(12),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.workspace_premium_rounded,
                                        color: AppColors.primary,
                                        size: context.rs(24),
                                      ),
                                    ),
                                    SizedBox(width: context.rs(14)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context
                                                .l10n
                                                .profile_label_currentPlan,
                                            style: AppTextStyles.font(
                                              context,
                                              fontSize: context.rs(13),
                                              color: const Color(0xFF888888),
                                            ),
                                          ),
                                          SizedBox(height: context.rs(2)),
                                          Text(
                                            context.l10n.profile_plan_free,
                                            style: AppTextStyles.font(
                                              context,
                                              fontSize: context.rs(16),
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF2E2E2E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/subscription',
                                        arguments: 1,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: context.rs(14),
                                          vertical: context.rs(7),
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            context.rs(20),
                                          ),
                                        ),
                                        child: Text(
                                          context.l10n.profile_button_upgrade,
                                          style: AppTextStyles.font(
                                            context,
                                            fontSize: context.rs(13),
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: context.rs(16)),
                              // Help row — label centered.
                              GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/help'),
                                child: Container(
                                  height: context.rs(60),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.rs(20),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      context.rs(16),
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    context.l10n.profile_button_help,
                                    style: AppTextStyles.font(
                                      context,
                                      fontSize: context.rs(16),
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2E2E2E),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.rs(16)),
                              // Log Out row — label centered.
                              GestureDetector(
                                onTap: () => _showLogoutDialog(context),
                                child: Container(
                                  height: context.rs(60),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.rs(20),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBD7C8),
                                    borderRadius: BorderRadius.circular(
                                      context.rs(16),
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFE62929),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    context.l10n.profile_button_logOut,
                                    style: AppTextStyles.font(
                                      context,
                                      fontSize: context.rs(16),
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFE62929),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Pinned avatar + fixed name (do not scroll).
                    Positioned(
                      top: 0,
                      left: context.rs(20),
                      right: context.rs(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: avatarSize,
                                height: avatarSize,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child:
                                      (avatarUrl != null &&
                                          avatarUrl.isNotEmpty)
                                      ? Image.network(
                                          avatarUrl,
                                          width: avatarSize,
                                          height: avatarSize,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              _avatarFallback(),
                                        )
                                      : Image.asset(
                                          'assets/images/nmimes_front.png',
                                          width: avatarSize,
                                          height: avatarSize,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              _avatarFallback(),
                                        ),
                                ),
                              ),
                              Positioned(
                                right: -4,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/avatar'),
                                  child: Container(
                                    width: context.rs(28),
                                    height: context.rs(28),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.edit_rounded,
                                      color: AppColors.primary,
                                      size: context.rs(15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: context.rs(8)),
                          // Fixed name — pinned with the avatar, never scrolls.
                          // Opaque background so scrolling cards can never show
                          // through behind it. Single line + ellipsis so a long
                          // name can't wrap into the first scrolling card below.
                          Container(
                            width: double.infinity,
                            color: AppColors.background,
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.font(
                                context,
                                fontSize: context.rs(28),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E2E2E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() => Container(
        color: const Color(0xFFE8E8E8),
        child: const Icon(Icons.person_rounded, color: Colors.grey, size: 60),
      );
}
