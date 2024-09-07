import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/supabaseservice.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_textform_field.dart';

class NewPasswordPage extends StatefulWidget {


  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetTokenController = TextEditingController();
  final _reEnterPasswordController = TextEditingController();
  bool? isLoading;
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _resetTokenController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final supabase = SupabaseService().supabaseClient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextFormField(
                  controller: _resetTokenController,
                  label: "Token",
                  validator: ValidationBuilder().maxLength(6).build(),
                ),
                const SizedBox(height: 16,),
                CustomTextFormField(
                  controller: _emailController,
                  label: "Email",
                  validator: ValidationBuilder().email().build(),
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _passwordController,
                  label: "New Password",
                  obscureText: true,
                  validator: ValidationBuilder().minLength(6).build(),
                ),
                const SizedBox(height: 16,),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        isLoading = true;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        try {
                          await supabase.auth.updateUser(
                            UserAttributes(password: _passwordController.text),
                          );
                          isLoading = false;
                          if(!context.mounted) return;
                          Navigator.of(context, rootNavigator: true).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password reset successful. Please log in again.')),
                          );
                          Navigator.of(context).pop();
                        } catch (e) {
                          Navigator.of(context, rootNavigator: true).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in the form correctly!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.spaceCadetColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Set New Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}

