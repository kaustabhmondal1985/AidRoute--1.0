import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/animations/entrance_animations.dart';
import '../../core/animations/micro_interactions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

enum _NotifChannel { sms, email, both }

class _NotificationItem {
  final String id;
  final String caseId;
  final String clientName;
  final String summary;
  final String urgencyLabel;
  final Color urgencyColor;
  final Color urgencyBg;
  final IconData urgencyIcon;
  final DateTime sentAt;
  bool isSent;
  final _NotifChannel channel;

  _NotificationItem({
    required this.id,
    required this.caseId,
    required this.clientName,
    required this.summary,
    required this.urgencyLabel,
    required this.urgencyColor,
    required this.urgencyBg,
    required this.urgencyIcon,
    required this.sentAt,
    this.isSent = false,
    required this.channel,
  });
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      id: 'n1',
      caseId: 'CASE-2026-0847',
      clientName: 'Priya Mehta',
      summary: 'Court hearing deadline in 72 hours. Eviction notice document flagged HIGH urgency.',
      urgencyLabel: 'CRITICAL',
      urgencyColor: AppColors.urgent,
      urgencyBg: AppColors.urgentBg,
      urgencyIcon: Icons.warning_amber_rounded,
      sentAt: DateTime.now().subtract(const Duration(minutes: 14)),
      isSent: false,
      channel: _NotifChannel.both,
    ),
    _NotificationItem(
      id: 'n2',
      caseId: 'CASE-2026-0831',
      clientName: 'Arjun Sharma',
      summary: 'New document uploaded: Medical record. Requires legal review within 48 hours.',
      urgencyLabel: 'HIGH',
      urgencyColor: AppColors.moderate,
      urgencyBg: AppColors.moderateBg,
      urgencyIcon: Icons.priority_high_rounded,
      sentAt: DateTime.now().subtract(const Duration(hours: 2)),
      isSent: true,
      channel: _NotifChannel.email,
    ),
    _NotificationItem(
      id: 'n3',
      caseId: 'CASE-2026-0819',
      clientName: 'Fatima Shaikh',
      summary: 'Intake completed. Multilingual intake in Marathi. Lawyer match pending assignment.',
      urgencyLabel: 'MEDIUM',
      urgencyColor: AppColors.secondary,
      urgencyBg: const Color(0xFFE6FAF8),
      urgencyIcon: Icons.info_outline_rounded,
      sentAt: DateTime.now().subtract(const Duration(hours: 5)),
      isSent: true,
      channel: _NotifChannel.sms,
    ),
    _NotificationItem(
      id: 'n4',
      caseId: 'CASE-2026-0804',
      clientName: 'Ramesh Patil',
      summary: 'Appointment confirmed with Adv. Neha Kulkarni for 22 Aug, 10:00 AM.',
      urgencyLabel: 'ROUTINE',
      urgencyColor: AppColors.routine,
      urgencyBg: AppColors.routineBg,
      urgencyIcon: Icons.check_circle_outline_rounded,
      sentAt: DateTime.now().subtract(const Duration(days: 1)),
      isSent: true,
      channel: _NotifChannel.both,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Automated Alerts',
          style: AppTextStyles.titleMedium(
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ).copyWith(fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildPendingBadge(isDark),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Banner
          AnimatedFadeSlide(
            child: _buildSummaryBanner(isDark),
          ),

          // Tab Bar
          AnimatedFadeSlide(
            delay: const Duration(milliseconds: 80),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                labelColor: Colors.white,
                unselectedLabelColor:
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                labelStyle: AppTextStyles.label(Colors.white).copyWith(fontSize: 12),
                unselectedLabelStyle: AppTextStyles.label(AppColors.textSecondaryLight)
                    .copyWith(fontSize: 12),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Sent'),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingM),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_notifications, isDark),
                _buildList(
                  _notifications.where((n) => !n.isSent).toList(),
                  isDark,
                ),
                _buildList(
                  _notifications.where((n) => n.isSent).toList(),
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendAllPending,
        backgroundColor: AppColors.urgent,
        icon: const Icon(Icons.send_rounded, color: Colors.white),
        label: Text(
          'Send All Pending',
          style: AppTextStyles.label(Colors.white).copyWith(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildPendingBadge(bool isDark) {
    final pending = _notifications.where((n) => !n.isSent).length;
    if (pending == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.urgent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$pending urgent',
        style: AppTextStyles.caption(Colors.white)
            .copyWith(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.07, 1.07),
          duration: 900.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildSummaryBanner(bool isDark) {
    final pending = _notifications.where((n) => !n.isSent).length;
    final sent = _notifications.where((n) => n.isSent).length;

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded,
              color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clinic Alert Center',
                  style: AppTextStyles.titleMedium(Colors.white)
                      .copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '$pending pending • $sent sent today',
                  style: AppTextStyles.caption(Colors.white70)
                      .copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Via SMS + Email',
              style: AppTextStyles.caption(Colors.white)
                  .copyWith(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<_NotificationItem> items, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: isDark ? AppColors.textSecondaryDark : AppColors.borderLight,
            ),
            const SizedBox(height: 12),
            Text(
              'No notifications here',
              style: AppTextStyles.bodyMedium(
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AnimatedFadeSlide(
          delay: Duration(milliseconds: 100 + index * 60),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
            child: _buildNotifCard(items[index], isDark),
          ),
        );
      },
    );
  }

  Widget _buildNotifCard(_NotificationItem notif, bool isDark) {
    final channelIcon = notif.channel == _NotifChannel.sms
        ? Icons.sms_rounded
        : notif.channel == _NotifChannel.email
            ? Icons.email_rounded
            : Icons.all_inclusive_rounded;

    return AnimatedPressScale(
      onTap: () => _showActionSheet(notif),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: notif.isSent
                ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                : notif.urgencyColor.withValues(alpha: 0.5),
            width: notif.isSent ? 1 : 1.5,
          ),
          boxShadow: notif.isSent
              ? null
              : [
                  BoxShadow(
                    color: notif.urgencyColor.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: notif.urgencyBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: notif.urgencyColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(notif.urgencyIcon,
                          color: notif.urgencyColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        notif.urgencyLabel,
                        style: AppTextStyles.caption(notif.urgencyColor)
                            .copyWith(
                                fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(channelIcon,
                    size: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: notif.isSent
                        ? AppColors.routineBg
                        : AppColors.urgentBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    notif.isSent ? 'Sent' : 'Pending',
                    style: AppTextStyles.caption(
                      notif.isSent ? AppColors.routine : AppColors.urgent,
                    ).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      AppColors.primaryLight.withValues(alpha: 0.15),
                  child: Text(
                    notif.clientName[0],
                    style: AppTextStyles.label(AppColors.primaryLight)
                        .copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.clientName,
                        style: AppTextStyles.label(
                          isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ).copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        notif.caseId,
                        style: AppTextStyles.caption(
                          isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTime(notif.sentAt),
                  style: AppTextStyles.caption(
                    isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ).copyWith(fontSize: 11),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              notif.summary,
              style: AppTextStyles.bodyMedium(
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ).copyWith(fontSize: 12, height: 1.4),
            ),

            if (!notif.isSent) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      label: 'Send Now',
                      color: notif.urgencyColor,
                      icon: Icons.send_rounded,
                      onTap: () {
                        setState(() => notif.isSent = true);
                        _showSentSnackbar(notif.clientName);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionButton(
                      label: 'Dismiss',
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      icon: Icons.close_rounded,
                      onTap: () => setState(() => notif.isSent = true),
                      isSecondary: true,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    bool isSecondary = false,
    bool isDark = false,
  }) {
    return AnimatedPressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSecondary
              ? (isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9))
              : color,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: isSecondary ? Border.all(color: AppColors.borderLight) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 14,
                color: isSecondary ? color : Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.label(
                isSecondary ? color : Colors.white,
              ).copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSheet(_NotificationItem notif) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${notif.clientName} — ${notif.caseId}',
                style: AppTextStyles.titleMedium(
                  isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ).copyWith(fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                notif.summary,
                style: AppTextStyles.bodyMedium(
                  isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ).copyWith(fontSize: 13),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              _actionButton(
                label: notif.isSent ? 'Resend Alert' : 'Send Alert Now',
                color: notif.urgencyColor,
                icon: Icons.send_rounded,
                onTap: () {
                  setState(() => notif.isSent = true);
                  Navigator.pop(ctx);
                  _showSentSnackbar(notif.clientName);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _sendAllPending() {
    setState(() {
      for (final n in _notifications) {
        n.isSent = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'All pending alerts sent via SMS & email!',
              style: AppTextStyles.caption(Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.routine,
        duration: const Duration(seconds: 3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSentSnackbar(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert sent for $name'),
        backgroundColor: AppColors.routine,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
