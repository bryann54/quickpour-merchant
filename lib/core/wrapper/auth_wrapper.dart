import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';

import 'package:quickpourmerchant/features/product/presentation/pages/home_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';
import '../../features/auth/presentation/pages/Splash_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isLogin = true;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return; // Add this check
    final authBloc = context.read<AuthBloc>();

    try {
      if (authBloc.authUseCases.isUserSignedIn()) {
        final user = await authBloc.authUseCases.getCurrentUserDetails();

        if (!mounted) return; // Add this check before navigation

        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          return; // Add return to prevent further execution
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
          );
          return; // Add return to prevent further execution
        }
      }

      if (!mounted) return; // Add this check before setState
      setState(() {
        isLogin = false;
        _isChecking = false;
      });
    } catch (e) {
      if (!mounted) return; // Add this check before setState
      setState(() {
        isLogin = true;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking authentication
    if (_isChecking) {
      return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: const CircularProgressIndicator(
                  color: AppColors.background,
                  strokeWidth: 10,
                ),
              ),
              const SizedBox(height: 20),
              Text('Loading next screen...',
                  style: GoogleFonts.montaga(
                      color: AppColors.background,
                      fontSize: 27,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: isLogin ? const LoginScreen() : const SignupScreen(),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isLogin
                  ? "Don't have an account?"
                  : "Already have an account?"),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin ? "Sign Up" : "Login",
                  style: const TextStyle(color: AppColors.errorDark, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
