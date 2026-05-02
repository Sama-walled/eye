import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import 'home_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _hasPreviousSurgeries = false;
  //Check also in the API call that the data got parsed correctly.
  //Also note to make that call ASYNC.



  bool _hasDiabetes = false;
  bool _hasFamilyHistory = false;
  String? _selectedGender;

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Send actual API request to the Flask backend!
        // Note: For Android Emulator, use 10.0.2.2. For Desktop/Web, use 127.0.0.1.
        final uri = Uri.parse('http://127.0.0.1:5000/api/register');
        
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'age': _ageController.text,
            'gender': _selectedGender,
            'hasPreviousSurgeries': _hasPreviousSurgeries,
            'hasDiabetes': _hasDiabetes,
            'hasFamilyHistory': _hasFamilyHistory
          }),
        );

        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          print("Successfully registered user ID: ${responseData['user']['id']}");

          // Create local user model for caching
          final user = UserModel(
            id: responseData['user']['id'].toString(),
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null,
            gender: _selectedGender,
            hasPreviousSurgeries: _hasPreviousSurgeries,
            hasDiabetes: _hasDiabetes,
            hasFamilyHistory: _hasFamilyHistory,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );

          // Save user data using provider
          await ref.read(userProvider.notifier).setUser(user);

          // Set login status
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);

          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          final errorData = jsonDecode(response.body);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Failed: ${errorData['error']}')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection Error: Unable to reach the server. Is the backend running?')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: AppTheme.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Title
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Help us understand your eye health history',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Email field to be logged also when we make the call to know if
                //we are parsing the correct email to the API call
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Age field
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 1 || age > 120) {
                      return 'Please enter a valid age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Gender selection
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: const Icon(Icons.people_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.white,
                  ),
                  items: ['Male', 'Female', 'Other', 'Prefer not to say']
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                // Medical History Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical History',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 20),
                      // Previous Surgeries
                      SwitchListTile(
                        title: const Text('Previous Eye Surgeries'),
                        subtitle: const Text(
                          'Have you had any eye surgeries in the past?',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _hasPreviousSurgeries,
                        onChanged: (value) {
                          setState(() {
                            _hasPreviousSurgeries = value;
                          });
                        },
                        activeThumbColor: AppTheme.primaryBlue,
                      ),
                      const Divider(),
                      // Diabetes
                      SwitchListTile(
                        title: const Text('Diabetes'),
                        subtitle: const Text(
                          'Do you have diabetes? (Important for retinopathy risk)',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _hasDiabetes,
                        onChanged: (value) {
                          setState(() {
                            _hasDiabetes = value;
                          });
                        },
                        activeThumbColor: AppTheme.primaryBlue,
                      ),
                      const Divider(),
                      // Family History
                      SwitchListTile(
                        title: const Text('Family History of Eye Diseases'),
                        subtitle: const Text(
                          'Any family history of eye diseases or retinopathy?',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _hasFamilyHistory,
                        onChanged: (value) {
                          setState(() {
                            _hasFamilyHistory = value;
                          });
                        },
                        activeThumbColor: AppTheme.primaryBlue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                // Sign Up button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                const SizedBox(height: 20),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

