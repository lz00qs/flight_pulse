import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';

enum SettingsSection { general, appearance, language, notifications, account }

class SettingsView extends ConsumerStatefulWidget {
  final bool isMobile;

  const SettingsView({super.key, required this.isMobile});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  SettingsSection _activeSection = SettingsSection.general;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isMobile ? 16.0 : 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Text(
            'Settings',
            style: TextStyle(
              fontSize: widget.isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Personal preferences and delivery channels.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),

          const SizedBox(height: 24),

          // Layout: Left Navigation Sub-cards + Right Content Panel
          if (widget.isMobile) ...[
            _buildMobileSectionSelector(context, isDark),
            const SizedBox(height: 16),
            _buildActiveContent(context, isDark),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 240,
                  child: _buildDesktopSidebarSections(context, isDark),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildActiveContent(context, isDark),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebarSections(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          _buildSectionTile('General', SettingsSection.general, isDark),
          _buildSectionTile('Appearance', SettingsSection.appearance, isDark),
          _buildSectionTile('Language', SettingsSection.language, isDark),
          _buildSectionTile('Notifications', SettingsSection.notifications, isDark),
          _buildSectionTile('Account', SettingsSection.account, isDark),
        ],
      ),
    );
  }

  Widget _buildSectionTile(String label, SettingsSection section, bool isDark) {
    final isSelected = _activeSection == section;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _activeSection = section;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileSectionSelector(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SettingsSection.values.map((section) {
          final isSelected = _activeSection == section;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_sectionLabel(section)),
              selected: isSelected,
              selectedColor: isDark ? AppColors.primary : AppColors.surfaceSecondaryLight,
              labelStyle: TextStyle(
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.primary)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) {
                setState(() => _activeSection = section);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveContent(BuildContext context, bool isDark) {
    switch (_activeSection) {
      case SettingsSection.general:
        return _buildGeneralSection(context, isDark);
      case SettingsSection.appearance:
        return _buildAppearanceSection(context, isDark);
      case SettingsSection.language:
        return _buildLanguageSection(context, isDark);
      case SettingsSection.notifications:
        return _buildNotificationsSection(context, isDark);
      case SettingsSection.account:
        return _buildAccountSection(context, isDark);
    }
  }

  // General Settings
  Widget _buildGeneralSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Currency: HK\$ (Hong Kong Dollar)'),
          const SizedBox(height: 12),
          const Text('Time zone: (GMT+08:00) Hong Kong, Beijing'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('General settings saved.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save preferences'),
          ),
        ],
      ),
    );
  }

  // Appearance Settings (Riverpod Theme Switcher)
  Widget _buildAppearanceSection(BuildContext context, bool isDark) {
    final themeMode = ref.watch(themeModeProvider);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how FlightPulse looks on this device.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildThemeCard('Light', ThemeMode.light, themeMode, isDark, Icons.light_mode_outlined),
              const SizedBox(width: 12),
              _buildThemeCard('Dark', ThemeMode.dark, themeMode, isDark, Icons.dark_mode_outlined),
              const SizedBox(width: 12),
              _buildThemeCard('System', ThemeMode.system, themeMode, isDark, Icons.desktop_windows_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(String title, ThemeMode mode, ThemeMode currentMode, bool isDark, IconData icon) {
    final isSelected = currentMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(themeModeProvider.notifier).state = mode;
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Language Settings (Riverpod Language Switcher)
  Widget _buildLanguageSection(BuildContext context, bool isDark) {
    final currentLang = ref.watch(languageProvider);

    final languages = [
      {'code': 'EN', 'name': 'English', 'status': 'Current language'},
      {'code': 'zh-CN', 'name': '简体中文', 'status': 'Simplified Chinese'},
      {'code': 'zh-TW', 'name': '繁體中文', 'status': 'Planned'},
      {'code': 'ja', 'name': '日本語', 'status': 'Planned'},
    ];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Interface language',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          ...languages.map((lang) {
            final isSelected = currentLang == lang['code'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  ref.read(languageProvider.notifier).state = lang['code']!;
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight)
                        : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang['name']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                      ),
                      Text(
                        lang['status']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Notifications Settings
  Widget _buildNotificationsSection(BuildContext context, bool isDark) {
    final settings = ref.watch(notificationSettingsProvider);

    return Column(
      children: [
        // Telegram Notification Card
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Telegram notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Switch(
                    value: settings.telegramEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      ref.read(notificationSettingsProvider.notifier).state =
                          settings.copyWith(telegramEnabled: val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Status: ${settings.telegramEnabled ? "Enabled · Connected" : "Disabled"}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Bot token',
                        filled: true,
                        fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Chat ID',
                        filled: true,
                        fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Email Notification Card
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Email notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Switch(
                    value: settings.emailEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      ref.read(notificationSettingsProvider.notifier).state =
                          settings.copyWith(emailEnabled: val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Status: ${settings.emailEnabled ? "Enabled · Configured" : "Disabled"}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email address',
                  hintText: settings.emailAddress,
                  filled: true,
                  fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Account Settings
  Widget _buildAccountSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Single-user FlightPulse account.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),
          const TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'alex',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'alex@example.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out.')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  String _sectionLabel(SettingsSection section) {
    switch (section) {
      case SettingsSection.general:
        return 'General';
      case SettingsSection.appearance:
        return 'Appearance';
      case SettingsSection.language:
        return 'Language';
      case SettingsSection.notifications:
        return 'Notifications';
      case SettingsSection.account:
        return 'Account';
    }
  }
}
