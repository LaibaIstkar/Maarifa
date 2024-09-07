import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/database/supabaseservice.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/account_service/delete_account_service.dart';
import 'package:maarifa/features/auth/sign_in/signin_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final supabase = SupabaseService().supabaseClient;
    final deleteAccountService = DeleteAccountService(supabase: supabase);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        titleTextStyle: TextStyle(color: isDarkTheme ? Colors.white : Colors.black, fontSize: 17),
      ),
      body: Center(
        child: Column(
          children: [
            SwitchListTile(
              value: isDarkTheme,
              title: Text(
                'Dark Mode',
                style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
              ),
              onChanged: (bool value) {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                'Log Out',
                style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
              ),
              leading: const Icon(Icons.logout),
              onTap: ()
              async {
                final navigator = Navigator.of(context);
                await supabase.auth.signOut();
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              leading: const Icon(Icons.delete, color: Colors.red),
              onTap: () {
                _showDeleteAccountDialog(context, deleteAccountService);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, DeleteAccountService deleteAccountService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                navigator.pop();
                _showDeletingDialog(context);

                // Perform the delete operation
                final isDeleted = await deleteAccountService.deleteAccount();

                if (isDeleted) {
                  // If successful, navigate to the sign-in page
                  navigator.pushReplacement(
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }



  void _showDeletingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          title: Text('Deleting Account'),
          content: Text('We are sorry to see you go...'),
        );
      },
    );
  }
}
