import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportService {
  final String sendGridApiKey = "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";
  final String adminEmail = 'laibaistkar0@gmail.com';
  final String fromEmail = 'noreply@maarifa.com';

  // Function to check the report count and send an email
  Future<void> checkReportAndSendEmail(String channelId, String? postId, String channelName, String type, ) async {
    CollectionReference reports = FirebaseFirestore.instance.collection('reports');
    Query query;

    // Query based on whether it's a post or a channel report
    if (type == 'post') {
      query = reports.where('postId', isEqualTo: postId);
    } else {
      query = reports.where('channelId', isEqualTo: channelId).where('type', isEqualTo: 'channel');
    }

    try {
      QuerySnapshot reportSnapshots = await query.get();
      int reportCount = reportSnapshots.size;

      if (reportCount >= 5) {
        // Collect report messages for email content

        List<String> reportMessages = reportSnapshots.docs.map((doc) => doc['reportMessage'] as String).toList();


        // Prepare and send email
        await _sendEmail(channelId, postId, channelName, reportMessages, reportCount, type);
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Function to send an email using SendGrid API
  Future<void> _sendEmail(String channelId, String? postId, String channelName, List<String> reportMessages, int reportCount, String type) async {
    final subject = type == 'post' ? 'Post in Channel $channelName Reported' : 'Channel $channelName Reported';
    final content = type == 'post' ? 'Post ID: $postId' : '';
    final reportDetails = reportMessages.join('\n');

    final message = {
      'personalizations': [
        {
          'to': [
            {'email': adminEmail}
          ],
          'subject': subject
        }
      ],
      'from': {'email': fromEmail},
      'content': [
        {
          'type': 'text/plain',
          'value': 'The following $type has been reported more than $reportCount times:\n\n'
              'Channel: $channelName (ID: $channelId)\n'
              '$content\n\n'
              'Reports:\n$reportDetails'
        }
      ]
    };

    await http.post(
      Uri.parse('https://api.sendgrid.com/v3/mail/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $sendGridApiKey',
      },
      body: json.encode(message),
    );
  }
}
