import 'package:cloud_firestore/cloud_firestore.dart';

class Channel {
  final String id; // Document ID from Firestore
  final String creatorId;
  final String description;
  final String title;
  final String purpose;
  final String coverPhoto;
  final bool isApproved;
  final String user;

  Channel({
    required this.id,
    required this.creatorId,
    required this.description,
    required this.title,
    required this.purpose,
    required this.coverPhoto,
    required this.isApproved,
    required this.user
  });

  // Factory method to create a Channel from Firestore DocumentSnapshot
  factory Channel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Channel(
      id: doc.id,
      creatorId: data['creatorId'],
      description: data['description'],
      title: data['title'],
      purpose: data['purpose'],
      coverPhoto: data['coverPhoto'],
      isApproved: data['approved'],
      user: data['user'],
    );
  }

  // Convert Channel object to a Firestore document (Map)
  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'description': description,
      'title' : title,
      'purpose': purpose,
      'coverPhoto': coverPhoto,
      'approved': isApproved,
      'user': user,
    };
  }

}
