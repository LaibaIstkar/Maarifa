import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChannelCoverPhoto extends StatelessWidget {
  final String coverPhotoUrl;
  final VoidCallback onTap;

  const ChannelCoverPhoto({
    required this.coverPhotoUrl,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        minRadius: 20,
        maxRadius: 20,
        backgroundColor: Colors.grey[200],
        backgroundImage: CachedNetworkImageProvider(coverPhotoUrl),
      ),
    );
  }
}
