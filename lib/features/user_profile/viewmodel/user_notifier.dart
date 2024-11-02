import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/features/user_profile/model/user_model.dart';


//
// class UserNotifier extends StateNotifier<AsyncValue<UserModel>> {
//   final supabase = SupabaseService().client;
//
//   UserNotifier() : super(const AsyncValue.loading());
//
//   Future<void> fetchUserProfile(String userId) async {
//     try {
//
//       final response = await supabase
//           .from('profiles')
//           .select()
//           .eq('id', userId)
//           .single();
//
//       if (response.containsKey('error')) {
//         state = AsyncValue.error(response['error'].toString(), StackTrace.current );
//       } else {
//         final userData = UserModel.fromMap(response);
//         state = AsyncValue.data(userData);
//       }
//     } catch (e) {
//       state = AsyncValue.error(e.toString(), StackTrace.current);
//     }
//   }
//
//   Future<void> updateUserProfile(UserModel user) async {
//     try {
//       final response = await supabase.from('profiles').update(user.toMap()).eq('id', user.id);
//
//       if (response.error != null) {
//         state = AsyncValue.error(response.error!.message, StackTrace.current);
//       } else {
//         state = AsyncValue.data(user);
//       }
//     } catch (e) {
//       state = AsyncValue.error(e.toString(), StackTrace.current);
//     }
//   }
// }
//
// final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel>>((ref) {
//   final authState = ref.watch(authStateNotifierProvider);
//
//   final userNotifier = UserNotifier();
//   if (authState.userId != null) {
//     // Call fetchUserProfile with the user ID from authState
//     userNotifier.fetchUserProfile(authState.userId!);
//   }
//   return userNotifier;
// });
//
