import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/models/channel_model/channel.dart';
import 'package:maarifa/core/models/post_model/post.dart';
import 'package:maarifa/core/services/internet_service.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/auth/view/sign_in_page.dart';
import 'package:maarifa/features/auth/view_model/auth_view_model.dart';
import 'package:maarifa/features/channels/for_mods_channel/ui/channel_detail_page.dart';
import 'package:maarifa/features/channels/for_users_channel/provider/muted_channels_notifier.dart';
import 'package:maarifa/features/channels/for_users_channel/ui/user_channels_page.dart';
import 'package:maarifa/features/channels/for_users_channel/ui/users_channel_detail_page.dart';
import 'package:maarifa/features/channels/logic/channels_controller.dart';
import 'package:maarifa/features/channels/logic/providers.dart';
import 'package:maarifa/features/channels/ui/create_channel_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UsersJoinedChannelsPage extends ConsumerStatefulWidget {
  const UsersJoinedChannelsPage({super.key});

  @override
  UsersJoinedChannelsPageState createState() => UsersJoinedChannelsPageState();
}

class UsersJoinedChannelsPageState extends ConsumerState<UsersJoinedChannelsPage> {
  List<Channel> createdChannels = [];
  int? tappedIndex;
  String? lastUserId;
  List<String> mutedChannels = [];

  @override
  void initState() {
    super.initState();

    _fetchUserCreatedChannels();
    _monitorUserChanges();

    _fetchMutedChannels();
  }


  Future<void> _fetchMutedChannels() async {
    final authViewModel = ref.read(authViewModelProvider);
    final currentUser = authViewModel.getCurrentUser();

    if (currentUser != null) {
      await ref.read(mutedChannelsProvider.notifier).fetchMutedChannels(currentUser.uid);
    }
  }

  Future<void> _toggleMuteChannel(String channelId) async {
    final authViewModel = ref.read(authViewModelProvider);
    final currentUser = authViewModel.getCurrentUser();

    if (currentUser != null) {
      await ref.read(mutedChannelsProvider.notifier).toggleMuteChannel(currentUser.uid, channelId);
    }
  }

  Future<void> _fetchUserCreatedChannels() async {
    final authViewModel = ref.read(authViewModelProvider);
    final currentUser = authViewModel.getCurrentUser();
    if (currentUser != null) {
      final channelController = ref.read(channelControllerProvider);
      final channels = await channelController.getCreatedChannels(currentUser.uid);
      setState(() {
        createdChannels = channels;
      });


    }
  }

