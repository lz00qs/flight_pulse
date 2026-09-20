import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';

class MobileHeader extends ConsumerWidget {
  final VoidCallback onAddTap;

  const MobileHeader({super.key, required this.onAddTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FlightPulse',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onAddTap,
            icon: const Icon(Icons.add_rounded, size: 26, color: AppColors.primary),
            tooltip: 'Add Flight',
          ),
        ],
      ),
    );
  }
}

class MobileBottomNavBar extends ConsumerWidget {
  const MobileBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentNavProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            ref: ref,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Overview',
            tab: NavigationTab.overview,
            isActive: currentTab == NavigationTab.overview,
            isDark: isDark,
          ),
          _buildNavItem(
            ref: ref,
            icon: Icons.airplane_ticket_outlined,
            activeIcon: Icons.airplane_ticket,
            label: 'Tracking',
            tab: NavigationTab.tracking,
            isActive: currentTab == NavigationTab.tracking,
            isDark: isDark,
          ),
          _buildNavItem(
            ref: ref,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
            tab: NavigationTab.settings,
            isActive: currentTab == NavigationTab.settings,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required WidgetRef ref,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required NavigationTab tab,
    required bool isActive,
    required bool isDark,
  }) {
    final color = isActive
        ? AppColors.primary
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return InkWell(
      onTap: () {
        ref.read(currentNavProvider.notifier).state = tab;
        ref.read(selectedTripIdProvider.notifier).state = null;
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
