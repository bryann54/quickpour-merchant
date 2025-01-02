

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/theme/theme_toggle_switch.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/auth/data/models/user_model.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/logout_button_widget.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/option_widget.dart';

class ProfileScreen extends StatelessWidget {
 
  final AuthUseCases authUseCases;

  const ProfileScreen({
    super.key,
  
    required this.authUseCases,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title:   Center(
                    child: Text(
                      'Profile',
                      style: GoogleFonts.montaga(
                                    textStyle: theme.textTheme.displayLarge?.copyWith(
                        color: isDarkMode
                            ? AppColors.cardColor
                            : AppColors.accentColorDark,
                      ),)
                    ),
                  ),),
      body: FutureBuilder<User?>(
        future: authUseCases.authRepository.getCurrentUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                
                  const SizedBox(height: 20),

                  // User Profile Section
                  _buildUserProfileHeader(context, user),

                  const SizedBox(height: 24),

                  // User Activity Section
                  _buildSectionTitle(context, 'Your Activity'),
                  const SizedBox(height: 12),
                  const ProfileStatisticsSection(),

                  const SizedBox(height: 24),

                  // Profile Options
                  _buildSectionTitle(context, 'Account'),
                  const SizedBox(height: 12),
                  _buildProfileOptions(context),

                  const SizedBox(height: 24),

                  // Logout Button
                  const LogOutButton(),
                ],
              ),
            ),
          );
        },
      ),
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
            child:const FaIcon(
              FontAwesomeIcons.userLarge,
              color: Color.fromARGB(61, 60, 62, 65),
              size: 50,
            ),
          ),
        ),
        const SizedBox(width: 16),
    Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Owner: ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(
                      width: 8), // Add spacing between label and value
                  Expanded(
                    // Wrap in Expanded to handle overflow
                    child: Text(
                      user.firstName,
                      style: GoogleFonts.acme(
                        textStyle: Theme.of(context).textTheme.headlineSmall,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle text overflow
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12), // Increased vertical spacing
              Row(
                children: [
                  const Text('Store: ',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.lastName,
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
        )
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.montaga(
                                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),)
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
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
            onTap: () {
              // TODO: Implement edit profile navigation
            },
          ),
          _buildDivider(),
          _buildProfileOptionItem(
            context,
            icon: Icons.settings,
            title: 'Account Settings',
            onTap: () {
              context.push('/settings');
            },
          ),
          _buildDivider(),
          _buildProfileOptionItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // TODO: Implement help & support navigation
            },
          ),
          _buildDivider(),
        const   ListTile(
            leading: FaIcon(FontAwesomeIcons.moon),
            title: Text('dark mode'),
            trailing: ThemeToggle(),
           )
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
        style:  GoogleFonts.acme(fontSize: 16,fontWeight: FontWeight.normal),
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


