import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';

class DesktopSidebar extends ConsumerWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentNavProvider);
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final themeLabel = themeMode == ThemeMode.dark ? 'Dark' : 'Light';

    return Container(
      width: 236,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Logo & Name
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'FlightPulse',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Navigation Links
          _buildNavItem(
            context: context,
            ref: ref,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Overview',
            tab: NavigationTab.overview,
            isActive: currentTab == NavigationTab.overview,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildNavItem(
            context: context,
            ref: ref,
            icon: Icons.airplane_ticket_outlined,
            activeIcon: Icons.airplane_ticket,
            label: 'Tracking',
            tab: NavigationTab.tracking,
            isActive: currentTab == NavigationTab.tracking,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildNavItem(
            context: context,
            ref: ref,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
            tab: NavigationTab.settings,
            isActive: currentTab == NavigationTab.settings,
            isDark: isDark,
          ),

          const Spacer(),

          // Account Info
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$language  ·  $themeLabel',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'flightpulse@home',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required NavigationTab tab,
    required bool isActive,
    required bool isDark,
  }) {
    final bgColor = isActive
        ? (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight)
        : Colors.transparent;
    final textColor = isActive
        ? AppColors.primary
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(currentNavProvider.notifier).state = tab;
          ref.read(selectedTripIdProvider.notifier).state = null;
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: textColor,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
