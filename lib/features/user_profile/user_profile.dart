import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/database/user_profile_service.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/custom_textform_field.dart';
import 'package:maarifa/features/user_profile/viewmodel/user_notifier.dart';






// class UserProfile extends ConsumerWidget {
//   const UserProfile({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isDarkTheme = ref.watch(themeNotifierProvider);
//     final userAsyncValue = ref.watch(userNotifierProvider);
//     final authState = ref.watch(authStateNotifierProvider);
//     final userProfileService = UserProfileService(supabase: SupabaseService().client); // Adjust based on your setup
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
//         titleTextStyle: TextStyle(
//           color: isDarkTheme ? Colors.white : Colors.black,
//           fontSize: 17,
//         ),
//       ),
//       body: userAsyncValue.when(
//         data: (user) {
//           final isOwnProfile = authState.userId == user.id;
//           final bioController = TextEditingController(text: user.bio);
//
//           return Column(
//             children: [
//               // Cover Photo and Profile Picture
//               Stack(
//                 children: [
//                   Container(
//                     height: 200,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: user.coverUrl != null
//                             ? NetworkImage(user.coverUrl!)
//                             : const AssetImage('assets/default_cover.png')
//                         as ImageProvider,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     child: isOwnProfile
//                         ? Positioned(
//                       top: 10,
//                       right: 10,
//                       child: IconButton(
//                         icon: const Icon(Icons.add_a_photo,
//                             color: Colors.black26),
//                         onPressed: () {
//                           // Logic to change the cover photo
//                         },
//                       ),
//                     )
//                         : null,
//                   ),
//                   // Profile Picture
//                   Positioned(
//                     bottom: 0, // Ensure the circle avatar is visible
//                     left: 20,
//                     right: 20,
//                     child: Align(
//                       alignment: Alignment.bottomLeft,
//                       child: GestureDetector(
//                         onTap: isOwnProfile
//                             ? () async {
//                           print('Profile picture tapped');
//                           try {
//                             final file = await userProfileService.pickImageFromGallery();
//                             if (file != null) {
//                               print('Updating profile picture...');
//                               await userProfileService.updateProfilePicture(file.path);
//                               ref.refresh(userNotifierProvider);
//                             }
//                           } catch (e) {
//                             print('Error uploading profile picture: $e');
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Failed to update profile picture'),
//                               ),
//                             );
//                           }
//                         }
//                             : null,
//                         child: CircleAvatar(
//                           radius: 40,
//                           backgroundImage: user.avatarUrl != null
//                               ? NetworkImage(user.avatarUrl!)
//                               : const AssetImage('assets/default_avatar.png')
//                           as ImageProvider,
//                           child: isOwnProfile
//                               ? Align(
//                             alignment: Alignment.bottomRight,
//                             child: CircleAvatar(
//                               backgroundColor: Colors.grey[200],
//                               radius: 12,
//                               child: const Icon(
//                                 Icons.add,
//                                 size: 16,
//                                 color: Colors.black26,
//                               ),
//                             ),
//                           )
//                               : null,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 60), // Space for the CircleAvatar overlap
//
//               // Badges
//               if (user.badges != null)
//                 Wrap(
//                   alignment: WrapAlignment.center, // Center-align badges
//                   children: user.badges!.map((badge) {
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Image.asset(
//                         'assets/badges/$badge.svg',
//                         width: 50,
//                         height: 50,
//                       ),
//                     );
//                   }).toList(),
//                 ),
//
//               // User's Name
//               Text(
//                 user.username,
//                 style: TextStyle(
//                   fontSize: 24,
//                   color: isDarkTheme ? Colors.white : Colors.black,
//                 ),
//               ),
//
//               // Bio Data using CustomTextFormField
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: CustomTextFormField(
//                   controller: bioController,
//                   label: 'Bio',
//                   obscureText: false,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a bio';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//
//               // Space filler to push the Edit Profile button to the bottom
//               Spacer(), // This pushes the following widget to the bottom
//
//               // Edit Profile Button
//               if (isOwnProfile)
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Navigate to Edit Profile Page
//                     },
//                     child: const Text('Edit Profile'),
//                   ),
//                 ),
//             ],
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, _) => Center(child: Text('Error: $error')),
//       ),
//     );
//   }
// }
