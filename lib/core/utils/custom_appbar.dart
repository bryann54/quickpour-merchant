import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/logout_button_widget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({
    required this.title,
    required this.scaffoldKey,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const FaIcon(FontAwesomeIcons.bars),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      title: title,
      centerTitle: true,
    );
  }
}

class CustomDrawer extends StatelessWidget {
 final String? lastName;
  final String? merchantImage;
  final VoidCallback? onLogout;

  const CustomDrawer({
    super.key,
    this.lastName ,
    this.merchantImage,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
     final displayName = lastName ?? 'QuickPour Merchants';
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE74C3C),
                  Color(0xFFF39C12),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: merchantImage != null
                      ? NetworkImage(merchantImage!)
                      : null,
                  child: merchantImage == null
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Color(0xFFE74C3C),
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  displayName,
                  style: GoogleFonts.acme(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
       
          DrawerTile(
            icon: FontAwesomeIcons.boxesStacked,
            title: 'Products',
            onTap: () => Navigator.pushNamed(context, '/products'),
          ),
          DrawerTile(
            icon: FontAwesomeIcons.clipboardList,
            title: 'Orders',
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
          DrawerTile(
            icon: FontAwesomeIcons.chartLine,
            title: 'Analytics',
            onTap: () => Navigator.pushNamed(context, '/analytics'),
          ),
          DrawerTile(
            icon: FontAwesomeIcons.bell,
            title: 'Notifications',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
             DrawerTile(
            icon: FontAwesomeIcons.circleUser,
            title: 'Profile',
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
       
         SizedBox(
        height: 200,
         ),
         LogOutButton()
        ],
      ),
    );
  }
}

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
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            Navigator.pop(context); 
            onTap();
          },
        ),
        Divider()
      ],
    );
  }
}

// Helper method to create gradient text
class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const GradientText({
    required this.text,
    this.fontSize = 25,
    this.fontWeight = FontWeight.w800,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFE74C3C),
          Color(0xFFF39C12),
        ],
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.acme(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
        ),
      ),
    );
  }
}
