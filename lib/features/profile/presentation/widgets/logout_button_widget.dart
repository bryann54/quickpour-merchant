import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quickpourmerchant/features/auth/presentation/bloc/auth_event.dart';
import 'package:quickpourmerchant/features/profile/presentation/widgets/logout_dialog.dart';

class LogOutButton extends StatefulWidget {
  const LogOutButton({super.key});

  @override
  State<LogOutButton> createState() => _LogOutButtonState();
}

class _LogOutButtonState extends State<LogOutButton> {
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomLogoutDialog(
          onConfirm: () {
            Navigator.of(context).pop();
            context.read<AuthBloc>().add(LogoutEvent());
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLightMode = brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 5,
        shadowColor: isLightMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
        child: InkWell(
          onTap: _showLogoutConfirmationDialog,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isLightMode
                  ? AppColors.lightButtonGradient
                  : AppColors.darkButtonGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'logout',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
