import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_validator/form_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maarifa/features/auth/sign_in/new_password_page.dart';
import 'package:maarifa/features/auth/sign_in/signin_viewmodel.dart';
import 'package:maarifa/features/home/home_landing_page.dart';
import '../../../core/database/supabaseservice.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_textform_field.dart';
import '../sign_up/signup_page.dart';



class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    final signInState = ref.watch(signInViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Maarifa',
          style: GoogleFonts.poppins(
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
                  "Welcome back!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
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
                const SizedBox(height: 32),
                // Display the button and handle navigation and errors
                signInState.when(
                  data: (username) {
                    // Navigate if username is not empty
                    if (username != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeLandingPage()),
                        );
                      });
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final email = _emailController.text;
                            final password = _passwordController.text;
                            ref.read(signInViewModelProvider.notifier).signIn(email, password);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.spaceCadetColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Sign In', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                      ),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    });
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();
                            ref.read(signInViewModelProvider.notifier).signIn(email, password);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.spaceCadetColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Sign In', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          color: AppColors.spaceCadetColor,
                          fontSize: 16,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to Sign Up page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16,),
                Text.rich(
                  TextSpan(
                    text: "Forgot your password? ",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: "Recover",
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          color: AppColors.spaceCadetColor,
                          fontSize: 16,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _showForgotPasswordDialog(context);
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: CustomTextFormField(
            controller: _emailController,
            label: "Enter your email",
            validator: ValidationBuilder().email().required('Email cannot be empty').build(),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_emailController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email cannot be empty')),
                  );
                } else {
                  await _resetPassword(context);
                  if(!context.mounted) return;
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewPasswordPage(),
                    ),
                  );
                }
              },
              child: const Text('Send Token'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetPassword(BuildContext context) async {
    final supabase = SupabaseService().supabaseClient;
    final email = _emailController.text.trim();

    if (email.isNotEmpty) {
      try {
        await supabase.auth.resetPasswordForEmail(email);
        if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token sent to $email')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending token: $error')),
        );
      }
    }
  }
}

