import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/models/channel_model/channel.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/admin/logic/admin_controller.dart';
import 'package:maarifa/features/admin/ui/admin_channel_detail_page.dart';
import 'package:maarifa/features/admin/ui/admin_page.dart';
import 'package:maarifa/features/auth/view_model/auth_view_model.dart';


class AdminJoinedChannelsPage extends ConsumerStatefulWidget {
  const AdminJoinedChannelsPage({super.key});

  @override
  AdminJoinedChannelsPageState createState() => AdminJoinedChannelsPageState();
}

class AdminJoinedChannelsPageState extends ConsumerState<AdminJoinedChannelsPage> {
  List<Channel> createdChannels = [];
  List<Channel> joinedChannels = [];

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final userId = ref.watch(authViewModelProvider).getCurrentUser()?.uid;

    return Scaffold(
      appBar: AppBar(
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
                if(!context.mounted) return;

                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AdminPage())
                );
              },
              child: Flexible(
                child: Center(
                  child: Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'PoppinsBold',
                      color: isDarkTheme ? AppColorsDark.purpleColor  : AppColors.spaceCadetColor,
                    ),
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
            DeleteExpiredChannelsButton(ref: ref,),
            const SizedBox(height: 20),

            FutureBuilder<List<Channel>>(
              future: ref.read(adminChannelControllerProvider).getCreatedChannels(userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  createdChannels = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    builder: (context) => AdminChannelDetailPage(channel: channel),
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
                  );
                } else {
                  return const Text('No channels created yet');
                }
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Channel>>(
              future: ref.read(adminChannelControllerProvider).getApprovedChannels(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  joinedChannels = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Joined Channels',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDarkTheme ? Colors.white54 : Colors.black54,
                          fontFamily: 'PoppinsBold',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: joinedChannels.length,
                        itemBuilder: (context, index) {
                          final channel = joinedChannels[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AdminChannelDetailPage(channel: channel),
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
                    ],
                  );
                } else {
                  return const Text('No joined channels yet');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteExpiredChannelsButton extends StatelessWidget {
  final WidgetRef ref;

  const DeleteExpiredChannelsButton({required this.ref, super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return InkWell(
      onTap: () async {
        await ref.read(adminChannelControllerProvider).deleteExpiredChannels();
        if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expired channels deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Delete expired Channels ',
              style: TextStyle(
                color: isDarkTheme ? Colors.white54 : Colors.black54,
              ),
            ),
            const TextSpan(
              text: 'Delete',
              style: TextStyle(
                color: AppColors.purpleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}