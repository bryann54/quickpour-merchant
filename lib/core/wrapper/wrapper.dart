import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/custom_snackbar_widget.dart';
import 'package:quickpourmerchant/core/wrapper/auth_wrapper.dart';
import 'package:quickpourmerchant/features/auth/presentation/bloc/auth_event.dart';
import 'package:quickpourmerchant/features/product/presentation/pages/home_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    // Check authentication status when the wrapper initializes
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          CustomAnimatedSnackbar.show(
            context: context,
            message: "Authentication Error: ${state.message}",
            icon: Icons.error_outline,
            backgroundColor: Colors.red,
          );
        }

        if (state is Authenticated) {
          CustomAnimatedSnackbar.show(
            context: context,
            message: "Welcome back!!",
            icon: Icons.check_circle_outline,
            backgroundColor: Colors.green,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial || state is AuthLoading) {
            // Show a blank screen while checking auth status
            return const Scaffold(body: SizedBox.shrink());
          } else if (state is Authenticated) {
            return const HomeScreen();
          } else {
            return const AuthWrapper();
          }
        },
      ),
    );
  }
}
