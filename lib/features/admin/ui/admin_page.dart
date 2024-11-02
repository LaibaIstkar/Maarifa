import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/models/channel_model/channel.dart';
import 'package:maarifa/core/services/internet_service.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/shimmer_image.dart';
import 'package:maarifa/features/admin/logic/admin_controller.dart';


class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {

  @override
  Widget build(BuildContext context) {
    final adminController = ref.read(adminControllerProvider.notifier);
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final hasInternet = ref.watch(internetServiceProvider);

    if (!hasInternet) {
      return  Scaffold(
        body: Center(
          child: Text(
            'Oops, no internet... :(',
            style: TextStyle(fontSize: 17, color: isDarkTheme ? Colors.white : Colors.black, fontFamily: 'Roboto'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Admin Panel', style: TextStyle(
        fontSize: 17,
        color: isDarkTheme ? Colors.white : Colors.black,
        fontFamily: 'PoppinsBold',
      ),
      ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,),
      body: StreamBuilder<List<Channel>>(
        stream: adminController.getPendingChannels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pending channels.'));
          }

          final channels = snapshot.data!;
          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];

              return Card(
                color:  isDarkTheme ? AppColorsDark.cardBackground : AppColors.primaryColorPlatinum,
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
                          const SizedBox(height: 3,),

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
                          // Purpose
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
                            "Why join ?",
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
                          const SizedBox(height: 5),
                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  adminController.approveChannel(channel.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red), // Cross icon
                                onPressed: () {
                                  adminController.deleteChannel(channel.id);
                                },
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
}

