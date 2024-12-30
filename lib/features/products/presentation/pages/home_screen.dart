import 'package:flutter/material.dart';
import 'package:quickpourmerchant/core/utils/custom_appbar.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        title: const GradientText(text: 'QuickPour Merchant'),
      ),
      drawer: CustomDrawer(
        merchantName: 'QuickPour Merchant',
        // merchantImage: 'https://your-image-url.com', // Optional
        onLogout: () {
          // Add any additional logout logic here
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: const Center(
        child: Text('Home Screen Content'),
      ),
    );
  }
}
