import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/product/presentation/pages/home_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool isLogin = true;

  @override
  void initState() {
    super.initState();
    // Trigger auth check when the wrapper initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return;

    final authBloc = context.read<AuthBloc>();
    try {
      final isSignedIn = await authBloc.authUseCases.isUserSignedIn();
      if (!mounted) return;

      if (isSignedIn) {
        final user = await authBloc.authUseCases.getCurrentUserDetails();
        if (!mounted) return;

        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
          );
        }
      }
    } catch (e) {
      // Silent fail - just stay on auth screen
      if (!mounted) return;
      setState(() => isLogin = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLogin ? const LoginScreen() : const SignupScreen(),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLogin ? "Don't have an account?" : "Already have an account?",
                style: GoogleFonts.montserrat(
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin ? "Sign Up" : "Login",
                  style: GoogleFonts.montserrat(
                    color: AppColors.brandAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
