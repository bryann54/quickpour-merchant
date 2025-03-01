// lib/features/auth/presentation/pages/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/time_range_utils.dart';
import 'package:quickpourmerchant/features/auth/presentation/widgets/business_info_section.dart';
import 'package:quickpourmerchant/features/auth/presentation/widgets/personal_info_section.dart';
import 'package:quickpourmerchant/features/product/presentation/pages/home_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/operating_hours_section.dart';
import '../widgets/social_signup_section.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _is24Hours = false;
  StoreHours? _storeHours;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _storeNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _updateStoreHours(StoreHours? hours) {
    setState(() {
      _storeHours = hours;
    });
  }

  void _update24HoursStatus(bool value) {
    setState(() {
      _is24Hours = value;
      if (_is24Hours) {
        _storeHours = StoreHours(
          opening: const TimeOfDay(hour: 0, minute: 0),
          closing: const TimeOfDay(hour: 23, minute: 59),
          is24Hours: true,
        );
      } else {
        _storeHours = null;
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_storeHours == null && !_is24Hours) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select operating hours'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final storeHours = _is24Hours
          ? StoreHours(
              opening: const TimeOfDay(hour: 0, minute: 0),
              closing: const TimeOfDay(hour: 23, minute: 59),
              is24Hours: true,
            )
          : _storeHours!;

      context.read<AuthBloc>().add(
            SignupEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              fullName: _fullNameController.text.trim(),
              storeName: _storeNameController.text.trim(),
              location: _locationController.text.trim(),
              imageUrl: '',
              storeHours: storeHours.toJson(),
              is24Hours: _is24Hours,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        },
        builder: (context, state) {
          final theme = Theme.of(context);
          final isDarkMode = theme.brightness == Brightness.dark;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 10, right: 10.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create Merchant Account',
                        style: GoogleFonts.acme(
                          textStyle: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set up your store profile',
                        style: GoogleFonts.acme(
                          textStyle:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.accentColorDark
                                        : AppColors.accentColor,
                                    fontSize: 20,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      BusinessInformationSection(
                        storeNameController: _storeNameController,
                        locationController: _locationController,
                        isDarkMode: isDarkMode,
                      ),
                      OperatingHoursSection(
                        is24Hours: _is24Hours,
                        storeHours: _storeHours,
                        onUpdate24Hours: _update24HoursStatus,
                        onUpdateStoreHours: _updateStoreHours,
                      ),
                      const SizedBox(height: 20),
                      PersonalInformationSection(
                        fullNameController: _fullNameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: state is AuthLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Create Store Account'),
                      ),
                      const SizedBox(height: 70),
                      const SocialSignupSection(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
