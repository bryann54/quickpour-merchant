import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/function_utils.dart';
import 'package:quickpourmerchant/features/auth/data/models/user_model.dart';
import 'package:quickpourmerchant/features/auth/domain/usecases/auth_usecases.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/logout_button_widget.dart';

// FirebaseDrawer logic remains the same
class FirebaseDrawer extends StatelessWidget {
  final AuthUseCases authUseCases;
  final VoidCallback? onLogout;

  const FirebaseDrawer({
    required this.authUseCases,
    this.onLogout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: authUseCases.getCurrentUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Drawer(
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Drawer(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final user = snapshot.data;

        return EnhancedCustomDrawer(
          storeName: user?.storeName,
          merchantImage: user?.imageUrl,
          merchantName: user?.name,
          merchantEmail: user?.email,
          onLogout: onLogout,
        );
      },
    );
  }
}

// Redesigned drawer with enhanced UI
class EnhancedCustomDrawer extends StatelessWidget {
  final String? storeName;
  final String? merchantName;
  final String? merchantEmail;
  final String? merchantImage;
  final VoidCallback? onLogout;

  const EnhancedCustomDrawer({
    super.key,
    this.storeName,
    this.merchantName,
    this.merchantEmail,
    this.merchantImage,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = storeName ?? 'AlkoHut Merchants';
    final name = merchantName ?? 'Merchant';
    final email = merchantEmail ?? 'merchant@example.com';
    // final themeData = Theme.of(context);
    // final isDarkMode = themeData.brightness == Brightness.dark;

    return Drawer(
      elevation: 16.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Enhanced header section
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE74C3C),
                  AppColors.primaryColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                // Store logo and name with glow effect
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        merchantImage != null && merchantImage!.isNotEmpty
                            ? NetworkImage(merchantImage!)
                            : null,
                    child: merchantImage == null || merchantImage!.isEmpty
                        ? Icon(
                            Icons.storefront_rounded,
                            size: 45,
                            color: AppColors.primaryColor.withOpacity(0.8),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Store name with stylish font
                Text(
                  displayName,
                  style: GoogleFonts.raleway(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),

                // Merchant details
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.email,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider with gradient
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primaryColor.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Menu items section
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 16),

                // Enhanced menu items with hover effect
                EnhancedDrawerTile(
                  icon: FontAwesomeIcons.gaugeHigh,
                  title: 'Dashboard',
                  onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                  isActive: true,
                ),
                EnhancedDrawerTile(
                  icon: FontAwesomeIcons.chartPie,
                  title: 'Analytics',
                  onTap: () => Navigator.pushNamed(context, '/analytics'),
                ),
                EnhancedDrawerTile(
                  icon: FontAwesomeIcons.solidBell,
                  title: 'Notifications',
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                  badgeCount: 3,
                ),
                EnhancedDrawerTile(
                  icon: FontAwesomeIcons.bullhorn,
                  title: 'Promotions',
                  onTap: () => Navigator.pushNamed(context, '/promotions'),
                ),
                EnhancedDrawerTile(
                  icon: FontAwesomeIcons.barsProgress,
                  title: 'Orders',
                  onTap: () => Navigator.pushNamed(context, '/orders'),
                ),
                EnhancedDrawerTile(
                  icon: FontAwesomeIcons.boxOpen,
                  title: 'Products',
                  onTap: () => Navigator.pushNamed(context, '/products'),
                ),
                EnhancedDrawerTile(
                  icon: FontAwesomeIcons.circleUser,
                  title: 'Profile',
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                EnhancedDrawerTile(
                  icon: FontAwesomeIcons.gear,
                  title: 'Settings',
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Footer Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                if (onLogout != null)
                  FilledButton.icon(
                    onPressed: onLogout,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  const LogOutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced drawer tile with hover effect and active state
class EnhancedDrawerTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isActive;
  final int? badgeCount;

  const EnhancedDrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
    this.badgeCount,
    super.key,
  });

  @override
  State<EnhancedDrawerTile> createState() => _EnhancedDrawerTileState();
}

class _EnhancedDrawerTileState extends State<EnhancedDrawerTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const activeColor = AppColors.primaryColor;
    final inactiveIconColor = isDark ? Colors.white70 : Colors.grey[700];

    final backgroundColor = widget.isActive
        ? activeColor.withOpacity(0.1)
        : _isHovered
            ? isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey[100]
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: widget.isActive
              ? Border.all(color: activeColor.withOpacity(0.3), width: 1)
              : null,
        ),
        child: ListTile(
          leading: FaIcon(
            widget.icon,
            color: widget.isActive ? activeColor : inactiveIconColor,
            size: 20,
          ),
          title: Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
              color: widget.isActive
                  ? activeColor
                  : isDark
                      ? Colors.white
                      : Colors.grey[800],
            ),
          ),
          trailing: widget.badgeCount != null
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),
                  child: Text(
                    '${widget.badgeCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : widget.isActive
                  ? Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onTap: () {
            Navigator.pop(context);
            widget.onTap();
          },
        ),
      ),
    );
  }
}

// Keep the original DrawerTile for backward compatibility
class DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: FaIcon(
            icon,
            color: iconColor ?? theme.iconTheme.color?.withOpacity(.4),
            size: 30,
          ),
          title: GradientText(text: title),
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
        ),
        const Divider()
      ],
    );
  }
}
