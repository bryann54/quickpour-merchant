
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
    final authBloc = context.read<AuthBloc>();

    try {
      // Check if user is signed in
      if (authBloc.authUseCases.isUserSignedIn()) {
        // Attempt to get user details
        final user = await authBloc.authUseCases.getCurrentUserDetails();

        if (user != null) {
          // User is fully authenticated, navigate to BottomNav
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } else {
          // No user details found, navigate to Splash/Signup
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
          );
        }
      } else {
        // No user signed in, set to signup
        setState(() {
          isLogin = false;
          _isChecking = false;
        });
      }
    } catch (e) {
      // Error in authentication, default to login
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
                child: CircularProgressIndicator(
                  color: AppColors.background,
                  strokeWidth: 10,
                  
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading next screen...',
               style: GoogleFonts.montaga(
                      color: AppColors.background,
                      fontSize: 27,
                      fontWeight: FontWeight.bold)
              ),
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
                  style: TextStyle(color: AppColors.errorDark, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
