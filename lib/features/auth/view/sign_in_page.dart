import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_validator/form_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/custom_textform_field.dart';
import 'package:maarifa/features/auth/view/sign_up_page.dart';
import 'package:maarifa/features/home/home_landing_page.dart';
import '../view_model/auth_view_model.dart';


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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                                try {
                                  await authViewModel.signIn(_emailController.text, _passwordController.text);

                                  if(!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Sign-in successful'),
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
                                      content:  Text(e.toString()),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  );
                                }
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
                      ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                          children: [
                            TextSpan(
                              text: "Sign Up",
                              style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.spaceCadetColor,
                                  fontSize: 16),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
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
                                  _showForgotPasswordDialog(context , authViewModel);
                                },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          text: "Email not verified? ",
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                          children: [
                            TextSpan(
                              text: "Verify Now",
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                color: AppColors.spaceCadetColor,
                                fontSize: 16,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _showVerifyEmailDialog(context, authViewModel);
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        )

    );
  }

  void _showVerifyEmailDialog(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController verifyEmailController = TextEditingController();

        return AlertDialog(
          title: const Text('Verify Email'),
          content: CustomTextFormField(
            controller: verifyEmailController,
            label: "Enter your email",
            validator: ValidationBuilder().email().required('Email cannot be empty').build(),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (verifyEmailController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Email cannot be empty'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  );
                } else {
                  try {
                    await authViewModel.sendVerificationEmail();

                    if(!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Verification link sent, please check your email.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    );

                    Navigator.of(context).pop();
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
              },
              child: const Text('Send Verification Link'),
            ),
          ],
        );
      },
    );
  }


  void _showForgotPasswordDialog(BuildContext context, AuthViewModel authViewModel) {
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
                    SnackBar(
                      content: const Text('Email cannot be empty'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  );
                } else {
                  try {
                    await authViewModel.resetPassword(_emailController.text);

                    if(!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Password reset email sent, please check.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    );

                    Navigator.of(context).pop();

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:  Text(e.toString()),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Send reset link'),
            ),
          ],
        );
      },
    );
  }


}
