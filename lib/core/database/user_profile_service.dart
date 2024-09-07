import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileService {
  final SupabaseClient supabase;

  UserProfileService({required this.supabase});

  // Method to upload a profile picture to Supabase Storage
  Future<void> updateProfilePicture(String filePath) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    // File to be uploaded
    final file = File(filePath);
    final fileName = '${user.id}_profile_picture.png'; // Unique file name for the user's profile picture

    // Upload the file to the 'avatars' bucket in Supabase Storage
    final response = await supabase.storage.from('avatars').upload(fileName, file);
    if (response.isEmpty ) {
      throw Exception('Failed to upload profile picture');
    }

    // Get the public URL of the uploaded image
    final avatarUrl = supabase.storage.from('avatars').getPublicUrl(fileName)!;

    // Update the user's profile in the 'profiles' table
    final updateResponse = await supabase.from('profiles').update({'avatar_url': avatarUrl}).eq('id', user.id);
    if (updateResponse.error != null) {
      throw Exception('Failed to update profile picture URL: ${updateResponse.error!.message}');
    }
  }

  Future<File?> pickImageFromGallery() async {
    print('Requesting gallery permission...');
    final status = await Permission.photos.request();

    if (status.isGranted) {
      print('Permission granted. Opening image picker...');
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        print('Image selected: ${pickedFile.path}');
        return File(pickedFile.path);
      } else {
        print('No image selected.');
        return null;
      }
    } else if (status.isDenied) {
      print('Gallery access denied');
      return null;
    } else if (status.isPermanentlyDenied) {
      print('Permission permanently denied. Opening app settings...');
      openAppSettings();
      return null;
    }
    return null;
  }


  // Method to update the cover photo with a selected photo from the app's predefined set
  Future<void> updateCoverPhoto(String selectedPhoto) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    // Assuming selectedPhoto is a URL or identifier of the cover photo
    final response = await supabase.from('profiles').update({'cover_url': selectedPhoto}).eq('id', user.id);
    if (response.error != null) {
      throw Exception('Failed to update cover photo: ${response.error!.message}');
    }
  }

  // Method to update the user's bio
  Future<void> updateBio(String bio) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    final response = await supabase.from('profiles').update({'bio': bio}).eq('id', user.id);
    if (response.error != null) {
      throw Exception('Failed to update bio: ${response.error!.message}');
    }
  }
}
