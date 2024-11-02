import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/auth/view_model/auth_view_model.dart';
import 'package:maarifa/features/home/home_landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String email = '';
  String password = '';
  bool isDeleting = false;

  bool isNotificationsMuted = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();

  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final authViewModel = ref.read(authViewModelProvider);
    final isUserSignedIn = authViewModel.isUserSignedIn();
    final themeNotifier = ref.read(themeNotifierProvider.notifier);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        titleTextStyle: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
          fontSize: 17,
        ),
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

            // Notifications Switch
            SwitchListTile(
              value: isNotificationsMuted,
              title: Text(
                'Mute All Notifications',
                style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
              ),
              onChanged: (bool value) async {
                setState(() {
                  isNotificationsMuted = value;
                });
                await _saveNotificationSetting(value);
              },
            ),

            const SizedBox(height: 20),
            if (isUserSignedIn && !isDeleting) ...[
              ListTile(
                title: Text(
                  'Log Out',
                  style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                ),
                leading: const Icon(Icons.logout),
                onTap: () async {
                  await authViewModel.signOut();

                  if (!context.mounted) return;

                  if(isDarkTheme) {

                    themeNotifier.toggleTheme();

                  }

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeLandingPage()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Signed out'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
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
                  _showDeleteAccountDialog();
                },
              ),
            ] else if (isDeleting) ...[

              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Deleting Account...'),
            ]
          ],
        ),
      ),
    );
  }

  // Show the delete account confirmation dialog
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
                _showReauthenticationDialog(); // Show the re-authentication dialog
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Show re-authentication dialog to get the user's credentials before account deletion
  void _showReauthenticationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Re-authenticate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  email = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteAccount();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Delete account logic
  Future<void> _deleteAccount() async {
    setState(() {
      isDeleting = true;
    });

    final authViewModel = ref.read(authViewModelProvider);
    try {
      // Re-authenticate and delete user account
      await authViewModel.deleteUserAccount(email, password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account deleted successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );




      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeLandingPage()),
      );
    } catch (e) {
      setState(() {
        isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    }
  }

  // Load the notification setting from SharedPreferences or any persistent storage
  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotificationsMuted = prefs.getBool('isNotificationsMuted') ?? false;
    });
  }

  // Save the notification setting when toggled
  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationsMuted', value);
  }

}

