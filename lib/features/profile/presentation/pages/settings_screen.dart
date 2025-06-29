import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/theme/theme_toggle_switch.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings',
          style: GoogleFonts.montaga(
            color: isDarkMode ? Colors.white : AppColors.accentColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSection(
            title: 'preference',
            items: [
              const SettingsItem(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: ThemeToggle(),
              ),
              SettingsItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SettingsSection(
            title: 'Support & Legal',
            items: [
              SettingsItem(
                icon: FontAwesomeIcons.headset,
                title: 'Customer Service',
                subtitle: '24/7 Support',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.circleInfo,
                title: 'About Us',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.star,
                title: 'Rate Us',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.fileContract,
                title: 'Terms & Conditions',
              ),
              SettingsItem(
                icon: FontAwesomeIcons.userShield,
                title: 'Privacy Policy',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;

  const SettingsSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montaga(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.accentColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppColors.accentColor),
                    title: Text(item.title),
                    subtitle:
                        item.subtitle != null ? Text(item.subtitle!) : null,
                    trailing: item.trailing ??
                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    onTap: item.onTap,
                  ),
                  if (index != items.length - 1)
                    const Divider(indent: 16, endIndent: 16, height: 1),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
}
