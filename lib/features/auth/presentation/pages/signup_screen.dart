// signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickpourmerchant/core/utils/colors.dart';
import 'package:quickpourmerchant/core/utils/time_range_utils.dart';
import 'package:quickpourmerchant/features/auth/presentation/pages/login_screen.dart';
import 'package:quickpourmerchant/features/auth/presentation/widgets/facebook_signin_button.dart';
import 'package:quickpourmerchant/features/auth/presentation/widgets/google_signin_button.dart';
import 'package:quickpourmerchant/features/product/presentation/pages/home_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
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

  Future<void> _selectTimeRange(BuildContext context) async {
    if (_is24Hours) return;

    final TimeOfDay? openingTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Select Opening Time',
    );

    if (openingTime != null) {
      final TimeOfDay? closingTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 17, minute: 0),
        helpText: 'Select Closing Time',
      );

      if (closingTime != null) {
        setState(() {
          _storeHours = StoreHours(opening: openingTime, closing: closingTime);
        });
      }
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
                padding: EdgeInsets.only(top: 40, left: 10, right: 10.0),
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
                        // Business Information Section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Business Information',
                                style: GoogleFonts.acme(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _storeNameController,
                                decoration: InputDecoration(
                                  labelText: 'Store Name',
                                  prefixIcon: const Icon(Icons.store_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter store name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _locationController,
                                decoration: InputDecoration(
                                  labelText: 'Store Location',
                                  prefixIcon:
                                      const Icon(Icons.location_on_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter store location';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                            Text(
            'Operating Hours',
            style: GoogleFonts.acme(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          Row(
            children: [
              Checkbox(
                value: _is24Hours,
                onChanged: (value) {
                  setState(() {
                    _is24Hours = value ?? false;
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
                },
              ),
              Text('24 Hours'),
            ],
          ),

          if (!_is24Hours) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectTimeRange(context),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _storeHours?.getDisplayText() ?? 'Select Operating Hours',
                      style: TextStyle(
                        color: _storeHours == null 
                            ? Colors.grey 
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Icon(Icons.access_time),
                  ],
                ),
              ),
            ),
      
                        const SizedBox(height: 20),
                        // Personal Information Section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Information',
                                style: GoogleFonts.acme(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Rest of your existing fields...
                              TextFormField(
                                controller: _fullNameController,
                                decoration: InputDecoration(
                                  labelText: 'Owner\'s Name',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter owner\'s name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your email';
                                  }
                                  if (!value!.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your password';
                                  }
                                  if (value!.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                ElevatedButton(
            onPressed: state is AuthLoading
                ? null
                : () {
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
                  },
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
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Row(
                       children: [
                         const Expanded(
                           child: Divider(
                             color: Colors.grey,
                             thickness: 1,
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16.0),
                           child: Text(
                             'Or Sign Up with',
                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                   color: Colors.grey,
                                 ),
                           ),
                         ),
                         const Expanded(
                           child: Divider(
                             color: Colors.grey,
                             thickness: 1,
                           ),
                         ),
                       ],
                     ),
                   ),
                  const    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GoogleSignInButton(
                        
                          ),
                          const SizedBox(width: 30),
                          FacebookSignInButton(
                        
                          ),
                        ],
                      ),
                  ],
                  
              
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