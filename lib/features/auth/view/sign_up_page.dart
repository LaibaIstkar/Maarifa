import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_validator/form_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/widgets/custom_textform_field.dart';
import 'package:maarifa/core/widgets/terms_of_service_widget.dart';
import 'package:maarifa/features/auth/view/sign_in_page.dart';
import 'package:maarifa/features/home/home_landing_page.dart';
import '../view_model/auth_view_model.dart';


class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}


class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController = TextEditingController();
  bool _isTermsAccepted = false; // For managing checkbox state

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
  }

  // Function to show the Terms and Conditions popup
  Future<void> _showTermsDialog() async {
    bool agreed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions', style: TextStyle(fontFamily: 'Poppins'),),
        content: const SingleChildScrollView(
          child: SingleChildScrollView(
            child: SizedBox(
              height: 500.0,
              child: TermsOfServiceWidget(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // User disagrees
            child: const Text('I Disagree'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // User agrees
            child: const Text('I Agree'),
          ),
        ],
      ),
    );

    if (agreed) {
      setState(() {
        _isTermsAccepted = true;  // User accepted the terms
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Maarifa', style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            textStyle: const TextStyle(color: Colors.black)
        ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.secondaryColorSilver,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                CustomTextFormField(
                  controller: _usernameController,
                  label: "Username",
                  validator: ValidationBuilder().minLength(3).maxLength(20).build(),
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _emailController,
                  label: "Email",
                  validator: ValidationBuilder().email().build(),
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _passwordController,
                  label: "Password",
                  obscureText: true,
                  validator: ValidationBuilder().minLength(6).build(),
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _reEnterPasswordController,
                  label: "Re-enter Password",
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Checkbox for accepting terms and conditions
                Row(
                  children: [
                    Checkbox(
                      value: _isTermsAccepted,
                      onChanged: (value) {
                        if (value == true && !_isTermsAccepted) {
                          // If the checkbox is clicked for the first time and terms are not accepted, show the dialog
                          _showTermsDialog();
                        } else {
                          // If the checkbox is unchecked, reset the state
                          setState(() {
                            _isTermsAccepted = false;
                          });
                        }
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showTermsDialog(); // Show terms if user taps on the text
                        },
                        child: const Text(
                          "Please read the terms and conditions before creating an account",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isTermsAccepted ? () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await authViewModel.signUp(
                            email: _emailController.text,
                            password: _passwordController.text,
                            username: _usernameController.text,
                            isAdmin: false
                          );

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Sign-up successful, please verify your email'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeLandingPage()),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          );
                        }
                      }
                    } : null, // Disable if terms not accepted
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.spaceCadetColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                  ),
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Sign In",
                        style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            color: AppColors.spaceCadetColor,
                            fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

