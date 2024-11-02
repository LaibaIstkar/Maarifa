import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/models/channel_model/channel.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/channel_cover_photo.dart';
import 'package:maarifa/features/admin/logic/admin_controller.dart';
import 'package:maarifa/features/channels/for_mods_channel/ui/channel_posts.dart';
import 'package:maarifa/features/channels/ui/channel_profile.dart';




class AdminChannelDetailPage extends ConsumerStatefulWidget {
  final Channel channel;

  const AdminChannelDetailPage({required this.channel, super.key});

  @override
  AdminChannelDetailPageState createState() => AdminChannelDetailPageState();
}


class AdminChannelDetailPageState extends ConsumerState<AdminChannelDetailPage> {

  final isLoadingProvider = StateProvider<bool>((ref) => false);





  Future<void> _deleteChannelDialoge(BuildContext context, String channelId, String channelName, AdminController adminChannelController) async {
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Channel", style: TextStyle(fontFamily: 'PoppinsBold', fontSize: 17, color: Colors.red)),
          content: const TextField(
            maxLines: null,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
            decoration: InputDecoration(hintText: "You are about to delete this channel and this action can not be undone."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(fontFamily: 'PoppinsBold')),
            ),
            TextButton(
              onPressed: isLoading ? null : () async {
                isLoading = true;
                adminChannelController.deleteChannel(channelId);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text("Deleted successfully."),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),));

              },
              child: const Text("Delete", style: TextStyle(fontFamily: 'PoppinsBold', color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final isDarkTheme = ref.watch(themeNotifierProvider);
    final adminChannelController = ref.watch(adminChannelControllerProvider);



    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChannelProfile(channel: widget.channel),
              ),
            );
          },
          child: Row(
              children: [
                ChannelCoverPhoto(
                  coverPhotoUrl: widget.channel.coverPhoto,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChannelProfile(channel: widget.channel),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10,),
                Text(
                  widget.channel.title,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).textScaler.scale(17),
                    color: isDarkTheme ? Colors.white : Colors.black,
                    fontFamily: 'PoppinsBold',
                  ),
                ),
              ]
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkTheme ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Delete Channel') {
                _deleteChannelDialoge(context, widget.channel.id, widget.channel.title, adminChannelController);}
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: 'Delete Channel', child: Text('Delete Channel')),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: ChannelPosts(channelId: widget.channel.id, channelName: widget.channel.title,),
          ),
        ],
      ),
    );

  }
}