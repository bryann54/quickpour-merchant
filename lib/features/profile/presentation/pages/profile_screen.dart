import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/theme/theme_toggle_switch.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/auth/data/models/user_model.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/change_password.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/edit_profile_dialog.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/logout_button_widget.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/profile_shimmer.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/settings_dialog.dart';
import 'package:image_picker/image_picker.dart';
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
    final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }
  Future<User?>? _userFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _userFuture = widget.authUseCases.authRepository.getCurrentUserDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProfileScreenShimmer();
          }

          if (snapshot.hasError) {
            return _buildErrorState(context);
          }

          final user = snapshot.data;
          if (user == null) return _buildEmptyState(context);

          return RefreshIndicator(
            onRefresh: _loadUserData,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context, user),
                _buildProfileContent(context, user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, User user) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.white),
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image with Shader
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent.withOpacity(.9),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.darken,
              child: Image.asset(
                'assets/111 copy.png',
                fit: BoxFit.cover,
              ),
            ),
            // Profile Information
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: 'profile_avatar',
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.grey,
                          child: CircleAvatar(
                            radius: 77,
                            backgroundColor:
                                AppColors.accentColor.withOpacity(0.2),
                            backgroundImage: _pickedImage != null
                                ? FileImage(File(_pickedImage!.path))
                                : (user.imageUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(user.imageUrl)
                                    : null) as ImageProvider?,
                            child: user.imageUrl.isEmpty && _pickedImage == null
                                ? const Icon(Icons.person,
                                    size: 50, color: AppColors.accentColor)
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: _pickImage,
                          icon: Icon(Icons.camera_alt,
                              color: Colors.grey, size: 30),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: GoogleFonts.montaga(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                 
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (user.isVerified)
                        const Icon(Icons.verified,
                            color: Colors.white, size: 25),
                      const SizedBox(width: 6),
                      Text(
                        user.storeName,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: user.isOpen ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.isOpen ? 'Open' : 'Closed',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                   
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildStatsSection(user),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Account'),
            const SizedBox(height: 12),
            _buildProfileOptions(context, user),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'App Appearance'),
            const SizedBox(height: 12),
            _buildAppearanceSection(),
            const SizedBox(height: 24),
            const LogOutButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Products', user.products.length.toString()),
          _buildStatItem('Experience', '${user.experience}y'),
          _buildStatItem('Rating', user.rating.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montaga(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.accentColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return Container(
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
                  currentFirstName: user.name,
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
                builder: (context) => const SettingsDialog(),
              );
            },
          ),
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

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading profile data',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.red),
          ),
          TextButton(
            onPressed: _loadUserData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_outlined, size: 48),
          const SizedBox(height: 16),
          Text(
            'User data not found!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
