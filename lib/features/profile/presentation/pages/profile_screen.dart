import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/theme/theme_toggle_switch.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/auth/data/models/user_model.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/change_password.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/edit_profile_dialog.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/logout_button_widget.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/option_widget.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/profile_shimmer.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/settings_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final AuthUseCases authUseCases;

  const ProfileScreen({
    super.key,
    required this.authUseCases,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<User?>? _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _userFuture = widget.authUseCases.authRepository.getCurrentUserDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.montaga(
            textStyle: theme.textTheme.displayLarge?.copyWith(
              color:
                  isDarkMode ? AppColors.cardColor : AppColors.accentColorDark,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<User?>(
        future:
            _userFuture, // Use the stored future instead of creating a new one
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProfileScreenShimmer();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
              ),
            );
          }

          final user = snapshot.data;

          if (user == null) {
            return Center(
              child: Text(
                'User data not found!',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadUserData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildUserProfileHeader(context, user),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Your Activity'),
                    const SizedBox(height: 12),
                    const ProfileStatisticsSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Account'),
                    const SizedBox(height: 12),
                    _buildProfileOptions(context, user),
                    const SizedBox(height: 24),
                   _buildSectionTitle(context, 'App Appearance'),
                   const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentColor.withOpacity(0.2),
                        ),
                      ),
                      child: _buildSettingsItem(
                        context,
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        trailing: const ThemeToggle(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const LogOutButton(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? AppColors.accentColor,
      ),
      title: Text(
        title,
        style: GoogleFonts.acme(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildUserProfileHeader(BuildContext context, User user) {
    return Row(
      children: [
        Hero(
          tag: 'profile_avatar',
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.accentColor.withOpacity(0.2),
            child: const FaIcon(
              FontAwesomeIcons.userLarge,
              color: Color.fromARGB(61, 60, 62, 65),
              size: 50,
            ),
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Owner: ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.fullName,
                      style: GoogleFonts.acme(
                        textStyle: Theme.of(context).textTheme.headlineSmall,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Store: ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.storeName,
                      style: GoogleFonts.acme(
                        textStyle: Theme.of(context).textTheme.headlineSmall,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Email: ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.email,
                      style: GoogleFonts.montaga(
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.montaga(
        textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, User user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildProfileOptionItem(  
            context,
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => EditProfileDialog(
                  currentFirstName: user.fullName,
                  currentLastName: user.storeName,
                ),
              );

              if (result == true) {
                _loadUserData();
              }
            },
          ),
          _buildDivider(),
           _buildProfileOptionItem(
            context,
            icon: Icons.lock,
            title: 'change Password',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ChangePassword(),
              ).then((success) {
                if (success == true) {
                  // Handle successful password change
                }
              });
            },
          ),
          _buildDivider(),
          _buildProfileOptionItem(
            context,
            icon: Icons.settings,
            title: 'Account Settings',
            onTap: () {
             showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),);
            },
          ),
          // _buildDivider(),
          // _buildProfileOptionItem(
          //   context,
          //   icon: Icons.help_outline,
          //   title: 'Help & Support',
          //   onTap: () {
          //     // TODO: Implement help & support navigation
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildProfileOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.accentColor,
      ),
      title: Text(
        title,
        style: GoogleFonts.acme(fontSize: 16, fontWeight: FontWeight.normal),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
      ),
      onTap: onTap,
    );
  }


  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        height: 1,
        color: AppColors.dividerColorDark.withOpacity(0.3),
      ),
    );
  }
}
