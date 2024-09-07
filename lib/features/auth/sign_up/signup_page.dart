import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_validator/form_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maarifa/features/auth/sign_up/signup_viewmodel.dart';
import 'package:maarifa/features/home/home_landing_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_textform_field.dart';
import '../sign_in/signin_page.dart';

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


  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpViewModelProvider);

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
        child: SingleChildScrollView( // Wrap with SingleChildScrollView
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
            signUpState.when(
              data: (username) {
                if (username != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeLandingPage()),
                    );
                  });
                }
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final username = _usernameController.text;
                            final email = _emailController.text;
                            final password = _passwordController.text;

                            ref.read(signUpViewModelProvider.notifier).signUp(username, email, password);
                          }
                        },
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
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.toString())),
                  );
                });

                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final username = _usernameController.text;
                            final email = _emailController.text;
                            final password = _passwordController.text;
                            ref.read(signUpViewModelProvider.notifier).signUp(username, email, password);
                          }
                        },
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
                  ],
                );
              },
            ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}