  void _monitorUserChanges() {
    final authViewModel = ref.read(authViewModelProvider);
    final currentUser = authViewModel.getCurrentUser();

    if (currentUser?.uid != lastUserId) {
      lastUserId = currentUser?.uid;
      for (final channel in createdChannels) {
        ref.invalidate(lastReadProvider(channel.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final authViewModel = ref.read(authViewModelProvider);
    final currentUser = authViewModel.getCurrentUser();
    final hasInternet = ref.watch(internetServiceProvider);

    if (!hasInternet) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Channels', style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
          backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
        ),
        body: Center(
          child: Text(
            'Oops, no internet :(',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : Colors.black,
              fontFamily: 'PoppinsBold',
              fontSize: 16,
            ),
          ),
        ),
      );
    }


    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Channels', style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
          backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You need to sign in to display channels',
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignInPage(),
                    ),
                  );
                  },
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: isDarkTheme ? AppColorsDark.purpleColor : Colors.purple,
                    fontSize: 16,
                    fontFamily: 'PoppinsBold',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Row(
          children: [
            Text(
              'Channels',
              style: TextStyle(
                fontSize: 17,
                color: isDarkTheme ? Colors.white : Colors.black,
                fontFamily: 'PoppinsBold',
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                if (!context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UserChannelsPage()),
                );
              },
              child: Center(
                child: Text(
                  'Explore Channels',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'PoppinsBold',
                    color: isDarkTheme ? AppColorsDark.purpleColor : AppColors.spaceCadetColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: RichText(
                  text: TextSpan(
                    text: 'Want to create your own channel? ',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkTheme ? Colors.white70 : Colors.black54,
                      fontFamily: 'Poppins',
                    ),
                    children: [
                      TextSpan(
                        text: 'Create Channel',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'PoppinsBold',
                          color: isDarkTheme ? AppColorsDark.purpleColor : AppColors.spaceCadetColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const CreateChannelPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (createdChannels.isNotEmpty) ...[
              Text(
                'Your Channels',
                style: TextStyle(
                  fontSize: 15,
                  color: isDarkTheme ? Colors.white54 : Colors.black54,
                  fontFamily: 'PoppinsBold',
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: createdChannels.length,
                itemBuilder: (context, index) {
                  final channel = createdChannels[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    elevation: 2,
                    child: InkWell(
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 320));
                        if (!context.mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChannelDetailPage(channel: channel),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(
                          channel.title,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // Real-time Joined Channels
            Text(
              'Joined Channels',
              style: TextStyle(
                fontSize: 15,
                color: isDarkTheme ? Colors.white54 : Colors.black54,
                fontFamily: 'PoppinsBold',
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Channel>>(
                stream: ref.watch(channelControllerProvider).getJoinedChannelsWithDetails(currentUser.uid),
                builder: (context, snapshot) {
                  // Check for loading state at the channel level
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Column(
                      children: [
                        LinearProgressIndicator(),
                        Expanded(child: Center(child: Text('Loading channels...'))),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No joined channels.'));
                  }

                  final joinedChannels = snapshot.data!;

                  return ListView.builder(
                    itemCount: joinedChannels.length,
                    itemBuilder: (context, index) {
                      final channel = joinedChannels[index];

                      return Consumer(
                        builder: (context, ref, _) {
                          final lastReadAsyncValue = ref.watch(lastReadProvider(channel.id));

                          return lastReadAsyncValue.when(
                            data: (lastRead) {
                              if (lastRead == null) {
                                return _buildChannelCard(context, channel, lastPost: null, unreadCount: 0);
                              }

                              final unreadCountStream = FirebaseFirestore.instance
                                  .collection('posts')
                                  .where('channelId', isEqualTo: channel.id)
                                  .where('timestamp', isGreaterThan: lastRead)
                                  .snapshots()
                                  .map((snapshot) => snapshot.docs.length);

                              return StreamBuilder<int>(
                                stream: unreadCountStream,
                                builder: (context, unreadCountSnapshot) {
                                  final unreadCount = unreadCountSnapshot.data ?? 0;

                                  final lastPostAsyncValue = ref.watch(lastPostProvider(channel.id));

                                  return lastPostAsyncValue.when(
                                    data: (lastPost) {
                                      return _buildChannelCard(
                                        context,
                                        channel,
                                        lastPost: lastPost,
                                        unreadCount: unreadCount,
                                      );
                                    },
                                    loading: () => const SizedBox.shrink(),
                                    error: (error, _) => Center(child: Text('Error loading last post: $error')),
                                  );
                                },
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (error, _) => Center(child: Text('Error loading last read: $error')),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard(BuildContext context, Channel channel, {Post? lastPost, required int unreadCount}) {
    final mutedChannels = ref.watch(mutedChannelsProvider);
    bool isMuted = mutedChannels.contains(channel.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserChannelDetailPage(channel: channel),
            ),
          );
        },

        onLongPress: () {
          _toggleMuteChannel(channel.id);
        },

        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.title,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    if (lastPost != null)
                      Text(
                        lastPost.content != ""
                            ? lastPost.content.length > 30
                            ? '${lastPost.content.substring(0, 30)}...'
                            : lastPost.content
                            : 'Sent a photo',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (isMuted)
                const Icon(Icons.volume_off, color: Colors.grey),
              if (unreadCount > 0)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.black,
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}



