import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String channelId;
  final String content;
  final List<String> images; // Changed to a list of images
  final Map<String, String> reactions;
  final DateTime? timestamp; // Add timestamp field
  final bool? isDeletionWarning;

  Post({
    required this.id,
    required this.channelId,
    required this.content,
    this.images = const [], // Initialize as an empty list
    this.reactions = const {},
    this.timestamp,
    this.isDeletionWarning,
  });

  // Factory method to create a Post from Firestore DocumentSnapshot
  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      channelId: data['channelId'],
      content: data['content'],
      images: List<String>.from(data['images'] ?? []), // Handle list of images
      reactions: Map<String, String>.from(data['reactions'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      isDeletionWarning: data['isDeletionWarning']
    );
  }

  // To Map method for adding/updating Post in Firestore
  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'content': content,
      'images': images, // Save the list of images
      'reactions': reactions,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
      'isDeletionWarning': isDeletionWarning
    };
  }

}

