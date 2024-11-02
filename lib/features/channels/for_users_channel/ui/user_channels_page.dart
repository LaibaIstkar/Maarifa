import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/models/channel_model/channel.dart';
import 'package:maarifa/core/services/internet_service.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/shimmer_image.dart';
import 'package:maarifa/features/auth/view_model/auth_view_model.dart';
import 'package:maarifa/features/channels/logic/channels_controller.dart';



class UserChannelsPage extends ConsumerStatefulWidget {
  const UserChannelsPage({super.key});

  @override
  ConsumerState<UserChannelsPage> createState() => _UserChannelsPageState();
}

class _UserChannelsPageState extends ConsumerState<UserChannelsPage> {
  String? uid;
  String? username;
  List<String> joinedChannelIds = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }


  Future<void> _fetchUserDetails() async {
    final authView = ref.read(authViewModelProvider);
    final user = authView.getCurrentUser();

    if (user != null) {
      uid = user.uid;
      username = await authView.getUsername();
      _fetchUserJoinedChannels();
      setState(() {});
    }
  }

  Future<void> _fetchUserJoinedChannels() async {
    if (uid != null) {
      final channelController = ref.read(channelControllerProvider);

      channelController.getJoinedChannels(uid!).listen((channelIds) {
        setState(() {
          joinedChannelIds = channelIds;
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final channelController = ref.watch(channelControllerProvider);
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final hasInternet = ref.watch(internetServiceProvider);

    if (!hasInternet) {
      return Scaffold(
        body: Center(
          child: Text(
            'Oops, no internet... :(',
            style: TextStyle(
              fontSize: 17,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Join Channels',
          style: TextStyle(
            fontSize: 17,
            color: isDarkTheme ? Colors.white : Colors.black,
            fontFamily: 'PoppinsBold',
          ),
        ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
      ),
      body: StreamBuilder<List<Channel>>(
        stream: channelController.getApprovedChannels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No channels available.'));
          }

          final channels = snapshot.data!
              .where((channel) => !joinedChannelIds.contains(channel.id)) // Exclude joined channels
              .toList();

          if (channels.isEmpty) {
            return const Center(child: Text('You have already joined all available channels.'));
          }

          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];

              return Card(
                color: isDarkTheme ? AppColorsDark.cardBackground : AppColors.primaryColorPlatinum,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerImage(imageUrl: channel.coverPhoto),

                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Moderator",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkTheme ? Colors.white54 : Colors.black54,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            channel.user,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDarkTheme ? Colors.white : Colors.black,
                              fontFamily: 'PoppinsBold',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            channel.title,
                            style: TextStyle(
                              fontSize: 19,
                              color: isDarkTheme ? Colors.white : Colors.black,
                              fontFamily: 'PoppinsBold',
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            channel.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkTheme ? Colors.white : Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Why join?",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkTheme ? Colors.white54 : Colors.black54,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            channel.purpose,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkTheme ? Colors.white : Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _handleJoinClick(uid, username, channel, context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: uid == null ? Colors.grey : Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text('Join Channel'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleJoinClick(String? uid, String? username, Channel channel, BuildContext context) {
    if (!mounted) return;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sign in first to join a channel'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    } else {
      _joinChannel(channel, uid, username!, context);
    }
  }

  Future<void> _joinChannel(Channel channel, String userId, String username, BuildContext context) async {
    final channelController = ref.read(channelControllerProvider);

    try {
      await channelController.joinChannel(userId, username, channel.id);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have joined ${channel.title}!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );

      // Update the list of joined channels
      _fetchUserJoinedChannels();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error joining channel, please try again.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    }
  }
}

