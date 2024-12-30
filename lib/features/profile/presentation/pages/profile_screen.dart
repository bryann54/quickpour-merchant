import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/theme/theme_toggle_switch.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFE74C3C),
              Color(0xFFF39C12),
            ],
          ).createShader(bounds),
          child: Text(
            'Profile',
            style: GoogleFonts.acme(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFE74C3C),
                    child: Icon(
                      Icons.store,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Wine & Spirits Store',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'License #: ABC123456',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Business Information
            const Text(
              'Business Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              icon: Icons.location_on,
              title: 'Address',
              subtitle: '123 Main Street, City, State, ZIP',
            ),
            _buildInfoTile(
              icon: Icons.phone,
              title: 'Contact',
              subtitle: '+1 (555) 123-4567',
            ),
            _buildInfoTile(
              icon: Icons.access_time,
              title: 'Business Hours',
              subtitle: 'Mon-Sat: 10:00 AM - 9:00 PM\nSun: 12:00 PM - 6:00 PM',
            ),
            _buildInfoTile(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'store@quickpour.com',
            ),

            const SizedBox(height: 32),

            // Settings Section
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Push Notifications'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    trailing: const ThemeToggle(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle edit profile
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFFE74C3C),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
